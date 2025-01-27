import SwiftUI

struct ContentView: View {
    @State private var inputText: String = "" // User input
    @State private var resultText: String = "Allergens will be displayed here." // API response
    @State private var isLoading: Bool = false // Loading state

    var body: some View {
        VStack(spacing: 20) {
            // Input field
            TextField("Enter food (e.g., Apple pie)", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Button to submit the request
            Button(action: fetchAllergens) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Check Allergens")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading || inputText.isEmpty) // Disable when loading or input is empty

            // Response display
            ScrollView {
                Text(resultText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)
            }

            Spacer() // Push content to the top
        }
        .padding()
    }

    /// Fetch allergens from OpenAI API
    private func fetchAllergens() {
        guard !inputText.isEmpty else { return }

        isLoading = true
        resultText = "Fetching allergens..."

        // Prepare API request
        let apiKey = "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" // please don't abuse this I just need the project to work for you locally. I do not want you to pay to use my app.
        let endpoint = "https://api.openai.com/v1/chat/completions"
        let prompt = "What are the allergens in \(inputText) in list form?"

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo-0125",
            "prompt": prompt,
            "max_tokens": 100,
            "temperature": 0.7
        ]

        guard let url = URL(string: endpoint),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            resultText = "Error creating request"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    resultText = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    resultText = "No data received"
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Log the entire response for debugging
                        print("Raw Response: \(json)")

                        if let choices = json["choices"] as? [[String: Any]],
                           let text = choices.first?["text"] as? String {
                            resultText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        } else {
                            resultText = "Unexpected response format: \(json)"
                        }
                    } else {
                        resultText = "Unable to parse JSON response"
                    }
                } catch {
                    resultText = "Error parsing response: \(error.localizedDescription)"
                }

            }
        }.resume()
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
