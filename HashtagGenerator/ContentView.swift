//
//  ContentView.swift
//  HashtagGenerator
//
//  Created by Krish Vijayan on 2023-05-30.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @State var imageNum = 0
    @State var animalClassification = ""
    @State var hashtag = ""
    var body: some View {
        VStack {
            Button(action: nextAnimal){
                Text("Next Animal")
            }
            //Animal photo array
            AsyncImage(url: URL(string: Images.images[imageNum]))
            { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 250, height: 250)
            Text(animalClassification)
            Text(hashtag)
        }
        .padding()
        .onAppear{
            detectAnimal(image: Images.images[imageNum])
        }
    }
    func nextAnimal() {
        imageNum += 1
        if imageNum >= Images.images.count {
            imageNum = 0
        }
        detectAnimal(image: Images.images[imageNum])
    }

func detectAnimal(image: String) {
    guard let model = try? VNCoreMLModel(for: AnimalClassifier().model) else {fatalError("Loading CoreML Model Failed")}
    let request = VNCoreMLRequest(model: model){(request, error) in
        guard let results = request.results as? [VNClassificationObservation] else {return}
        
        if let firstResult = results.first {
            
            animalClassification = firstResult.identifier
            //Match animal with hashtag
            for hashtag in Hashtags.hashtags{
                if (hashtag.contains(animalClassification)){
                    print(hashtag)
                    self.hashtag = hashtag
                }
            }
            print(animalClassification)
            
        }
    }
    if let url = URL(string: image) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Error handling...
            guard let imageData = data else { return }
            guard let ciImage = CIImage(data: imageData) else {fatalError("Cannot convert to CIImage")}
            
            DispatchQueue.main.async {
                
                let handler = VNImageRequestHandler(ciImage: ciImage)
                
                do{
                    try handler.perform([request])
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
    
}

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
