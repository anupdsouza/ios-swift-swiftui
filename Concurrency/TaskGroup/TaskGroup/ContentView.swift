//
//  ContentView.swift
//  TaskGroup
//
//  Created by Anup D'Souza on 10/08/23.
//

import SwiftUI

class TaskGroupDataManager {
    
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
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let img1 = fetchImage()
        async let img2 = fetchImage()
        async let img3 = fetchImage()
        async let img4 = fetchImage()
        let (image1, image2, image3, image4) = await (try img1, try img2, try img3, try img4)
        return [image1, image2, image3, image4]
    }
    
    private func fetchImage(withUrlString urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchImagesWithAsyncTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                group.addTask { [self] in
                    try? await self.fetchImage(withUrlString: urlString)
                }
            }
            
            // note: will wait indefinitely until all tasks complete or fail
            for try await result in group {
                if let result {
                    images.append(result)
                }
            }
            
            return images
        }
    }
    
}
class TaskGroupViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let dataManager = TaskGroupDataManager()
    
    func getImages() async {
        let images = try? await dataManager.fetchImagesWithAsyncLet()
        if let images {
            self.images.append(contentsOf: images)
        }
        
        let images2 = try? await dataManager.fetchImagesWithAsyncTaskGroup()
        if let images2 {
            self.images.append(contentsOf: images2)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskGroupViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
