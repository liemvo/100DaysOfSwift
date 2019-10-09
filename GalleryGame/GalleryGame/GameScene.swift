//
//  GameScene.swift
//  GalleryGame
//
//  Created by Liem Vo on 10/9/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

//  GAME CHARACTERS: http://clipart.nicubunu.ro/?gallery=computers by nicu@nicubunu.ro are licensed under
//                   a Creative Commons Copyright-Only Dedication (based on United States law)
//                   or Public Domain Certification https://creativecommons.org/licenses/publicdomain/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	private var rowTimer: Timer!
	private var badTimer: Timer!
	private var roundTimer: Timer!
	
	private var targets = [SKNode]()
	private let rowTargets = ["tower", "racked", "printer", "penguin", "open_source", "network", "networ_cloud", "mouse", "lcd", "laptop"]
	private let badStuffs = ["network", "networ_cloud", "mouse"]
	
	private let leftEdge = -60
	private let rightEdge = 1024 + 60
	private let row1Position = 100
	private let row2Position = 280
	private let row3Position = 460
	
	private var wallPosition = 640
	
	private let fontFace = "Chalkduster"
	private var isGameOver = false
	
    private var scoreLabel: SKLabelNode!
	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
    
	private var timeLeftLabel: SKLabelNode!
	private var timeLeft: Int = 60 {
		didSet {
			timeLeftLabel.text = "Time: \(timeLeft)"
		}
	}
	
    override func didMove(to view: SKView) {
        
		let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
		
		scoreLabel = SKLabelNode(fontNamed: fontFace)
		scoreLabel.position = CGPoint(x: 16, y: 720)
		scoreLabel.horizontalAlignmentMode = .left
		addChild(scoreLabel)
		score = 0
		
		timeLeftLabel = SKLabelNode(fontNamed: fontFace)
		timeLeftLabel.text = "Time: 60"
		timeLeftLabel.position = CGPoint(x: 850, y: 720)
		timeLeftLabel.horizontalAlignmentMode = .left
		addChild(timeLeftLabel)
		
		Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(startGame), userInfo: nil, repeats: false)
    }
	
	override func update(_ currentTime: TimeInterval) {
        for (index, target) in targets.enumerated().reversed() {
            if let name = target.name {
                if Int(target.position.y) == row1Position && Int(target.position.x) == rightEdge {
                    if badStuffs.contains(name) {
                        score -= 1
                    }
                    
                    targets.remove(at: index)
                    target.removeFromParent()
                } else if Int(target.position.y) == row2Position && Int(target.position.x) == leftEdge {
                    if badStuffs.contains(name) {
                        score -= 2
                    }
                    
                    targets.remove(at: index)
                    target.removeFromParent()
                } else if Int(target.position.y) == row3Position && Int(target.position.x) == rightEdge {
                    if badStuffs.contains(name) {
                        score -= 3
                    }
                    
                    targets.remove(at: index)
                    target.removeFromParent()
                } else if name == "wallL2R" && Int(target.position.x) == rightEdge {
                    score -= 10
                    
                    targets.remove(at: index)
                    target.removeFromParent()
                } else if name == "wallR2L" && Int(target.position.x) == leftEdge {
                    score -= 10
                    
                    targets.remove(at: index)
                    target.removeFromParent()
                }
            }
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
	
	private func checkTouches(_ touches: Set<UITouch>){
		guard let touch = touches.first else { return }
		if !isGameOver {
			let location = touch.location(in: self)
            let nodesAtPoint = nodes(at: location)

            var characterWasTapped = false
			
			for node in nodesAtPoint {
				if node is SKSpriteNode {
					if let name = node.name {
						characterWasTapped = true
						if badStuffs.contains(name) {
							node.name = "hit"
							
							let fade = SKAction.fadeOut(withDuration: 0.25)
                            let shrink = SKAction.scale(to: 0.0, duration: 0.25)
                            let fadeShrink = SKAction.group([fade, shrink])
                            node.run(fadeShrink)
                            
                            switch(Int(node.position.y)){
                            case row1Position:
                                score += 3
                            case row2Position:
                                score += 5
                            case row3Position:
                                score += 10
                            case wallPosition:
                                score += 50
                            default:
                                break
                            }
						} else {
							if node.name == "hit" || node.name == "miss" { return }  // handles cases where multiple taps are registered
                            
                            node.name = "miss"
                            let redX = SKSpriteNode(imageNamed: "X-icon")
                            redX.zPosition = 400
                            
                            let redXFadeOut = SKAction.fadeOut(withDuration: 0.75)
                            redX.run(redXFadeOut)
                            
                            node.addChild(redX)
                            
                            switch(Int(node.position.y)){
                            case row1Position:
                                score -= 5
                            case row2Position:
                                score -= 10
                            case row3Position:
                                score -= 30
                            default:
                                break
                            }
						}
					}
				}
			}

			if !characterWasTapped {
				score -= 10
			}
			
		}
		
	}
	
	@objc private func startGame() {
		rowTimer = Timer.scheduledTimer(timeInterval: 1.75, target: self, selector: #selector(startRowTargets), userInfo: nil, repeats: true)
        badTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(startWallTargets), userInfo: nil, repeats: true)
        roundTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decreaseTimer), userInfo: nil, repeats: true)
	}
    
	@objc private func startRowTargets() {
		var target: String
		
		target = randomTarget()
		let targetAtRow1 = SKSpriteNode(imageNamed: target)
		targetAtRow1.name = target
		targetAtRow1.position = CGPoint(x: leftEdge, y: row1Position)
		targetAtRow1.zPosition = 300
		let moveRow1 = SKAction.moveTo(x: CGFloat(rightEdge), duration: 6.0)
		targetAtRow1.run(moveRow1)
		addChild(targetAtRow1)
		
		target = randomTarget()
		let targetAtRow2 = SKSpriteNode(imageNamed: target)
		targetAtRow2.name = target
		targetAtRow2.position = CGPoint(x: rightEdge, y: row2Position)
		targetAtRow2.zPosition = 300
		let moveRow2 = SKAction.moveTo(x: CGFloat(leftEdge), duration: 5.0)
		targetAtRow2.run(moveRow2)
		addChild(targetAtRow2)
		
		target = randomTarget()
		let targetAtRow3 = SKSpriteNode(imageNamed: target)
		targetAtRow3.name = target
		targetAtRow3.position = CGPoint(x: leftEdge, y: row3Position)
		targetAtRow3.zPosition = 300
		let moveRow3 = SKAction.moveTo(x: CGFloat(rightEdge), duration: 4.0)
		targetAtRow3.run(moveRow3)
		addChild(targetAtRow3)
		
		targets.append(targetAtRow1)
		targets.append(targetAtRow2)
		targets.append(targetAtRow3)
	}
	
	private func randomTarget() -> String {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: rowTargets).first as! String
    }
	
	
	@objc private func startWallTargets() {
		let wall = SKSpriteNode(imageNamed: "wall")
        let moveWall: SKAction
        
        switch(GKRandomSource.sharedRandom().nextInt(upperBound: 2)) {
        case 0:
            wall.position = CGPoint(x: rightEdge, y: wallPosition)
            moveWall = SKAction.moveTo(x: CGFloat(leftEdge), duration: 1.5)  // move right to left
            wall.xScale = -0.7                                               // flip on x and scale 70%
            wall.name = "wallR2L"
        default:
            wall.position = CGPoint(x: leftEdge, y: wallPosition)
            moveWall = SKAction.moveTo(x: CGFloat(rightEdge), duration: 1.5)  // move left to right
            wall.xScale = 0.7                                                 // scale 70%
            wall.name = "wallL2R"
        }
        
        wall.yScale = 0.7
        wall.zPosition = 300
        
        wall.run(moveWall)
        addChild(wall)
        targets.append(wall)
	}
	
	@objc func decreaseTimer() {
        timeLeft -= 1
        
        if timeLeft == 0 {
            rowTimer.invalidate()
            badTimer.invalidate()
            roundTimer.invalidate()
            
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(gameOver), userInfo: nil, repeats: false)
        }
    }

	
	@objc func gameOver() {
        isGameOver = true
        
        let gameOver = SKLabelNode(fontNamed: fontFace)
        gameOver.text = "Game Over"
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 999
        gameOver.horizontalAlignmentMode = .center
        gameOver.fontSize = 128
        addChild(gameOver)
        
        let songCredit = SKLabelNode(fontNamed: fontFace)
        songCredit.text = "I don't like game"
        songCredit.position = CGPoint(x: 512, y: 30)
        songCredit.zPosition = 999
        songCredit.horizontalAlignmentMode = .center
        songCredit.fontSize = 22
        addChild(songCredit)

    }
}
