import Foundation

class OpenAIClient {
    private let apiKey = "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" // please don't abuse this I just need the project to work for you locally. I do not want you to pay to use my app.
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    // Function to send the prompt to ChatGPT
    func getAllergens(for food: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion("Invalid URL")
            return
        }
        
        // Request headers
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        // Construct the prompt
        let prompt = "What are the allergens in \(food)?"
        
        // Body of the request
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": prompt]],
            "temperature": 0.7
        ]
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Send the request and handle the response
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                // Parse the response JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // Return the content of the response
                    completion(content)
                } else {
                    completion("Invalid response format")
                }
            } catch {
                completion("Failed to parse response: \(error.localizedDescription)")
            }
        }.resume()
    }
}
