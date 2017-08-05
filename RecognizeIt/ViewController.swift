//
//  ViewController.swift
//  RecognizeIt
//
//  Created by Sviatoslav Fil on 05/08/2017.
//  Copyright © 2017 Sviatoslav Fil. All rights reserved.
//

import Foundation
import Photos
import UIKit

class ViewController: UIViewController {

    var imageView: UIImageView!
    var label: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initCameraPermissions()
        self.initUI()
    }
    
    func initUI()
    {
        initImageView()
        initLabel()
        initCameraButton()
    }
    
    func initImageView()
    {
        let size = CGSize(width: self.view.frame.size.width * 0.5, height: self.view.frame.size.width * 0.5)
        let origin = CGPoint(x: (self.view.frame.origin.x + self.view.frame.size.width - size.width) / 2, y: (self.view.frame.origin.y + self.view.frame.size.height - size.width) / 2)
        let frame = CGRect(origin: origin, size: size)
        
        self.imageView = UIImageView(frame: frame)
        self.imageView.backgroundColor = UIColor.gray
        self.view.addSubview(self.imageView)
    }
    
    func initLabel()
    {
        let size = CGSize(width: self.view.frame.size.width, height: 100)
        let origin = CGPoint(x: (self.view.frame.origin.x + self.view.frame.size.width - size.width) / 2, y: (self.view.frame.origin.y + self.view.frame.size.height - size.height))
        let frame = CGRect(origin: origin, size: size)
        
        label = UILabel(frame: frame)
        label.textAlignment = .center
        
        self.view.addSubview(label)
    }
    
    func initCameraButton()
    {
        let size = CGSize(width: 100, height: 50)
        let origin = CGPoint(x: (self.view.frame.origin.x + self.view.frame.size.width - size.width) / 2, y: (self.view.frame.origin.y + self.view.frame.size.height - size.height) / 1.25)
        let frame = CGRect(origin: origin, size: size)
        
        let button = UIButton(frame: frame)
        button.setTitle("Recognize", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.green, for: .highlighted)
        
        button.addTarget(self, action: #selector(self.cameraButtonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func cameraButtonTapped(sender: UIButton)
    {
        let imagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        }
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func initCameraPermissions()
    {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized
            {
                /* do stuff here */
                debugPrint("Access granted")
            }
            else
            {
                self.presentAlertController(withTitle: "Access denied",
                                            message: "You need to turn it on manualy!")
                debugPrint("Access denied")
            }
        })
    }
    
    func process(_ image: UIImage)
    {
        imageView.image = image
        
        guard let pixelBuffer = image.pixelBuffer else
        {
            return
        }
        
        let model = Inceptionv3()
        
        do
        {
            let output = try model.prediction(image: pixelBuffer)
            let probs = output.classLabelProbs.sorted { $0.value > $1.value }
            
            if let prob = probs.first
            {
                label.text = "It's \(prob.key) \(round(prob.value * 100))%"
                self.presentAlertController(withTitle: "Fil's recognizer detect", message: "\(prob.key)")
            }
        }
        catch
        {
            self.presentAlertController(withTitle: title, message: error.localizedDescription)
        }
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else
        {
            return
        }
        process(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}

