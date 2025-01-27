import SwiftUI
import OpenAIKit

struct ContentView: View {
    @State private var userInput = ""
    @State private var allergenDetectionResult = ""

    var apiKey: String {
        return "YOUR_OPENAI_API_KEY" // Replace with your actual API key
    }

    var configuration: Configuration {
        Configuration(apiKey: apiKey)
    }

    var openAIClient: OpenAIKit.Client {
        OpenAIKit.Client(configuration: configuration)
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter food", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Detect Allergens") {
                    detectAllergens()
                }
                .padding()

                if !allergenDetectionResult.isEmpty {
                    Text(allergenDetectionResult)
                        .padding()
                }
            }
            .navigationTitle("Allergen Detector")
        }
    }

    func detectAllergens() {
        let prompt = "Given the food '\(userInput)', can you detect any allergens?"

        do {
            let completion = try await openAIClient.chat.completions.create(
                model: Model.GPT3.davinci,
                messages: [
                    .init(role: .system, content: "You are a helpful assistant."),
                    .init(role: .user, content: prompt)
                ],
                temperature: 0.8,
                maxTokens: 50
            )

            if let response = completion.choices.first?.message.content {
                self.allergenDetectionResult = response
            }

        } catch {
            print("Error: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
