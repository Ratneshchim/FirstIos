//
//  ContentView.swift
//  RAT
//
//  Created by Ratnesh Chimnani on 5/28/23.
//

import SwiftUI

struct ContentView: View {
    @State private var searchTerm = ""
    @State private var images: [UIImage] = []
    @State private var page = 1
    
    private let baseUrl = "https://api.imgur.com/3/gallery/search/time/"
    private let clientId = "15bebbc01a7d847"
    
    var body: some View {
        VStack {
            TextField("Enter search term", text: $searchTerm, onCommit: searchImages)
                .padding()
            
            List(images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
            .onAppear(perform: searchImages)
        }
    }
    
    private func searchImages() {
        //constructing the base url with the search term
        guard let url = URL(string: "\(baseUrl)\(page)?q=\(searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            print("Invalid URL")
            return
        }
        
        // giving the autherization
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        
        // calling the Server/API
        URLSession.shared.dataTask(with: request) {  (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let items = json?["data"] as? [[String: Any]] {
                    var fetchedImages: [UIImage] = []
                    for item in items {
                        // extarct url with term "link", construct a url, extract and check the image data and assign it to imagedata, creeate object UIImage with image data and then append it to the array for display
                        if let imageUrl = item["link"] as? String, let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                            fetchedImages.append(image)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.images.append(contentsOf: fetchedImages)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        .resume()
        page += 1
    }
    // end of searchimage function
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
