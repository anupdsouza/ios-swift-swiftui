//
//  ContentView.swift
//  AsyncAwait
//
//  Created by Anup D'Souza on 08/08/23.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    @Published var data: [String] = []
    
    func addTitle1() {
        data.append("title 1: \(Thread.current)")
    }
    
    func addTitle2() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.data.append("title 2: \(Thread.current)")
        }
    }
    
    func addTitle3() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) { [weak self] in
            let item = "title 3: \(Thread.current)"
            DispatchQueue.main.async {
                
                self?.data.append(item)
                
                self?.addTitle4()
            }
        }
    }
    
    func addTitle4() {
        self.data.append("title 4: \(Thread.current)")
    }
    
    func addAuthor1() async {
        self.data.append("author 1: \(Thread.current)")
    }
    
    func addAuthor2() async {
        try? await Task.sleep(for: .seconds(2))
        self.data.append("author 2: \(Thread.current)")
    }
    
    func addAuthor3() async {
        try? await Task.sleep(for: .seconds(3))
        await MainActor.run {
            self.data.append("author 3: \(Thread.current)")
        }
    }

    func doSomething() async {
        await addAuthor1()
        await addAuthor2()
        await addAuthor3()
    }
    
    func addSomething() async {
        try? await Task.sleep(for: .seconds(2))
        
        let item = "something 1: \(Thread.current)"
        
        await MainActor.run {
            self.data.append(item)
            
            let item2 = "something 2: \(Thread.current)"
            self.data.append(item2)
        }
    }
}

struct ContentView: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.data, id: \.self) { data in
                Text(data)
                    .foregroundColor(data.contains("title") ? .blue : .red)
            }
        }
        .onAppear {
//            viewModel.addTitle1()
//            viewModel.addTitle2()
//            viewModel.addTitle3()
            
            Task {
//                await viewModel.addAuthor1()
//                await viewModel.addAuthor2()
//                await viewModel.addAuthor3()
                await viewModel.doSomething()
                await viewModel.addSomething()
                
                viewModel.data.append("final text: \(Thread.current)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
