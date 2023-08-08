//
//  ContentView.swift
//  Task
//
//  Created by Anup D'Souza on 08/08/23.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(for: .seconds(2))
        do {
            guard let url = URL(string: "https://picsum.photos/600") else {
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image = UIImage(data: data)
                print("image downloaded successfully")
            }
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/600") else {
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image2 = UIImage(data: data)
                print("image2 downloaded successfully")
            }
            
        } catch  {
            print(error.localizedDescription)
        }
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Click me") {
                    ContentView()
                }
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject private var viewModel = TaskViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//            fetchImageTask = Task {
//                await viewModel.fetchImage()
//            }
            
//            Task {
//                await viewModel.fetchImage()
//                await viewModel.fetchImage2()
//            }
            
//            Task(priority: .userInitiated) {
//                print("userInitiated \(Thread.current): \(Task.currentPriority)")
//            }
//            Task(priority: .high) {
//                await Task.yield()
//                print("high \(Thread.current): \(Task.currentPriority)")
//            }
//            Task(priority: .low) {
//                print("low \(Thread.current): \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("utility \(Thread.current): \(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("background \(Thread.current): \(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("medium \(Thread.current): \(Task.currentPriority)")
//            }
            
//            Task(priority: .medium) {
//                print("medium1 \(Thread.current): \(Task.currentPriority)")
//
//                // same priority as parent
//                Task {
//                    print("medium2 \(Thread.current): \(Task.currentPriority)")
//                }
//            }
//
//            Task(priority: .low) {
//                print("medium3 \(Thread.current): \(Task.currentPriority)")
//
//                // different priority than parent
//                Task.detached {
//                    print("medium3 detached \(Thread.current): \(Task.currentPriority)")
//                }
//            }
//
//            Task(priority: .low) {
//                print("medium4 \(Thread.current): \(Task.currentPriority)")
//
//                // different priority than parent
//                Task.detached(priority: .high) {
//                    print("medium4 detached \(Thread.current): \(Task.currentPriority)")
//                }
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
