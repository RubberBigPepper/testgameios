//
//  GameViewController.swift
//  testgame
//
//  Created by Albert on 14.09.2020.
//  Copyright © 2020 Albert. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var ship: SCNNode!
    
    var duration: TimeInterval = 5
    
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    var extraShip: SCNNode?{
        get{
            return scene.rootNode.childNode(withName: "ship", recursively: true)
        }
    }
    func removeExtraShip(){
        extraShip?.removeFromParentNode()
    }
    
    func spawnShip(){
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
        scene.rootNode.addChildNode(ship)
        
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = Int.random(in: -200 ... -50)
        
        ship.position = SCNVector3(x, y, z )
        
        let lookAtPos = SCNVector3(2*x, 2 * y, 2 * z)
        ship.look(at: lookAtPos)
            
        let duration = self.duration * Double(z) / 100.0
        ship.runAction(SCNAction.move(to: SCNVector3(x:0, y:0, z: -10), duration: duration)){
            
        }
        self.duration *= 0.9
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeExtraShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        //ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        //ship.position=SCNVector3(x: 0, y:0, z: -30)
        // animate the 3d object
     //  ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        spawnShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
               self.ship.removeAllActions()
               self.removeExtraShip()
               self.spawnShip()
                               
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
