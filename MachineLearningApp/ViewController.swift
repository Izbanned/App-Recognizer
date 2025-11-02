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
    private lazy var visionModel: VNCoreMLModel? = {
        do {
            return try VNCoreMLModel(for: Inceptionv3().model)
        } catch {
            showAlert(title: "Model Error", message: "Unable to load the classification model.")
            return nil
        }
    }()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.allowsEditing = false

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            guard let CIImage = CIImage(image: image) else {
                showAlert(title: "Image Error", message: "The selected image could not be processed.")
                return
            }
            detect(image: CIImage)
        }
        imagePicker.dismiss(animated: true)
    }



    func detect(image: CIImage) {
        guard let model = visionModel else { return }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let self = self else { return }
            guard let result = request.results as? [VNClassificationObservation],
                  let firstResult = result.first else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Classification Error", message: "Unable to classify the selected image.")
                }
                return
            }

            DispatchQueue.main.async {
                self.navigationItem.title = firstResult.identifier
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            showAlert(title: "Processing Error", message: "There was a problem analyzing the image.")
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable", message: "This device does not support camera capture.")
            return
        }
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @IBAction func photoTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }


}

extension ViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            guard self.presentedViewController == nil else { return }
            self.present(alert, animated: true)
        }
    }
}

