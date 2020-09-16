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
    
    //тут аутлеты на элементы сториборды
    @IBOutlet weak var viewScene: SCNView!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var btnNewGame: UIButton!
    
    var scores: Int = 0{//очки за сбитые корабли
        didSet{
            self.labelScore.text="Очки: \(self.scores)" // сразу обновим на экране, нужды в main UI нет - didSet итак всегда в main UI thread
        }
    }
    
    var tapGesture : UITapGestureRecognizer!//это распознаватель жестов
    
    var ship: SCNNode! //собственно наш корабль
    
    var duration: TimeInterval = 10 //длительность анимации, она же скорость полета (обратная)
    
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    var extraShip: SCNNode?{
        get{//поиск корабля в графе узлов
            return scene.rootNode.childNode(withName: "ship", recursively: true)
        }
    }
    
    func removeNode(_ node: SCNNode?){//удаление объекта и его анимации
        node?.removeFromParentNode()
        node?.removeAllActions()
    }
    
    func spawnShip(){
        //создаем новый экземпляр корабля и добавляем его на сцену
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        scene.rootNode.addChildNode(ship)
        
        //задаем координаты корабля - каждый раз новые
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = Int.random(in: -140 ... -70)
        
        ship.position = SCNVector3(x, y, z )
        
        //чтобы нос корабля был направлен на нас - зададим поворот всего корабля в камеру
        let multipler = 3
        ship.look(at: ship.position * multipler)
            
        //высчитаем скорость полета
        let duration = -self.duration * Double(z) / 100.0
        ship.runAction(SCNAction.move(to: SCNVector3(x:0, y:0, z: -10), duration: duration)){
            //если анимация закончилась - значит корабль долетел до места - игра окончена
            self.removeNode(self.ship)
            DispatchQueue.main.async {//некоторые вещи требуют вызов в main UI потоке
                self.viewScene?.removeGestureRecognizer(self.tapGesture)
                self.labelScore.text="Игра окончена\nОчки: \(self.scores)"
                self.btnNewGame.isHidden=false//кнопка перезапуска игры, покажем
            }
        }
        //будем увеличивать скорость с каждой новой генерацией
        self.duration *= 0.95
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareGame()//после загрузки подготовим сцену
    }
    
    private func prepareGame(){
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
        
        // retrieve the SCNView
        let scnView = self.viewScene!

        // set the scene to the view
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = !true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        // configure the view
        scnView.backgroundColor = UIColor.black
        removeNode(extraShip)//удаляем лишнее
    }
    
    //лучше в отдельной функции - проще будет потом перезапускать игру
    private func startNewGame(){
        self.scores=0//ставим очки в 0
        
        btnNewGame.isHidden=true //прячем кнопку, чтобы не мешалась

        // add a tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        viewScene?.addGestureRecognizer(tapGesture)
        
        spawnShip()//добавляем корабль на сцену - игра началась
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.viewScene!
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
            SCNTransaction.animationDuration = 0.1
            
            // после того как красным покажется - удаляем корабль, создаем новую цель и увеличим очки
            SCNTransaction.completionBlock = {
                self.removeNode(self.ship)
                self.scores+=10
                self.spawnShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    @IBAction func btnNewGamePressed(_ sender: Any) {
        startNewGame()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //надо запомнить на будущее - как управлять возможными ориентациями, в зависимости от модели устройства
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
