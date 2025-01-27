//
//  ContentView.swift
//  All-ergen
//
//  Created by Frankie Severino on 1/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = "Allergens will be displayed here."
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Enter food (e.g., Apple pie)", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.default)
                    .frame(maxWidth: .infinity)
                
                Button(action: fetchAllergens) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Check Allergens")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .disabled(isLoading || inputText.isEmpty)
                .padding(.horizontal)
                
                ScrollView {
                    Text(resultText)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("ALL-ergen")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.vertical)
        }
    }
    
    private func fetchAllergens() {
        guard !inputText.isEmpty else { return }
        
        isLoading = true
        resultText = "Fetching allergens..."
        
        let apiKey = "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"
        let endpoint = "https://api.openai.com/v1/chat/completions"
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": "What are the most common allergens in \(inputText) in list form? Then list some less common allergens. Lastly append: ALL-ergen is approximate information. Please check specific recipes for more accurate results"]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 500,
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        resultText = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        resultText = "Sorry, we couldn't process the response. Please try again."
                    }
                } catch {
                    resultText = "Error parsing server response. Please try again later."
                }
            }
        }.resume()
    }
}
#Preview {
    ContentView()
}
