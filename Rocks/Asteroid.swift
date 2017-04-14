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
    
    class Asteroid {
        
        // graphics
        private let sprite  = SKSpriteNode(color: UIColor.brown, size: CGSize(width: 10, height: 10))
        private var fragmentSprites = [AsteroidFragment]()
        
        
        // model
        private var size    = 6 + Int(arc4random_uniform(24))
        private var velocity = CGVector(dx: 0, dy: 0 - (2 + Int(arc4random_uniform(6))))
        
        private let explosionEffect   = SKEmitterNode(fileNamed: "asteroidExplosion.sks")
        
        private var xConfine:Int      = 1080
        private var yConfine:Int      = 1920 // 6 plus default
        
        private var textureCache: TextureCache!
        
        private var hit = false
        private var fragmented = false
        
        private var spin: CGFloat = CGFloat(Float(arc4random_uniform(10)) * 0.000001)
        
        func setXConfine (con: Int) { xConfine = con - Int(sprite.size.width) }
        func setYConfine (con: Int) { yConfine = con + Int(sprite.size.width) }
        
        func setSpeed(s: CGFloat) {
            velocity.dy = s
        }
        
        func getSpeed() -> CGFloat {
            return velocity.dy
        }
        
        func resetSpeed () {
            self.setSpeed(s: CGFloat(0 - (2 + Int(arc4random_uniform(6)))))
        }
        
        func spawn (textureCache: TextureCache) -> SKSpriteNode {
            self.textureCache = textureCache
            
            // Give name, size and position
            sprite.name       = "asteroid"
            sprite.xScale     = CGFloat(size)
            sprite.yScale     = CGFloat(size)
            sprite.position.x = CGFloat(arc4random_uniform(UInt32(xConfine - Int(sprite.size.width))))
            sprite.position.y = CGFloat(yConfine + 800 + Int(arc4random_uniform(750)))
            
            // Give graphics
            let ting = 1 + Int(arc4random_uniform(4))
            sprite.texture = textureCache.getCached(key: String("Asteroid_" + String(describing: ting)))
            
            // Give physics components
            sprite.physicsBody                     = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.isDynamic          = true
            sprite.physicsBody?.categoryBitMask    = asteroidCollisionCat
            sprite.physicsBody?.contactTestBitMask = playerCollisionCat
            sprite.physicsBody?.collisionBitMask   = playerCollisionCat
            sprite.physicsBody!.mass               = CGFloat(size)
            sprite.physicsBody?.allowsRotation     = true
            
            // move to back or render queue
            sprite.zPosition = -1
            sprite.zRotation = CGFloat (arc4random_uniform(360))
            
            // populate fragment queue now
            for _ in 0...size {
                fragmentSprites.append(AsteroidFragment())
            }
            
            // add to scene
            return sprite
        }
        
        func update () {
            sprite.position.x += velocity.dx
            sprite.position.y += velocity.dy
            sprite.zRotation += spin
            
            if (sprite.position.y < 0 - (sprite.size.height * 2)) {
                reuse()
            }
            
            fragmentSprites.forEach { $0.update() }
            
            sprite.physicsBody?.allContactedBodies().forEach {
                if ($0.node?.name == "laserbeam") {
                    if (!fragmented) {
                        destroyed()
                    }
                }
            }
        }
        
        func destroyed () {
            fragmented = true
            
            // dispurse fragments
            fragmentSprites.forEach {
                $0.setPosition(x: sprite.position.x, y: sprite.position.y)
                $0.getSprite().removeFromParent()
                sprite.parent?.addChild($0.getSprite())
                $0.boom()
            }
            
            // occasional explosion
            if (size > 6) {
                //explosionEffect?.position = sprite.position
                //explosionEffect?.numParticlesToEmit = size * 10
                //explosionEffect?.removeFromParent()
                //explosionEffect?.resetSimulation()
                //sprite.parent?.addChild(explosionEffect!)
            }
            reuse()
        }
        
        func quietDestroy () {
            reuse()
        }
        
        func culled () {
            sprite.removeFromParent()
        }
        
        private func reuse () {
            
            // randomise appearence
            size          = 2 + Int(arc4random_uniform(24))
            spin          = CGFloat(Float(arc4random_uniform(10)) * 0.000001)
            sprite.xScale = CGFloat(size)
            sprite.yScale = CGFloat(size)
            sprite.zRotation = CGFloat (arc4random_uniform(360))
            
            // reuse
            sprite.position.x = CGFloat(arc4random_uniform(UInt32(xConfine)))
            sprite.position.y = CGFloat(yConfine +  800 + Int(arc4random_uniform(750)))
            
            fragmented = false
        }
    }
}
