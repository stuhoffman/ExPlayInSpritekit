//
//  GameScene.swift
//  PlayAround
//
//  Created by Stuart Hoffman on 2/26/17.
//  Copyright © 2017 Stuart Hoffman. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32 {
    case player = 1
    case building = 2
    case castle = 4
    // powers of 2. 8, 16...
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var thePlayer:SKSpriteNode = SKSpriteNode()
    var moveSpeed:TimeInterval = 1
    let swipeRightRec:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    let swipeLeftRec:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    let swipeUpRec:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    let swipeDownRec:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    let rotateRec:UIRotationGestureRecognizer = UIRotationGestureRecognizer()
    let tapRec:UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        /* 
         self.physicsWorld.gravity = CGVector(dx: 1, dy: 0)
        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 2
        tapRec.numberOfTapsRequired = 3
        self.view!.addGestureRecognizer(tapRec)
        
        rotateRec.addTarget(self, action: #selector(GameScene.rotatedView (_:) ))
        self.view!.addGestureRecognizer(rotateRec)
        */
        swipeRightRec.addTarget(self, action: #selector(GameScene.swipeRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        swipeLeftRec.addTarget(self, action: #selector(GameScene.swipeLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipeUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipeDown) )
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)

        
        if let somePlayer:SKSpriteNode = self.childNode(withName: "Player") as? SKSpriteNode {
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            //for pushing the buildings
            //thePlayer.physicsBody?.collisionBitMask = BodyType.building.rawValue | BodyType.somethingElse.rawValue
            //zero collision with buildings
            thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue
            thePlayer.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue
            
        }
        
        for node in self.children {
            if (node.name == "Building") {
                if (node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    print ("Found a building")
                }
            }
            if let aCastle:Castle = node as? Castle {
                aCastle.setUpCastle()
                aCastle.dudesInCastle = 5
            }
        }
    }
    
    //MARK: ========= Gesture Recognizers
    func swipeRight() {
        print("Right")
        move(theXAmount: 100, theYAmount: 0, theAnimation: "WalkRight")
    }
    
    func swipeLeft() {
        print("Left")
        move(theXAmount: -100, theYAmount: 0, theAnimation: "WalkLeft")
    }
    
    func swipeUp() {
        print("Up")
        move(theXAmount: 0, theYAmount: 100, theAnimation: "WalkBack")
    }
    
    func swipeDown() {
        print("Down")
        move(theXAmount: 0, theYAmount: -100, theAnimation: "WalkFront")
    }

    func tappedView() {
            print("Tapped three times")
    }
    
    func cleanUp() {
        //only call when switching scenes. like to home etc
        for gesture in (self.view?.gestureRecognizers)! {
            self.view?.removeGestureRecognizer(gesture)
        }
    }
    
    func rotatedView(_ sender:UIRotationGestureRecognizer) {
        if (sender.state == .began) {
            print("rotation began")
        }
        if (sender.state == .changed) {
            print("rotation changed")
            let rotateAmount = Measurement(value: Double(sender.rotation), unit: UnitAngle.radians).converted(to: .degrees).value
            print("Rad = \(sender.rotation), Deg = \(rotateAmount)")
            
            thePlayer.zRotation = -sender.rotation
        }
        if (sender.state == .ended) {
            print("rotation ended")
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for node in self.children {
            if (node.name == "Building") {
                if (node.position.y > thePlayer.position.y){
                    node.zPosition = -100
                } else {
                    node.zPosition = 100
                }
                node.physicsBody?.categoryBitMask = BodyType.building.rawValue
            }
        }
        
    }
    
    func move(theXAmount:CGFloat, theYAmount:CGFloat, theAnimation:String) {
        self.thePlayer.physicsBody?.isDynamic = true
        self.thePlayer.physicsBody?.affectedByGravity = false

        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        let walkAnimation:SKAction = SKAction(named: theAnimation, duration: moveSpeed)!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y: theYAmount, duration: moveSpeed)
        
        let group:SKAction = SKAction.group([walkAnimation,moveAction])
 
        let finish:SKAction = SKAction.run {
            print("Finish")
            self.thePlayer.physicsBody?.isDynamic = false
            self.thePlayer.physicsBody?.affectedByGravity = false
        }
        let seq:SKAction = SKAction.sequence([wait,group,finish])

        thePlayer.run(seq)
    }
    
    func moveDown(){
        self.thePlayer.physicsBody?.isDynamic = true
        self.thePlayer.physicsBody?.affectedByGravity = true
        
        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        let walkAnimation:SKAction = SKAction(named: "WalkFront", duration: moveSpeed)!
        let moveAction:SKAction = SKAction.moveBy(x: 0, y: -100, duration: moveSpeed)
        
        let group:SKAction = SKAction.group([walkAnimation,moveAction])
        
        let finish:SKAction = SKAction.run {
            print("Finish")
            self.thePlayer.physicsBody?.isDynamic = false
            self.thePlayer.physicsBody?.affectedByGravity = false
        }
        let seq:SKAction = SKAction.sequence([wait,group,finish])
        
        thePlayer.run(seq)
    }

    
    func touchDown(atPoint pos : CGPoint) {
//            print("Touched at \(pos.x) , \(pos.y)")
//        if (pos.y > 0) {
//            //top half
//        } else {
//            moveDown()
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
              for t in touches {
                self.touchDown(atPoint: t.location(in: self))
                
                break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //MARK: ========= Physics Contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.building.rawValue) {
            print ("Touched a building")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue) {
            print ("Touched a person")
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue) {
            print ("Touched a castle")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.castle.rawValue) {
            print ("Touched a castle")
        }

    }

}
