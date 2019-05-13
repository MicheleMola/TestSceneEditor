//
//  ViewController.swift
//  TestSceneEditor
//
//  Created by Michele Mola on 5/13/19.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  
  let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
    ".serialSceneKitQueue")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    // Create a new scene
    let scene = SCNScene()
    
    // Set the scene to the view
    sceneView.scene = scene
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
      fatalError("Missing expected asset catalog resources.")
    }
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.detectionImages = referenceImages
    
    // Run the view's session
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  // MARK: - ARSCNViewDelegate
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    guard let imageAnchor = anchor as? ARImageAnchor else { return }
    let referenceImage = imageAnchor.referenceImage
    updateQueue.async {
      
      // Create a plane to visualize the initial position of the detected image.
      let plane = SCNPlane(width: referenceImage.physicalSize.width,
                           height: referenceImage.physicalSize.height)
      let planeNode = SCNNode(geometry: plane)
//      planeNode.opacity = 0.25
      
      let scene = SCNScene(named: "art.scnassets/ship.scn")!
      let planeFromScene = scene.rootNode.childNode(withName: "plane", recursively: true)!
      
      
      planeFromScene.scale = SCNVector3(referenceImage.physicalSize.width, referenceImage.physicalSize.height, 1)
      
//      let boundingBox = planeFromScene.boundingBox
//      var xSize = boundingBox.max.x - boundingBox.min.x
//      let ySize = boundingBox.max.y - boundingBox.max.y
//
//      xSize = Float(referenceImage.physicalSize.width)
//
//      print("here")
      
      

      /*
       `SCNPlane` is vertically oriented in its local coordinate space, but
       `ARImageAnchor` assumes the image is horizontal in its local space, so
       rotate the plane to match.
       */
      planeFromScene.eulerAngles.x = -.pi / 2
      
      /*
       Image anchors are not tracked after initial detection, so create an
       animation that limits the duration for which the plane visualization appears.
       */
      //planeNode.runAction(self.imageHighlightAction)
      
      // Add the plane visualization to the scene.
      node.addChildNode(planeFromScene)
    }
    
  }
  
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
