//
//  ViewController.swift
//  ARKit+ReplayKit
//
//  Created by Santosh Guruju | MACROKIOSK on 12/03/18.
//  Copyright © 2018 workstreak. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate {
    
    let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    
    var buttonWindow = UIWindow()
    
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    //add buttons to a new window
    
    func addButtons( button1: UIButton) {
        self.buttonWindow = UIWindow(frame: self.view.frame)
        self.buttonWindow.rootViewController = HiddenStatusBarViewController()
        self.buttonWindow.rootViewController?.view.addSubview(button1)
        self.buttonWindow.rootViewController?.view.updateConstraintsIfNeeded()
        self.buttonWindow.makeKeyAndVisible()
        
    }
    
    @IBAction func videoButtonAction(_ sender: Any) {
        
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        
        DispatchQueue.main.async {
            // Update UI
            self.addButtons(button1: self.videoButton)
            
            
        }
        
        self.videoButton.tintColor = .red
        
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            self.videoButton.tintColor = .white
            return
        }
        recorder.isMicrophoneEnabled = true
        recorder.startRecording{ [unowned self] (error) in
            guard error == nil else {
                print("There was an error starting the recording.")
                self.videoButton.tintColor = .white
                return
            }
            
            print("Started Recording Successfully")
            self.isRecording = true
            
        }
        
    }
    
    func stopRecording() {
        
        self.videoButton.tintColor = .white
        recorder.stopRecording { [unowned self] (preview, error) in
            print("Stopped recording")
            
            
            guard preview != nil else {
                print("Preview controller is not available.")
                return
            }
            
            let alert = UIAlertController(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                self.recorder.discardRecording(handler: { () -> Void in
                    print("Recording suffessfully deleted.")
                    
                })
            })
            
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                preview?.previewControllerDelegate = self.buttonWindow.rootViewController as? RPPreviewViewControllerDelegate
                self.buttonWindow.rootViewController?.present(preview!, animated: true, completion: nil)
            })
            
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            //            self.buttonWindow.rootViewController?.present(alert, animated: true, completion: nil)
            
            self.isRecording = false
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            //            self.buttonWindow.rootViewController = rootController
            
            
            let app = UIApplication.shared
            app.keyWindow?.rootViewController = rootController
            rootController.present(alert, animated: true, completion: nil)
            
            
        }
        
        
        
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
        
        //        self.view.becomeFirstResponder()
    }
    
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
