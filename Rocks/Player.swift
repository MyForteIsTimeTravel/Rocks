/* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  Player.swift
 *  Space Game
 *
 *  Created by Ryan Needham & Danny Wilson on 07/11/2016.
 *  Copyright © 2016 Ryan Needham & Danny Wilson.
 *  All rights reserved.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
import SpriteKit

extension GameScene {
    class Player {
        
        // the admin
        private var velocity     = CGVector(dx: 0, dy: 0)
        private var lasers       = NSMutableArray()
        private let score        = Counter()
        private var ammo         = 25
        private let AMMO_MAX     = 25
        private var health       = 25
        private let HEALTH_MAX   = 25
        private var restingY     = 100
        private var laserColour  = LaserColour.cyan//Save.getLaserID()
        private var name = "player"
        private var bodyID: Int!
        private var thrusterID: Int!
        private var colourID: Int!
        
        private var ship: Ship!
        
        private var firing = false
        
        private var targetScale = CGVector(dx: 1, dy: 1)
        
        private var playedBefore = false
        
        
        func getName     () -> String  { return name }
        func getPosition () -> CGPoint { return ship.position }
        func getHealth   () -> Int     { return health }
        func getAmmo     () -> Int     { return ammo }
        func getScore    () -> Int     { return score.getCount() }
        func getShip     () -> Ship    { return ship }
        func getLaserColour () -> UIColor {return laserColour.toUIColor}
        func hasPlayedBefore() -> Bool { return playedBefore }
        
        init () {}
        
        func startAutoFire () { firing = true  }
        func stopAutoFire  () { firing = false }
        
        func moveRight   () { velocity.dx += 5 }
        func moveLeft    () { velocity.dx -= 5 }
        func moveUp      () { velocity.dy += 5 }
        func setRestingY (y: Int) { restingY = y }
        func move        (to: CGPoint) { ship.position = to }
        
        func nextLaserColour () { laserColour = laserColour.nextColour;}// Save.setLaserID(x: laserColour) }
        func prevLaserColour () { laserColour = laserColour.prevColour;}// Save.setLaserID(x: laserColour) }
        
        func scaleTo (x: CGFloat, y: CGFloat) { targetScale = CGVector(dx: x, dy: y) }
        func hide () { ship.isHidden = true }
        func show () { ship.isHidden = false }
        func shrink () { ship.xScale = 1.0; ship.yScale = 1.0}
        func serializeShip () -> Vector3D { return ship.serialize() }
        
        func setX (x: CGFloat) { ship.position.x = x }
        func setY (y: CGFloat) { ship.position.y = y }
        
        func buildShip () {
            bodyID = Save.getShipID()
            thrusterID = Save.getThrusterID()
            colourID = Save.getColourID()
            print("\(bodyID)\(thrusterID)\(colourID)")
            
            //if (Save.getLaserID().rawValue == 0) {
                laserColour = LaserColour.cyan
            //}
                
            //else {
            //    laserColour = Save.getLaserID()
            //}
            
            // NOT YET SAVED
            if bodyID == 0 {
                ship = Ship (
                    bID: 11,
                    tID: 5,
                    cID: 6
                )
            }

            // SAVED SHIP FOUND
            else {
                ship = Ship(
                    bID: bodyID,
                    tID: thrusterID,
                    cID: colourID
                )
            }
        }
        
        func disassembleShip() {
            ship.disassemble()
        }
        
        func reassembleShip () {
            ship.animatedReassemble()
        }
        
        func resetAt (x: Int, y: Int) {
            // reset health and ammo
            restingY = y
            health   = HEALTH_MAX
            ammo     = AMMO_MAX
            
            // move, reset rotation
            ship.reassemble()
            ship.xScale = 1.0
            ship.yScale = 1.0
            ship.position    = CGPoint(x: x, y: y)    // reset position
            
            score.reset()
        }
        
        func spawn (x: Int, y: Int) -> SKNode {
            restingY = y

            ship.position = CGPoint(x: x, y: y)
            
            // Give physics
            ship.physicsBody                                  = SKPhysicsBody(rectangleOf: CGSize(width: ship.metaWidth, height: ship.metaHeight))
            ship.physicsBody?.isDynamic                       = true
            ship.physicsBody?.categoryBitMask                 = playerCollisionCat
            ship.physicsBody?.contactTestBitMask              = asteroidCollisionCat
            ship.physicsBody?.collisionBitMask                = asteroidCollisionCat
            ship.physicsBody!.affectedByGravity               = false
            ship.physicsBody!.mass                            = 0.02
            ship.physicsBody!.allowsRotation                  = false
            ship.physicsBody!.usesPreciseCollisionDetection   = true
            ship.physicsBody!.linearDamping                   = 3
            
            return ship
        }
        
        func update (currentTime: TimeInterval) {
        
            
            // move
            if (!isExploding()) {
                if (ship.position.y < CGFloat(restingY - 10)) {
                    velocity.dy += 0.0025 * (ship.position.y + CGFloat(restingY))
                } else if (ship.position.y > CGFloat(restingY + 10)) {
                    velocity.dy -= 0.0025 * (ship.position.y + CGFloat(restingY))
                }
            }
            
            // scale
            if (ship.xScale < targetScale.dx) { ship.xScale += 0.02 }
            if (ship.yScale < targetScale.dy) { ship.yScale += 0.02 }
            if (ship.xScale > targetScale.dx) { ship.xScale -= 0.02 }
            if (ship.yScale > targetScale.dy) { ship.yScale -= 0.02 }
            
            // apply velocity
            ship.position.x += velocity.dx
            ship.position.y += velocity.dy
            
            ship.update()
            
            // dampen
            velocity.dx = velocity.dx / 2
            velocity.dy = velocity.dy / 2
            
            // laser
            for laser in (lasers as NSArray as! [LaserBeam]) { laser.update() }
            cullLasers()
        }
        
        func pickupHealth () {
            if      (health < HEALTH_MAX - 10) { health += 10 }
            else if (health > HEALTH_MAX - 10) { health = HEALTH_MAX }
        }
        
        func pickupAmmo   () { ammo = AMMO_MAX }
        func pickupPoints () { for _ in 1...100 { score.increment() } }
        func give (points: Int) { for _ in 1...points { score.increment() } }
        
        func takeDamage () {
            if      (health <  2) { health = 0 }
            else if (health >= 2) { health -= 1; }
            
            ship.flash(color: UIColor.red)
        }
        
        func explode () { ship.explode() }
        
        func isExploding() -> Bool { return ship.isExploding() }
        
        func fireLaser () {
            if (ammo > 0) {
                let beam = LaserBeam()
                lasers.add(beam)
                ammo -= 1
                ship.parent?.addChild(beam.fire(o: CGVector(dx: ship.position.x, dy: ship.position.y), colour: laserColour.toUIColor))
            }
        }
        
        func cullLasers () {
            for laser in (lasers as NSArray as! [LaserBeam]) {
                if (laser.getPosition().dy > 1000) {
                    laser.cull()
                    lasers.remove(laser)
                }
            }
        }
        
        func clearLasers () {
            for laser in (lasers as NSArray as! [LaserBeam]) {
                laser.cull()
                lasers.remove(laser)
            }
        }
    }
}
