import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = "Allergens will be displayed here."
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter food (e.g., Apple pie)", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
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
            .disabled(isLoading || inputText.isEmpty)
            
            ScrollView {
                Text(resultText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func fetchAllergens() {
        guard !inputText.isEmpty else { return }
        
        isLoading = true
        resultText = "Fetching allergens..."
        
        let apiKey = "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"
        let endpoint = "https://api.openai.com/v1/chat/completions"
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": "What are the allergens in \(inputText) in list form?"]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
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
                        print("Raw Response: \(json)")
                        
                        if let choices = json["choices"] as? [[String: Any]],
                           let message = choices.first?["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            resultText = content.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    @main
    struct MyApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
}
