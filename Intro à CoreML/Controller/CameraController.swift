//
//  CameraController.swift
//  Intro à CoreML
//
//  Created by Matthieu PASSEREL on 02/08/2018.
//  Copyright © 2018 Matthieu PASSEREL. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {

    @IBOutlet weak var cameraVue: UIView!
    
    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var position = AVCaptureDevice.Position.back
    
    var imagePicker = UIImagePickerController()
    var imageChoisie: UIImage?
    
    let segueID = "CoreML"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }
    
    func setupCamera() {
        previewLayer?.removeFromSuperlayer()
        
        captureSession = AVCaptureSession()
        guard captureSession != nil else { return }
        guard let appareil = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: position) else { return }
        do  {
            let input = try AVCaptureDeviceInput(device: appareil)
            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
                capturePhotoOutput = AVCapturePhotoOutput()
                guard capturePhotoOutput != nil  else { return }
                if captureSession!.canAddOutput(capturePhotoOutput!) {
                    captureSession!.addOutput(capturePhotoOutput!)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                    previewLayer?.videoGravity = .resizeAspectFill
                    previewLayer?.connection?.videoOrientation = .portrait
                    previewLayer?.frame = cameraVue.bounds
                    guard previewLayer != nil else { return }
                    cameraVue.layer.addSublayer(previewLayer!)
                    captureSession!.startRunning()
                }
            }
        } catch {
            print("Erreur -> \(error.localizedDescription)")
        }
    }
    
    @IBAction func prendrePhoto(_ sender: Any) {
        guard capturePhotoOutput != nil else { return }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.previewPhotoFormat = photoSettings.embeddedThumbnailPhotoFormat
        capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func versLibrary(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func rotateCamera(_ sender: Any) {
        switch position {
        case .back: position = .front
        default: position = .back
        }
        setupCamera()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            if let vc = segue.destination as? CoreMLController {
                vc.image = sender as? UIImage
            }
        }
    }
}

extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageChoisie = image
        }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: self.segueID, sender: self.imageChoisie)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let erreur = error {
            print("Erreur: \(erreur.localizedDescription)")
        }
        
        if let data = photo.fileDataRepresentation() {
            imageChoisie = UIImage(data: data)
            performSegue(withIdentifier: segueID, sender: imageChoisie)
        } else {
            print("Erreur: le résultat ne m'a pas donné de Data")
        }
    }
}
