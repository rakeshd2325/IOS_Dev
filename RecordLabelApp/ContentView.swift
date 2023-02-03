//
//  ContentView.swift
//  RecordLabelApp
//
//  Created by Rui Alho on 15/10/20.
//

import SwiftUI

struct ContentView: View {
    @State private var results = Dictionary<String, [BandsViewModel]>()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            
            if let errorMessage = errorMessage {
                VStack(alignment: .center) {
                    Text(errorMessage).padding()
                    Button("Retry") {
                        loadData()
                    }.padding()
                }
            } else {
                List {
                    ForEach(results.keys.sorted(), id: \.self) { key in
                        VStack(alignment: .leading) {
                            Text("\(key)").font(.headline)
                            if let models = results[key] {
                                ForEach(models, id: \.self) { model in
                                    let festival = model.festival ?? "Unknown"
                                    Text("\(festival)").padding(.leading).font(Font.subheadline.weight(.semibold))
                                }
                            }
                            
                        }
                    }
                }
                if isLoading {
                    ActivityIndicator(isAnimating: isLoading) {
                        $0.color = .black
                        $0.hidesWhenStopped = false
                        $0.style = .large
                    }
                }
            }
        }.onAppear(perform: loadData)
        
    }
    
    func loadData() {
        self.isLoading = true
        errorMessage = nil
        FestivalsServiceAPI.shared.fetchFestivals(from: .festivals) { (result: Result<[MusicFestival], FestivalsServiceAPI.APIServiceError>) in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    // update our UI
                    self.results = mapViewModel(festivals:response)
                }
            case .failure(let error):
                switch error {
                case .throttle(let errorString):
                    DispatchQueue.main.async {
                        // update our UI
                        errorMessage = errorString
                    }
                default:
                    DispatchQueue.main.async {
                        // update our UI
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    struct ActivityIndicator: UIViewRepresentable {
        
        typealias UIView = UIActivityIndicatorView
        var isAnimating: Bool
        fileprivate var configuration = { (indicator: UIView) in }
        
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
            isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
            configuration(uiView)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
