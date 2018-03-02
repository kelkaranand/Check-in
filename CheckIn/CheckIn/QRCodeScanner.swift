//
//  QRCodeScanner.swift
//  CheckIn
//
//  Created by Anand Kelkar on 15/02/18.
//

import Foundation

import UIKit
import AVFoundation
import CoreData

class QRScannerController: UIViewController {
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 5
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //Experimental code to get directory and get image
    
    func getDirectoryPath() -> String {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        let documentsDirectory = path
        return documentsDirectory
    }
    
    func getImage(id: String) -> UIImage{
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(id+".jpg")
        if fileManager.fileExists(atPath: imagePAth){
            return UIImage(contentsOfFile: imagePAth)!
        }else{
            print("No Image")
        }
        print("Default image")
        return UIImage(named:"default")!
    }
    
    
    //End Experimental code
    
    //Shows the alert pop up when QRCode is scanned
    func showAlert(id: String) {
        
        //Find student record by APS ID
        var student : [NSManagedObject]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        fetchRequest.predicate = NSPredicate(format: "studentId == %@", id)
        
        
        do {
            student = try managedContext.fetch(fetchRequest)
            
            if(student.isEmpty)
            {
                let invalidQrAlert = UIAlertController(title:"No record found", message:"No record was found for the scanned code. Try using the manual search", preferredStyle: .alert)
                invalidQrAlert.addAction(UIAlertAction(title:"OK", style: .cancel, handler:nil))
                self.present(invalidQrAlert, animated:true)
            }
            else{
                
            //Fields and labels
            let studentRecord=student.first
            let fname=studentRecord?.value(forKey:"firstName") as! String
            let lname=studentRecord?.value(forKey:"lastName") as! String
            let sname=studentRecord?.value(forKey:"school") as! String
            let media=studentRecord?.value(forKey:"media") as! String
            let id=studentRecord?.value(forKey:"studentId") as! String
            let flabel="First Name: "
            let llabel="Last Name: "
            let ilabel="APS ID: "
            let mlabel="Media Waiver: "
            let slabel="School Name: "
            let nextLine="\n"
            
            //Create alert on screen
            let alert = UIAlertController(title: "Record Found", message: nextLine+ilabel+id+nextLine+flabel+fname+nextLine+llabel+lname+nextLine+slabel+sname+nextLine+nextLine+mlabel+media, preferredStyle: .alert)
            
            //Show image by retrieving from directory
            let profilePicture = UIAlertAction(title: "", style: .default, handler: nil)
            profilePicture.setValue(self.getImage(id: id).withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
            alert.addAction(profilePicture)
                
                
            alert.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = "Number of Guests"
                })
                
            alert.addAction(UIAlertAction(title: "Check-in", style: .default, handler:
                {
                    (alertAction: UIAlertAction) in
                    //Code after Check-in is pressed
                    //Check if media waiver is not accepted and show alert as required
                    var guests:String=alert.textFields![0].text!
                    if(guests.isEmpty)
                    {
                        guests="0"
                    }
                    self.checkMediaWaiver(indicator: media, id:id, fname:fname, lname:lname, guests: guests)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
            }
            
        } catch _ as NSError {
            print ("Could not fetch data")
        }
    }
    
    //Function to check if media waiver has been accepted
    func checkMediaWaiver(indicator: String, id:String, fname: String, lname: String, guests: String)
    {
        //If media waiver is not accepted, display alert
        if indicator=="N"
        {
            let mediaAlert = UIAlertController(title:"Media Waiver not accepted", message:"The student is yet to accept the media waiver!", preferredStyle: .alert)
            
            
            //Make Check in call once accepted
            mediaAlert.addAction(UIAlertAction(title:"Accepted", style: .default, handler: {(alert:UIAlertAction) in
                self.checkInStudent(id: id, fname: fname, lname: lname, guests:guests)
            }))
            self.present(mediaAlert, animated: true)
        }
        //If media waiver is accepted, proceed with check-in
        else{
            self.checkInStudent(id: id, fname:fname, lname:lname, guests:guests)
        }
    }
    
    
    //Function to complete the check in
    func checkInStudent(id: String, fname: String, lname: String, guests:String)
    {
        let space=" "
        let successlabel="Successfully checked in "
        
        //Write to local data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CheckedInStudent", in: managedContext)
        let checkedStudent = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        checkedStudent.setValue(id, forKey: "id")
        checkedStudent.setValue("Y", forKey: "media")
        if(!guests.isEmpty){
        checkedStudent.setValue(guests, forKey: "guests")
        }
        do{
            try managedContext.save()
        }
        catch _ as NSError{
            print("Could not check-in student")
        }
        //Print final success message
        let successAlert=UIAlertController(title:"Success", message:successlabel+fname+space+lname , preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
        self.present(successAlert, animated: true)
    }
    
    
    
    
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                showAlert(id:metadataObj.stringValue!)
            }
        }
    }
    
}
