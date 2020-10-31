//
//  WildlifeClassifyViewController.swift
//  Wildify
//
//  Created by ANUBHAV DAS on 31/10/20.
//  Copyright © 2020 Captain Anubhav. All rights reserved.
//WildlifeClassifyViewController

import UIKit
import AVKit
import Vision

class WildlifeClassifyViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    

    @IBOutlet weak var cameraView: UIView!

    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var wildLable: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.staringTheCam()
    }
    
    //MARK: - Starting the camera
    
    func staringTheCam() {
        
        //Set session preset
        captureSession.sessionPreset = .hd4K3840x2160
        
        //Capturing Device
        guard let capturingDevice = AVCaptureDevice.default(for: .video) else { return }
        
        //Capture Input
        guard let capturingInput = try? AVCaptureDeviceInput(device: capturingDevice) else { return }
        
        //Adding input to capture session
        captureSession.addInput(capturingInput)

        //Data output
        let cameraDataOutput = AVCaptureVideoDataOutput()
        cameraDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "outputVideo"))
        captureSession.addOutput(cameraDataOutput)
        
        //Construct a camera preview layer
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Set the frame
        cameraPreviewLayer.frame = cameraView.bounds
        
        //Add this preview layer to sublayer of view
        cameraView.layer.addSublayer(cameraPreviewLayer)
        
        //Start the session
        captureSession.startRunning()
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension WildlifeClassifyViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            
            //Get pixel buffer
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
                
            }
            
            //get model
            guard let resNetModel = try? VNCoreMLModel(for: WildlifeClassifier_1().model) else { return }
            
            //Create a coreml request
            let requestCoreML = VNCoreMLRequest(model: resNetModel) { (vnReq, err) in
                
                //handling error and request
                
                DispatchQueue.main.async {
                    if err == nil{
                        
                        
                        
                        guard let capturedRes = vnReq.results as? [VNClassificationObservation] else { return }
                        
                        guard let firstObserved = capturedRes.first else { return }
                        
                        print(firstObserved.identifier, firstObserved.confidence)
                      
                        
                        if firstObserved.identifier.contains(" Amphibian"){
                            
                            
                            self.wildLable.backgroundColor = .red
                            self.wildLable.text = String(format: "Amphibian")
                            self.wildLable.textColor = .blue
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                            
                        }
                        if firstObserved.identifier.contains(" Invertebrate") {
                            
                            self.wildLable.backgroundColor = .red
                            self.wildLable.text = String(format: "Invertebrate")
                            self.wildLable.textColor = .white
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                        }
                        if firstObserved.identifier.contains(" Reptile") {
                            
                            self.wildLable.backgroundColor = .orange
                            self.wildLable.text = String(format: "Reptile")
                            self.wildLable.textColor = .black
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                        }
                        if firstObserved.identifier.contains("Bird") {
                            
                            self.wildLable.backgroundColor = .cyan
                            self.wildLable.text = String(format: "Bird")
                            self.wildLable.textColor = .blue
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                        }
                        if firstObserved.identifier.contains("Bug") {
                            
                            self.wildLable.backgroundColor = .green
                            self.wildLable.text = String(format: "Plants and Fungi")
                            self.wildLable.textColor = .black
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                        }
                        if firstObserved.identifier.contains("Fish") {
                            
                            
                            self.wildLable.backgroundColor = .brown
                            self.wildLable.text = String(format: "Fish")
                            self.wildLable.textColor = .yellow
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                        }
                        if firstObserved.identifier.contains("Mammal") {
                            
                            self.wildLable.backgroundColor = .black
                            self.wildLable.textColor = .white
                            self.wildLable.text = String(format: "Mammal")
                            self.accuracy.text = String(format: "%.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                        }
                        
                    }
                    
                }
                
            }
            
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestCoreML])
            
        }
        
        
        
    }



