//
//  BarcodeViewController.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 22/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import UIKit
import AVFoundation


// TODO: Delegate not required, use unwind Segue
protocol BarcodeViewControllerDelegate {
    
    func barcodeCaptured(barcode: String)
    
}

class BarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate: BarcodeViewControllerDelegate?    // TODO: Remove unused... replaced by unwindSegue
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barcodeFrameView: UIView?
    
    let supportedBarcodes = [AVMetadataObjectTypeQRCode]
    
    var scannedBarcode: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as AVCaptureInput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarcodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Initialize Barcode Frame to highlight the barcode
            barcodeFrameView = UIView()
            
            if let barcodeFrameView = barcodeFrameView {
                barcodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                barcodeFrameView.layer.borderWidth = 2
                view.addSubview(barcodeFrameView)
                view.bringSubviewToFront(barcodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            
            
            // TODO: Handle error, pass to unwindSegue for Alert
            
            // MARK: HARDCODED DUMMY SCAN
            scannedBarcode = "4" //"P50715PGD1"
//            if let callback = delegate {
//                callback.barcodeCaptured("P50715PGD1")
//            }
            // END ----------------------
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if scannedBarcode != nil {
//            dismissViewControllerAnimated(true, completion: nil)
            performSegueWithIdentifier("unwindToEnrolments", sender: nil)
        }
        
    }
    
    
    // MARK: - Caputure Delegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Already captured?
        guard scannedBarcode == nil else {
            return
        }
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            barcodeFrameView?.frame = CGRectZero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarcodes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barcodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            barcodeFrameView?.frame = barcodeObject!.bounds
            
            if metadataObj.stringValue != nil {
//                print(metadataObj.stringValue)
//                
//                if let callback = delegate {
//                    callback.barcodeCaptured(metadataObj.stringValue)
//                }
//                
//                dismissViewControllerAnimated(true, completion: nil)
                scannedBarcode = metadataObj.stringValue
                performSegueWithIdentifier("unwindToEnrolments", sender: nil)
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
