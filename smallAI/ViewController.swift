//
//  ViewController.swift
//  smallAI
//
//  Created by JiangYe on 8/7/17.
//  Copyright © 2017 JiangYe. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false 
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image:userPickedImage) else{
                fatalError("Can not convert into CIImage")
            }
            // call detect image
            detect(image:ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image:CIImage){
        // load up model
        guard let model = try? VNCoreMLModel(for: inceptioniv3().model) else{
            fatalError("Loarding coreML model failed")
        }
        
        // create model to ask model
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                faltalError("model failed to process image")
            }
            // get the first result
            if let firstResult = results.first{
                // let the navigation bar title change to this item name predict by our model
                let itemName = firstResult.identifier as! String
                self.navigationItem.title = "it is a "+itemName
            }
        }
        // create handler to handle this request
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perfrom([request])
        }
        catch{
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

