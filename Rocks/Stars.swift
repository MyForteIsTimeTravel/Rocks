/* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  Asteroid.swift
 *  Space Game
 *
 *  Created by Ryan Needham & Danny Wilson on 07/11/2016.
 *  Copyright © 2016 Ryan Needham & Danny Wilson.
 *  All rights reserved.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
import SpriteKit

extension GameScene {
    
    class Stars {
        private let sprite  = SKSpriteNode(color: UIColor.white, size: CGSize(width: 1.5, height: 1.5))
        private var velocity = CGVector(dx: 0, dy: -1)
        
        private var xConfine:Int      = 1080
        private var yConfine:Int      = 1920 // 6 plus default

        func setXConfine (con: Int) { xConfine = con - Int(sprite.size.width) }
        func setYConfine (con: Int) { yConfine = con + Int(sprite.size.width) }
        
        func spawn () -> SKSpriteNode {
            
            // Give name, size and position
            sprite.name       = "star"
            
            sprite.position.x = CGFloat(arc4random_uniform(UInt32(xConfine - Int(sprite.size.width))))
            sprite.position.y = CGFloat(Int(arc4random_uniform(UInt32(yConfine))))
            
            // move to back or render queue
            sprite.zPosition = -10
            
            //sprite.color = StarColour(rawValue: Int(arc4random_uniform(UInt32(StarColour.COLOUR_BOUNDRY.rawValue))))!.toUIColor
            sprite.alpha = CGFloat(arc4random_uniform(10)) / CGFloat(10)
            
            let ting = arc4random_uniform(100);
            
            if (ting < 33) {
                velocity.dy *= 1.00
            } else if (ting > 33) && (ting < 66) {
                velocity.dy *= 1.05
            } else if (ting > 66) {
                velocity.dy *= 1.50
            }
            
            // add to scene
            return sprite
        }
        
        func update () {
            sprite.position.x += velocity.dx
            sprite.position.y += velocity.dy
            
            if (sprite.position.y < 0 - (sprite.size.height * 2)) {
                reuse()
            }
            
            sprite.physicsBody?.allContactedBodies().forEach {
                if ($0.node?.name == "laserbeam") {
                    destroyed()
                }
            }
            
            if (Int(arc4random_uniform(150)) < 2) {
               // sprite.alpha = 0.5 + (CGFloat(arc4random_uniform(5)) / CGFloat(10))
            }
        }
        
        func setSpeed (s: CGFloat) {
            velocity.dy = CGFloat(s)
            
            let ting = arc4random_uniform(100);
            if (ting < 33) {
                velocity.dy *= 1.00
            } else if (ting > 33) && (ting < 66) {
                velocity.dy *= 1.05
            } else if (ting > 66) {
                velocity.dy *= 1.50
            }
        }
        
        func getSpeed () -> CGFloat {
            return velocity.dy
        }
        
        func resetSpeed () {
            self.setSpeed(s: -1)
        }
        
        func destroyed () {
            reuse()
        }
        
        func culled () {
            sprite.removeFromParent()
        }
        
        private func reuse () {
            
            // reuse
            sprite.position.x = CGFloat(arc4random_uniform(UInt32(xConfine)))
            sprite.position.y = CGFloat(yConfine + Int(arc4random_uniform(750)))
            //sprite.color = StarColour(rawValue: Int(arc4random_uniform(UInt32(StarColour.COLOUR_BOUNDRY.rawValue))))!.toUIColor
            sprite.alpha = CGFloat(arc4random_uniform(10)) / CGFloat(10)
        }
    }
}
