//
//  GameScene.swift
//  Project26
//
//  Created by Liem Vo on 11/6/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
	case player = 1
	case wall = 2
	case star = 4
	case vortex = 8
	case finish = 16
	case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	private var player: SKSpriteNode!
	private var lastTouchPosition: CGPoint? = nil
	private var motionManager: CMMotionManager?
	private var isGameOver = false
	
	private var scoreLabel: SKLabelNode!
	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	private var spacePositions = [CGPoint]()
	private var currentLevel = 1
	
	private var finishLevelLabel: SKLabelNode!
	private var nextButton: SKSpriteNode?
	
	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
		
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.position = CGPoint(x: 16, y: 16)
		scoreLabel.zPosition = 2
		addChild(scoreLabel)
		
		loadLeve(level: currentLevel)
		createPlayer()
		
		physicsWorld.gravity = .zero
		physicsWorld.contactDelegate = self
		
		motionManager = CMMotionManager()
		motionManager?.startAccelerometerUpdates()
	}
	
	private func loadLeve(level: Int) {
		guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {
			fatalError("Could not find level1.txt in the app bundle.")
		}
		guard let levelString = try? String(contentsOf: levelURL) else {
			fatalError("Could not find level1.txt in the app bundle.")
		}

		let lines = levelString.components(separatedBy: "\n")
		spacePositions.removeAll()
		buildGameBoard(lines)
	}
	
	private func buildGameBoard(_ lines: [String]) {
		
		for (row, line) in lines.reversed().enumerated() {
			for (column, letter) in line.enumerated() {
				let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
				
				if letter == "x" {
					addBlockNode(at: position, name: "block")
				}  else if letter == "t" {
					addGameNode(at: position, name: "teleport", bitmask: CollisionTypes.vortex.rawValue)
				} else if letter == "v" {
					addGameNode(at: position, name: "vortex", bitmask: CollisionTypes.vortex.rawValue)
				} else if letter == "s" {
					addGameNode(at: position, name: "star", bitmask: CollisionTypes.star.rawValue)
				} else if letter == "f" {
					addGameNode(at: position, name: "finish", bitmask: CollisionTypes.finish.rawValue)
				} else if letter == " " {
					spacePositions.append(position)
				} else {
					fatalError("Uknown level letter: \(letter)")
				}
			}
		}
	}
	
	private func addBlockNode(at position: CGPoint, name: String) {
		let node = SKSpriteNode(imageNamed: name)
		node.position = position
		node.name = name
		node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
		node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
		node.physicsBody?.isDynamic = false
		
		addChild(node)
	}
	
	private func addGameNode(at position: CGPoint, name: String, bitmask: UInt32) {
		let node = SKSpriteNode(imageNamed: name)
		node.name = name
		node.position = position
		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false
		
		node.physicsBody?.categoryBitMask = bitmask
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}
	
	private func createPlayer(at position: CGPoint? = nil) {
		player = SKSpriteNode(imageNamed: "player")
		player.position = position ?? CGPoint(x:96, y: 672)
		player.zPosition = 1
		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.linearDamping = 0.5
		
		player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleport.rawValue
		
		player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
		addChild(player)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		lastTouchPosition = location
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		lastTouchPosition = location
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		
		guard let nextButton = self.nextButton else { return }
		if nextButton.contains(location) {
			cleanBoardGame()
			finishLevelLabel.removeFromParent()
			
			nextButton.removeFromParent()
			currentLevel += 1
			if currentLevel < 3 {
				loadLeve(level: currentLevel)
				createPlayer()
			} else {
				isGameOver = true
			}
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		guard isGameOver == false else { return }
		#if targetEnvironment(simulator)
		if let lastTouchPosition = lastTouchPosition {
			let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
			physicsWorld.gravity = CGVector(dx: diff.x, dy: diff.y)
		}
		#else
		if let accelerometerData = motionManager?.accelerometerData {
			physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
		}
		#endif
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node else { return }
		guard let nodeB = contact.bodyB.node else { return }
		
		if nodeA == player {
			playerCollided(with: nodeB)
		} else if nodeB == player {
			playerCollided(with: nodeA)
		}
	}
	
	private func playerCollided(with node: SKNode) {
		if node.name == "vortex" {
			player.physicsBody?.isDynamic = false
			isGameOver = true
			score -= 1
			
			let move = SKAction.move(to: node.position, duration: 0.25)
			let scale = SKAction.scale(by: 0.0001, duration: 0.25)
			let remove = SKAction.removeFromParent()
			let sequence = SKAction.sequence([move, scale, remove])
			player.run(sequence) { [weak self] in
				self?.createPlayer()
				self?.isGameOver = false
			}
		} else if node.name == "star" {
			node.removeFromParent()
			score += 1
		} else if node.name == "finish" {
			let move = SKAction.move(to: node.position, duration: 0.25)
			let scale = SKAction.scale(by: 0.0001, duration: 0.25)
			let remove = SKAction.removeFromParent()
			let sequence = SKAction.sequence([move, scale, remove])
			player.run(sequence)
			
			showFinishLevel()
		} else if node.name ==  "teleport" {
			if let position = spacePositions.randomElement() {
				let move = SKAction.move(to: node.position, duration: 0.25)
				let scale = SKAction.scale(by: 0.0001, duration: 0.25)
				let remove = SKAction.removeFromParent()
				let sequence = SKAction.sequence([move, scale, remove])
				player.run(sequence) { [weak self] in
					self?.createPlayer(at: position)
				}
			}
		}
	}
	
	private func showFinishLevel() {
		
		finishLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
		finishLevelLabel.text = "You have finish level: \(currentLevel)"
		finishLevelLabel.horizontalAlignmentMode = .center
		finishLevelLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
		finishLevelLabel.zPosition = 2
		addChild(finishLevelLabel)
		
		let nextButton = SKSpriteNode(imageNamed: "next")
		nextButton.position = CGPoint(x:self.frame.midX, y:self.frame.midY - finishLevelLabel.frame.height)
		nextButton.zPosition = 2
		nextButton.name = "next"
		addChild(nextButton)
		self.nextButton = nextButton
		
	}
	
	private func cleanBoardGame() {
		for child in self.children {
			if child.name == "vortex" || child.name == "star" || child.name == "finish" || child.name == "block" || child.name == "teleport" {
				child.removeFromParent()
			}
		}
	}
}
