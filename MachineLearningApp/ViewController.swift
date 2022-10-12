//
//  ViewController.swift
//  MachineLearningApp
//
//  Created by Dias Karimov on 23.09.2022.
//

import UIKit
import CoreML
import Vision
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var PhotLibrary: UIBarButtonItem!

    let imagePicker = UIImagePickerController()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.allowsEditing = false

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let image = info[UIImagePickerController.InfoKey.originalImage] as?  UIImage {
            imageView.image = image
            guard let CIImage = CIImage(image: image) else {
                fatalError("CIImage error")
            }
            detect(image: CIImage)
            
            
        }
        imagePicker.dismiss(animated: true)
    }
    
    
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {  fatalError("Model error") }
        
         let request = VNCoreMLRequest(model: model) { (request, error) in
             guard  let result = request.results as? [VNClassificationObservation] else {  fatalError("result error")
                 
             }
            
             let firstResult = result.first?.identifier
                 self.navigationItem.title = firstResult
             
      }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print("Error")
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @IBAction func photoTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    
}

