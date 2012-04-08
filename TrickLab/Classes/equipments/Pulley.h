//
//  Pulley.h
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

@interface Pulley : PhysicsObject{
    
    b2PulleyJoint* pulleyJoint;
    
    b2Body *objectBodyA;    //basket or pullring
    b2Body *objectBodyB;    //basket or pullring
    CCSprite *spriteA;
    CCSprite *spriteB;
    CCSprite *leftRopeSprite;
    CCSprite *rightRopeSprite;
    
    b2Vec2 pulleyAnchorA;     //pulleyjoint anchor on pulley
    b2Vec2 pulleyAnchorB;
    
}

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
- (void) attachPulleyJointToPulleyBodyA: (b2Body *)bodyA PosA: (int) posA SpriteA: (CCSprite *)spA BodyB: (b2Body *)bodyB  PosB: (int) posB SpriteB: (CCSprite *)spB World: (b2World *)world;
- (void) drawRope;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *leftRopeSirpte;
@property (retain) CCSprite *rightRopeSirpte;
@property b2Body *objectBodyA;
@property b2Body *objectBodyB;
@property (retain) CCSprite *spriteA;
@property (retain) CCSprite *spriteB;
@property b2Vec2 pulleyAnchorA;
@property b2Vec2 pulleyAnchorB;

@end
