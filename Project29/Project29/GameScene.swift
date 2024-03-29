//
//  GameScene.swift
//  Project29
//
//  Created by Liem Vo on 11/14/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
	case banana = 1
	case building = 2
	case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	private var buildings = [BuildingNode]()
	weak var viewController: GameViewController?
	
	private var player1: SKSpriteNode!
	private var messageLabel: SKLabelNode!
	private var player2: SKSpriteNode!
	private var banana: SKSpriteNode!
	
	private var gameOver: SKLabelNode!
	private var player1Score = 0 {
		didSet {
			isGameOver = self.player2Score >= 3 || self.player1Score >= 3
		}
	}
	private var player2Score = 0 {
		didSet {
			isGameOver = self.player2Score >= 3 || self.player1Score >= 3
		}
	}
	
	private var currentPlayer = 1
	
	private var isGameOver: Bool = false
	
	override func didMove(to view: SKView) {
		backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
		
		createBuildings()
		createPlayers()
		physicsWorld.contactDelegate = self
	}
	
	func createSpeed() {
		let speed = CGFloat.random(in: 0.5 ... 2.0)
		physicsWorld.speed = speed
		viewController?.speedLabel.isHidden = false
		viewController?.speedLabel.text = "Speed: \(speed) m/s"
	}
	
	private func createBuildings() {
		var currentX: CGFloat = -15
		
		while(currentX < 1024) {
			let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
			currentX += size.width + 2
			
			let building = BuildingNode(color: UIColor.red, size: size)
			building.name = "building"
			building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
			building.setup()
			addChild(building)
			
			buildings.append(building)
		}
	}
	
	func launch(angle: Int, velocity: Int) {
		if isGameOver {
			self.player1Score = 0
			self.player2Score = 0
			viewController?.launchButton.setTitle("Launch", for: .normal)
			gameOver.removeFromParent()
			gameOver = nil
			messageLabel.removeFromParent()
			messageLabel = nil
			currentPlayer = 1
			
			createNewSence()
		}
		let speed = Double(velocity) / 10
		
		let radians = deg2rad(degrees: angle)
		
		if banana != nil {
			banana.removeFromParent()
			banana = nil
		}
		
		banana = SKSpriteNode(imageNamed: "banana")
		banana.name = "banana"
		banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
		banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
		banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
		banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
		
		banana.physicsBody?.usesPreciseCollisionDetection = true
		addChild(banana)
		
		if currentPlayer == 1 {
			banana.position = CGPoint(x: player1.position.x  - 30, y: player1.position.y + 40)
			banana.physicsBody?.angularVelocity = -20
			
			let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
			let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
			let pause = SKAction.wait(forDuration: 0.15)
			
			let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
			player1.run(sequence)
			
			let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
			banana.physicsBody?.applyImpulse(impulse)
		} else {
			banana.position = CGPoint(x: player2.position.x  + 30, y: player2.position.y + 40)
			banana.physicsBody?.angularVelocity = 20
			
			let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
			let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
			let pause = SKAction.wait(forDuration: 0.15)
			
			let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
			player2.run(sequence)
			
			let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
			banana.physicsBody?.applyImpulse(impulse)
		}
		
	}
	
	private func deg2rad(degrees: Int) -> Double {
		return Double(degrees) * Double.pi / 180
	}
	
	private func createPlayers() {
		player1 = SKSpriteNode(imageNamed: "player")
		player1.name =  "player1"
		player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
		
		player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
		player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
		player1.physicsBody?.isDynamic = false
		
		let player1Building = buildings[1]
		player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
		addChild(player1)
		
		
		player2 = SKSpriteNode(imageNamed: "player")
		player2.name =  "player2"
		player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
		
		player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
		player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
		player2.physicsBody?.isDynamic = false
		
		let player2Building = buildings[buildings.count - 2]
		player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
		addChild(player2)
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		let firstBody: SKPhysicsBody
		let secondBody: SKPhysicsBody
		
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		guard let firstNode = firstBody.node else { return }
		guard let secondNode = secondBody.node else { return }
		
		if firstNode.name == "banana" && secondNode.name == "building" {
			bananaHit(building: secondNode, atPoint: contact.contactPoint)
		}
		
		if firstNode.name == "banana" && secondNode.name == "player1" {
			player2Score += 1
			destroy(player: player1)
		}
		
		if firstNode.name == "banana" && secondNode.name == "player2" {
			player1Score += 1
			destroy(player: player2)
		}
	}
	
	private func destroy(player: SKSpriteNode) {
		if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
			explosion.position = player.position
			addChild(explosion)
		}
		
		player.removeFromParent()
		banana.removeFromParent()
		
		if (isGameOver) {
			createGameOver()
			self.viewController?.speedLabel.isHidden = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			if (!self.isGameOver) {
				self.createNewSence()
			}
		}
	}
	
	private func createNewSence() {
		
		let newGame = GameScene(size: self.size)
		newGame.viewController = self.viewController
		self.viewController?.currentGame = newGame
		self.changePlayer()
		newGame.currentPlayer = self.currentPlayer
		newGame.player1Score = self.player1Score
		newGame.player2Score = self.player2Score
		newGame.createSpeed()
		let transition = SKTransition.doorway(withDuration: 1.5)
		self.view?.presentScene(newGame, transition: transition)
	}
	
	private func createGameOver() {
		
		let fontFace = "Chalkduster"
		
		gameOver = SKLabelNode(fontNamed: fontFace)
		gameOver.horizontalAlignmentMode = .center
		gameOver.fontSize = 64
		gameOver.text = "Game Over"
		gameOver.zPosition = 5
		addChild(gameOver)
		gameOver.position = CGPoint(x: 560, y: 400)
		
		
		let win: String
		if player1Score >= 3 {
			win = "Player1"
		} else {
			win = "Player2"
		}
		messageLabel = SKLabelNode(fontNamed: fontFace)
        messageLabel.text = "\(win) is a winner!"
        messageLabel.position = CGPoint(x: 512, y: 320)
        messageLabel.zPosition = 999
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontSize = 22
        addChild(messageLabel)
		
		viewController?.launchButton.isHidden = false
		viewController?.launchButton.setTitle("Restart", for: .normal)
	}
	
	private func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
		guard let building = building as? BuildingNode else { return }
		let buildingLocation = convert(contactPoint, to: building)
		building.hit(at: buildingLocation)
		
		if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
			explosion.position = contactPoint
			addChild(explosion)
		}
		
		banana.name = ""
		banana.removeFromParent()
		banana = nil
		changePlayer()
	}
	
	private func changePlayer() {
		if currentPlayer == 1 {
			currentPlayer = 2
		} else {
			currentPlayer = 1
		}
		
		viewController?.activatePlayer(number: currentPlayer)
	}
	
	override func update(_ currentTime: TimeInterval) {
		guard banana != nil else { return }
		
		if abs(banana.position.y) > 1000 {
			banana.removeFromParent()
			banana = nil
			changePlayer()
		}
	}
}
