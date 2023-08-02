//
//  DownloadImageAsync.swift
//  AsyncImageDownload
//
//  Created by Anup D'Souza on 01/08/23.
//

import SwiftUI
import Combine

class DownloadImageAsyncLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode else {
            return nil
        }
        return image
    }
    
    /// Image download with escaping completion handler
    func downloadImage(onCompletion completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) {[weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completion(image, error)
            
        }.resume()
    }
    
    /// Image download using Combine
    func downloadImage() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    /// Image download using async/await
    func downloadImageAsync() async throws -> UIImage? {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        return handleResponse(data: data, response: response)
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let imageLoader = DownloadImageAsyncLoader()
    var cancellables = Set<AnyCancellable>()
    func fetchImage() {
        imageLoader.downloadImage { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func fetchImageWithCombine() {
        imageLoader.downloadImage()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
    }
    
    func fetchImageAsync() async {
        let image = try? await imageLoader.downloadImageAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear { [weak viewModel] in // prevent leak inside Task
//            viewModel.fetchImage()
//            viewModel.fetchImageWithCombine()
            Task {
                await viewModel?.fetchImageAsync()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
