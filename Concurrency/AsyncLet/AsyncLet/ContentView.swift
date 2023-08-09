//
//  ContentView.swift
//  AsyncLet
//
//  Created by Anup D'Souza on 09/08/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let")
            .onAppear {
                Task {
                    do {
                        
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        //note: using 'try' will exit to the catch block if any async fetchImage operations fail
                        let (img1, img2, img3, img4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                        self.images.append(contentsOf: [img1, img2, img3, img4])
                        
                        
                        async let fetchImage5 = fetchImage()
                        async let fetchArticle = fetchArticle()
                        let (img, text) = await (try fetchImage5, fetchArticle)
                        // Do something with img, text
                        
                        let image1 = try await fetchImage()
                        self.images.append(image1)

                        let image2 = try await fetchImage()
                        self.images.append(image2)

                        let image3 = try await fetchImage()
                        self.images.append(image3)

                        let image4 = try await fetchImage()
                        self.images.append(image4)
                        
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func fetchArticle() async -> String {
        return "Lorem ipsum..."
    }

    private func fetchImage() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://picsum.photos/300")!)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw URLError(.badServerResponse)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
