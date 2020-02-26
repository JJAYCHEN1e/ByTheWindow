//
//  ViewController.swift
//  abc
//
//  Created by 项慕凡 on 2020/2/24.
//  Copyright © 2020 项慕凡. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        //begin
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // draw view in that context.
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        // get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil {
            return image!
        }
        return UIImage()
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var grids = [Grid]()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var image:UIImage?
    
    var paintingNode:SCNNode?
    var selectedNode: SCNNode?
    
    @IBAction func takeShot(_ sender: Any) {
        image = sceneView.takeScreenshot()
        imageView.image = image
        cancelBtn.isHidden = false
        imageView.isHidden = false
        share()
    }
    
    @IBAction func showShare(_ sender: UITapGestureRecognizer) {
        share()
    }
    
  
    @IBAction func changePositon(_ sender: UILongPressGestureRecognizer) {
        guard let recognizerView = sender.view as? ARSCNView else {
            return
        }
        let touch = sender.location(in: recognizerView)
        
        if sender.state == .began {
            let hitTestResult = self.sceneView.hitTest(touch, options: [SCNHitTestOption.categoryBitMask: 2])
            guard let hitNode = hitTestResult.first?.node else { return }
            self.selectedNode = hitNode
        } else if sender.state == .changed {
        // make sure a node has been selected from .began
        guard let hitNode = self.selectedNode else { return }

        // perform a hitTest to obtain the plane
        let hitTestPlane = self.sceneView.hitTest(touch, types: .existingPlane)
        guard let hitPlane = hitTestPlane.first else { return }
        hitNode.position = SCNVector3(hitPlane.worldTransform.columns.3.x,
                                       hitNode.position.y,
                                       hitPlane.worldTransform.columns.3.z)
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed{

            guard self.selectedNode != nil else { return }

            // Undo selection
            self.selectedNode = nil
        }
    }
    
    
    @IBAction func changeScale(_ sender: UIPinchGestureRecognizer) {
        guard let recognizerView = sender.view as? ARSCNView else {
            return
        }
        let touch = sender.location(in: recognizerView)
        
        if sender.state == .began {
            let hitTestResult = self.sceneView.hitTest(touch, options: [SCNHitTestOption.categoryBitMask: 2])
            guard let hitNode = hitTestResult.first?.node else { return }
            self.selectedNode = hitNode
        } else if sender.state == .changed {
        // make sure a node has been selected from .began
            guard let hitNode = self.selectedNode else { return }
            let scale = sender.scale
            let o = hitNode.scale
            hitNode.scale = SCNVector3(o.x * (1 + Float(scale)), o.y * (1 + Float(scale)), o.z * (1 + Float(scale)))
            
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed{

            guard self.selectedNode != nil else { return }

            // Undo selection
            self.selectedNode = nil
        }
        
    }
    
    
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
        let popOver = activityVC.popoverPresentationController
        popOver?.sourceView = imageView
        
        present(activityVC, animated: true, completion: nil)
    }

    @IBAction func cancelImage(_ sender: Any) {
        imageView.image = nil
        image = nil
        cancelBtn.isHidden = true
        imageView.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelBtn.isHidden = true
        imageView.isHidden = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        let showShareTap = UITapGestureRecognizer(target: self, action: #selector(showShare(_:)))
        imageView.isUserInteractionEnabled = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(changePositon(_:)))
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(changeScale(_:)))
        
        sceneView.addGestureRecognizer(gestureRecognizer)
        imageView.addGestureRecognizer(showShareTap)
        sceneView.addGestureRecognizer(longPress)
        sceneView.addGestureRecognizer(pinch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            }.first

        guard let foundGrid = grid else {
            return
        }

        foundGrid.update(anchor: planeAnchor)
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)

        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)

        // Get hitTest results and ensure that the hitTest corresponds to a grid that has been placed on a wall
        guard let hitTest = hitTestResults.first, let anchor = hitTest.anchor as? ARPlaneAnchor, let gridIndex = grids.firstIndex(where: { $0.anchor == anchor }) else {
            return
        }
        if paintingNode == nil {
            return
        }
        addPainting(hitTest, grids[gridIndex])
    }
    
    func addPainting(_ hitResult: ARHitTestResult, _ grid: Grid) {
        
        let planeGeometry = SCNPlane(width: 0.2, height: 0.35)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "mona-lisa")
        planeGeometry.materials = [material]

        
        paintingNode = SCNNode(geometry: planeGeometry)
        paintingNode!.transform = SCNMatrix4(hitResult.anchor!.transform)
        paintingNode!.eulerAngles = SCNVector3(paintingNode!.eulerAngles.x + (-Float.pi / 2), paintingNode!.eulerAngles.y, paintingNode!.eulerAngles.z)
        paintingNode!.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(paintingNode!)
        grid.removeFromParentNode()
    }
    
    func removePainting() {
        paintingNode?.removeFromParentNode()
    }
}
