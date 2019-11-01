//
//  GameScene.swift
//  Project23
//
//  Created by Liem Vo on 10/24/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum ForceBomb {
	case never, always, random
}

enum  SequenceType: CaseIterable {
	case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain, fast
}

class GameScene: SKScene {
	
	private var gameScore: SKLabelNode!
	private var score = 0 {
		didSet {
			gameScore.text = "Score: \(score)"
		}
	}
	
	private var livesImages = [SKSpriteNode]()
	private var lives = 3
	
	private var activeSliceBG: SKShapeNode!
	private var activeSliceFG: SKShapeNode!
	
	private var activeSlicePoints = [CGPoint]()
	private var isSwooshSoundActive = false
	private var activeEnemies = [SKSpriteNode]()
	
	private var bombSoundEffect: AVAudioPlayer?
	
	private var popupTime = 0.9
	private var sequence = [SequenceType]()
	private var sequencePosition = 0
	private var chainDelay = 3.0
	private var nextSequenceQueued = true
	private var isGameEnded = false

	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "sliceBackground")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
		
		physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		physicsWorld.speed = 0.85
		createScore()
		createLives()
		createSlices()
		sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
		
		for _ in 0...100 {
			if let nextSequence = SequenceType.allCases.randomElement() {
				sequence.append(nextSequence)
			}
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
			self?.tossEnemies()
		}
	}
	
	private func createScore() {
		gameScore = SKLabelNode(fontNamed: "Chalkduster")
		gameScore.horizontalAlignmentMode = .left
		gameScore.fontSize = 48
		addChild(gameScore)
		
		gameScore.position = CGPoint(x: 8, y: 8)
		score = 0
	}
	
	private func createGameOver() {
		let gameOver = SKLabelNode(fontNamed: "Chalkduster")
		gameOver.horizontalAlignmentMode = .center
		gameOver.fontSize = 64
		gameOver.text = "Game Over"
		addChild(gameOver)
		gameOver.position = CGPoint(x: 560, y: 400)
	}
	
	private func createLives() {
		for i in 0 ..< 3 {
			let spriteNote = SKSpriteNode(imageNamed: "sliceLife")
			spriteNote.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
			addChild(spriteNote)
			livesImages.append(spriteNote)
		}
		
	}
	
	private func createSlices() {
		activeSliceBG = SKShapeNode()
		activeSliceBG.zPosition = 2
		
		activeSliceFG = SKShapeNode()
		activeSliceFG.zPosition = 3
		
		activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
		activeSliceBG.lineWidth  = 9
		
		activeSliceFG.strokeColor = UIColor.white
		activeSliceFG.lineWidth = 5
		
		addChild(activeSliceBG)
		addChild(activeSliceFG)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard isGameEnded == false else { return }
		guard let touch = touches.first else { return }
		let location = touch .location(in: self)
		activeSlicePoints.append(location)
		redrawActiveSlice()
		
		if !isSwooshSoundActive {
			playSwooshSound()
		}
		
		let nodesAtPoint = nodes(at: location)
		
		for case let node as SKSpriteNode in nodesAtPoint {
			if node.name == "enemy" || node.name == "fastenemy" {
				if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy"){
					emitter.position = node.position
					addChild(emitter)
				}
				
				node.name = ""
				node.physicsBody?.isDynamic = false
				let scaleOut = SKAction.scale(to: 0.0001, duration: 0.2)
				let fadeOut = SKAction.fadeOut(withDuration: 0.2)
				let group = SKAction.group([scaleOut, fadeOut])
				
				let seq = SKAction.sequence([group, .removeFromParent()])
				node.run(seq)
				
				score += node.name == "fastenemy" ? 5 : 1
				
				if let index = activeEnemies.firstIndex(of: node) {
					activeEnemies.remove(at: index)
				}
				
				run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
			} else if node.name == "bomb" {
				guard let bombContainer = node.parent as? SKSpriteNode else {
					continue
				}
				
				if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
					emitter.position = bombContainer.position
					addChild(emitter)
				}
				
				node.name = ""
				bombContainer.physicsBody?.isDynamic = false
				let scaleOut = SKAction.scale(to: 0.0001, duration: 0.2)
				let fadeOut = SKAction.fadeOut(withDuration: 0.2)
				let group = SKAction.group([scaleOut, fadeOut])
				
				let seq = SKAction.sequence([group, .removeFromParent()])
				bombContainer.run(seq)
				
				if let index = activeEnemies.firstIndex(of: bombContainer) {
					activeEnemies.remove(at: index)
				}
				
				run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
				endGame(triggeredByBomb: true)
				
			}
		}
	}
	
	private func endGame(triggeredByBomb: Bool) {
		guard isGameEnded == false else { return }
		
		isGameEnded = true
		physicsWorld.speed = 0
		isUserInteractionEnabled = false
		bombSoundEffect?.stop()
		bombSoundEffect = nil
		if triggeredByBomb {
			livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
			livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
			livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
		}
		createGameOver()
	}
	
	private func playSwooshSound() {
		isSwooshSoundActive = true
		
		let randomNumber = Int.random(in: 1...3)
		let soundName = "swoosh\(randomNumber).caf"
		
		let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
		
		run(swooshSound) { [weak self] in
			self?.isSwooshSoundActive = false
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
		activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		activeSlicePoints.removeAll(keepingCapacity: true)
		
		let location = touch.location(in: self)
		activeSlicePoints.append(location)
		
		activeSliceBG.removeAllActions()
		activeSliceFG.removeAllActions()
		
		activeSliceBG.alpha = 1
		activeSliceFG.alpha = 1
	}
	
	private func redrawActiveSlice() {
		if activeSlicePoints.count < 2 {
			activeSliceBG.path = nil
			activeSliceFG.path = nil
			return
		}
		
		if activeSlicePoints.count > 12 {
			activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
		}
		
		let path = UIBezierPath()
		path.move(to: activeSlicePoints[0])
		
		for i in 1 ..< activeSlicePoints.count {
			path.addLine(to: activeSlicePoints[i])
		}
		
		activeSliceBG.path = path.cgPath
		activeSliceFG.path = path.cgPath
	}
	
	private func substractLife() {
		lives -= 1
		
		run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
		
		var life: SKSpriteNode
		if lives == 2 {
			life = livesImages[0]
		} else if lives == 1 {
			life = livesImages[1]
		} else {
			life = livesImages[2]
			endGame(triggeredByBomb: false)
		}
		life.texture = SKTexture(imageNamed: "sliceLifeGone")
		life.xScale = 1.3
		life.yScale = 1.3
		life.run(SKAction.scale(to: 1, duration: 0.1))
	}
	
	override func update(_ currentTime: TimeInterval) {
		if activeEnemies.count > 0 {
			for (index, node) in activeEnemies.enumerated().reversed() {
				if node.position.y < -140 {
					node.removeAllActions()
					if (node.name == "enemy" || node.name == "fastenemy") {
						node.name = ""
						substractLife()
						
						node.removeFromParent()
						activeEnemies.remove(at: index)
					} else if node.name == "bombContainer" {
						node.name = ""
						node.removeFromParent()
						activeEnemies.remove(at: index)
					}
				}
			}
		} else {
			if !nextSequenceQueued {
				DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
					self?.tossEnemies()
				}
				
				nextSequenceQueued = true
			}
		}
		var bombCount = 0
		
		for node in activeEnemies {
			if node.name == "bombContainer" {
				bombCount += 1
				break
			}
		}
		
		if bombCount == 0 {
			bombSoundEffect?.stop()
			bombSoundEffect = nil
		}
	}
	
	private func createEnemy(forceBomb: ForceBomb = .random) {
		
		let enemyRange = 0...7
		let randomEnemyXPositionRange = 64...960
		let	ememyYPosition = -128
		
		let enemy: SKSpriteNode
		
		var enemyType = Int.random(in: enemyRange)
		if forceBomb == .never {
			enemyType = 1
		} else if forceBomb == .always {
			enemyType = 0
		}
		
		if enemyType == 0 {
			enemy = SKSpriteNode()
			enemy.zPosition = 1
			enemy.name = "bombContainer"
			let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
			bombImage.name = "bomb"
			enemy.addChild(bombImage)
			
			if bombSoundEffect != nil {
				bombSoundEffect?.stop()
				bombSoundEffect = nil
			}
			
			if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
				if let sound = try? AVAudioPlayer(contentsOf: path) {
					bombSoundEffect = sound
					sound.play()
				}
			}
			
			if let emmitter = SKEmitterNode(fileNamed: "sliceFuse") {
				emmitter.position = CGPoint(x: 76, y: 64)
				enemy.addChild(emmitter)
			}
		} else {
			enemy = SKSpriteNode(imageNamed: "penguin")
			run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
			enemy.name = enemyType == 7 ? "fastenemy" : "enemy"
			
		}
		
		let randomPosition = CGPoint(x: Int.random(in: randomEnemyXPositionRange), y: ememyYPosition)
		enemy.position = randomPosition
		
		let angularVelocityRange: ClosedRange<CGFloat> = -3...3
		let randomAngularVelocity = CGFloat.random(in: angularVelocityRange)
		let randomXVelocity: Int
		
		let xPosition1: CGFloat = 256
		let xPosition2: CGFloat = 512
		let xPosition3: CGFloat = 768
		let highVelocityRange: ClosedRange<Int> = 8...15
		let lowVelocityRange: ClosedRange<Int> = 3...5
		if randomPosition.x < xPosition1 {
			randomXVelocity = Int.random(in: highVelocityRange)
		} else if randomPosition.x < xPosition2 {
			randomXVelocity = Int.random(in: lowVelocityRange)
		} else if randomPosition.x < xPosition3 {
			randomXVelocity = Int.random(in: lowVelocityRange)
		} else {
			randomXVelocity = Int.random(in: highVelocityRange)
		}
		
		let yVelocityRange = 24...32
		let randomYVelocity = Int.random(in: yVelocityRange)
		
		let radius: CGFloat = 64
		enemy.physicsBody = SKPhysicsBody(circleOfRadius: radius)
		let multipleNumber = 40
		enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * multipleNumber, dy: randomYVelocity * multipleNumber)
		enemy.physicsBody?.angularVelocity = randomAngularVelocity
		enemy.physicsBody?.collisionBitMask = 0
		
		addChild(enemy)
		activeEnemies.append(enemy)
	}
	
	private func tossEnemies() {
		guard isGameEnded == false else { return }
		
		popupTime *= 0.991
		chainDelay *= 0.999
		physicsWorld.speed *= 1.02
		
		let sequenceType = sequence[sequencePosition]
		
		switch sequenceType {
		case .oneNoBomb:
			createEnemy(forceBomb: .never)
		case .one:
			createEnemy()
		case .twoWithOneBomb:
			createEnemy(forceBomb: .never)
			createEnemy(forceBomb: .always)
		case .two:
			createEnemy()
			createEnemy()
		case .three:
			createEnemy()
			createEnemy()
			createEnemy()
		case .four:
			createEnemy()
			createEnemy()
			createEnemy()
			createEnemy()
		case .chain:
			createEnemy()
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }
		case .fastChain:
			createEnemy()
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
		case .fast:
			createEnemy(forceBomb: .never)
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 15.0)) { [weak self] in self?.createEnemy(forceBomb: .never) }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 15.0 * 2)) { [weak self] in self?.createEnemy(forceBomb: .never) }
			DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 15.0 * 3)) { [weak self] in self?.createEnemy(forceBomb: .never) }
		}
		sequencePosition += 1
		nextSequenceQueued = false
	}
}
