//
//  ContentView.swift
//  CheckedContinuations
//
//  Created by Anup D'Souza on 11/08/23.
//

import SwiftUI

struct DataLoader {
    
    func getData(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }.resume()
        }
    }
    
    func getSystemImage(_ name: String, completion: @escaping(_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(UIImage(systemName: name)!)
        }
    }
    
    func getHeartSystemImage() async -> UIImage {
        await withCheckedContinuation { continuation in
            getSystemImage("heart.fill") { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class ViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    private let dataLoader = DataLoader()
    
    func fetchImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else {
            return
        }
        
        do {
            let data = try await dataLoader.getData(url: url)
            if let img = UIImage(data: data) {
                await MainActor.run {
                    self.image = img
                }
            }
        } catch {
            print(error)
        }
    }
    
    func fetchSystemImage() {
        dataLoader.getSystemImage("heart.fill") { [weak self] image in
            self?.image = image
        }
    }
    
    func fetchHeartSystemImage() async {
        self.image = await dataLoader.getHeartSystemImage()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
            Text("Hello, world!")
        }
        .padding()
        .task { [weak viewModel] in
            //await viewModel?.fetchImage()
            //await viewModel?.fetchSystemImage()
            await viewModel?.fetchHeartSystemImage()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
