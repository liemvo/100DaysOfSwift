//
//  GameScene.swift
//  Project20
//
//  Created by Liem Vo on 10/15/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	private var gameTimer: Timer?
	private var fireworks = [SKNode]()
	private let leftEdge = -22
	private let bottomEdge = -22
	private let rightEdge = 1024 + 22
	
	private let fontFace = "Chalkduster"
	
	private var launchCount = 0
	
	private var scoreLabel: SKLabelNode!
	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
		
		scoreLabel = SKLabelNode(fontNamed: fontFace)
		scoreLabel.position = CGPoint(x: 16, y: 16)
		scoreLabel.horizontalAlignmentMode = .left
		addChild(scoreLabel)
		score = 0
		
		gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
		
    }
	
	private func createFireWork(xMovement: CGFloat, x: Int, y: Int) {
		let node = SKNode()
		node.position = CGPoint(x: x, y: y)
		
		let firework = SKSpriteNode(imageNamed: "rocket")
		firework.colorBlendFactor = 1
		firework.name = "firework"
		node.addChild(firework)
		
		switch Int.random(in: 0...2) {
		case 0:
			firework.color = .cyan
		case 1:
			firework.color = .green
		default:
			firework.color = .red
		}
		
		let path = UIBezierPath()
		path.move(to: .zero)
		path.addLine(to: CGPoint(x: xMovement, y: 1000))
		
		let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
		
		node.run(move)
		
		if let emitter = SKEmitterNode(fileNamed: "fuse") {
			emitter.position = CGPoint(x: 0, y: -22)
			node.addChild(emitter)
		}
		
		fireworks.append(node)
		addChild(node)
	}
	
	@objc private func launchFireworks() {
		let movementAmount: CGFloat = 1800
		
		if launchCount == 20 {
			gameTimer?.invalidate()
			return
		}
		launchCount += 1
		
		switch Int.random(in: 0...3) {
		case 0:
			// fire five, traight up
			createFireWork(xMovement: 0, x: 512, y: bottomEdge)
			createFireWork(xMovement: 0, x: 512 - 200, y: bottomEdge)
			createFireWork(xMovement: 0, x: 512 - 100, y: bottomEdge)
			createFireWork(xMovement: 0, x: 512 + 100, y: bottomEdge)
			createFireWork(xMovement: 0, x: 512 + 200, y: bottomEdge)
			
		case 1:
			// fire five, in a fan
			createFireWork(xMovement: 0, x: 512, y: bottomEdge)
			createFireWork(xMovement: -200, x: 512 - 200, y: bottomEdge)
			createFireWork(xMovement: -100, x: 512 - 100, y: bottomEdge)
			createFireWork(xMovement: 100, x: 512 + 100, y: bottomEdge)
			createFireWork(xMovement: 200, x: 512 + 200, y: bottomEdge)
			
		case 2:
			// fire five, from left to the right
			createFireWork(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
			createFireWork(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
			createFireWork(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
			createFireWork(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
			createFireWork(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
			
		case 3:
			// fire five, from right to left
			createFireWork(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
			createFireWork(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
			createFireWork(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
			createFireWork(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
			createFireWork(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
			
		default:
			break
		}
	}
	
	private func checkTouches(_ touches: Set<UITouch>) {
		guard let touch = touches.first else { return }
		
		let location = touch.location(in: self)
		
		let nodesAtPoint = nodes(at: location)
		
		for case let node as SKSpriteNode in nodesAtPoint {
			guard node.name == "firework" else {
				continue
			}
			
			for parent in fireworks {
				guard let firework = parent.children.first as? SKSpriteNode else { continue }
				
				if firework.name == "selected" && firework.color != node.color {
					firework.name = "firework"
					firework.colorBlendFactor = 1
				}
			}
			node.name = "selected"
			node.colorBlendFactor = 0
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		checkTouches(touches)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		
		checkTouches(touches)
	}
	
	override func update(_ currentTime: TimeInterval) {
		for (index, firework) in fireworks.enumerated().reversed() {
			if firework.position.y > 900 {
				fireworks.remove(at: index)
				firework.removeFromParent()
			}
		}
	}
	
	func explode(firework: SKNode) {
		if let emitter = SKEmitterNode(fileNamed: "explode") {
			let delayedRemoval = SKAction.sequence([
				SKAction.wait(forDuration: 3),
				SKAction.removeFromParent()
			])
			emitter.position = firework.position
			emitter.run(delayedRemoval)
			addChild(emitter)
		}
		firework.removeFromParent()
	}
	
	func explodeFireworks() {
		var numExploded = 0
		
		for (index, fireworkContainer) in fireworks.enumerated().reversed() {
			guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
			
			if firework.name == "selected" {
				explode(firework: fireworkContainer)
				fireworks.remove(at: index)
				numExploded += 1
			}
		}
		
		switch numExploded {
		case 0:
			break
		case 1:
			score += 200
		case 2:
			score += 500
		case 3:
			score += 1500
		case 4:
			score += 2500
		default:
			score += 4000
		}
	}
}
