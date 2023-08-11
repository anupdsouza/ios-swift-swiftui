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
            await viewModel?.fetchImage()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
