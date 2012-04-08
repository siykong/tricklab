//
//  Pulley.m
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Pulley.h"

#define PULLEY_SPRITE @"pulley.png"
#define PULLEY_SHAPE @"pulley_shape"
#define ROPE_SPRITE @"rope.png"
#define PULLEY_ID @"PULLEY"


@implementation Pulley

@synthesize leftRopeSirpte;
@synthesize rightRopeSirpte;
@synthesize objectBodyA;
@synthesize objectBodyB;
@synthesize spriteA;
@synthesize spriteB;
@synthesize pulleyAnchorA;
@synthesize pulleyAnchorB;


- (id)initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
{
    self = [super init];
    if (self) {
        
        //set obj id
        self.objId = PULLEY_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFile:PULLEY_SPRITE];
        
        //create body def for pulley
        b2BodyDef bodyDef;
        bodyDef.position = toMeters(pos);
        bodyDef.type = b2_staticBody;
        bodyDef.userData = self;
        
        //create body for pulley
        body = world->CreateBody(&bodyDef);
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:PULLEY_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:PULLEY_SHAPE]];  
        
        //add rope sprite
        self.leftRopeSirpte = [CCSprite spriteWithFile:ROPE_SPRITE];
        self.rightRopeSirpte = [CCSprite spriteWithFile:ROPE_SPRITE];
    }
    
    return self;

}

//attach bucket and pullring to pulley
/* position value:
 * 1 -- left
 * 2 -- right
 * 3 -- up
 * 4 -- down
 */
- (void) attachPulleyJointToPulleyBodyA: (b2Body *)bodyA PosA: (int) posA SpriteA: (CCSprite *)spA BodyB: (b2Body *)bodyB  PosB: (int) posB SpriteB: (CCSprite *)spB World: (b2World *)world
{
    objectBodyA = bodyA;
    objectBodyB = bodyB;
    self.spriteA = spA;
    self.spriteB = spB;
    
    b2Vec2 anchor1 = b2Vec2(objectBodyA->GetWorldCenter().x, objectBodyA->GetWorldCenter().y+spriteA.contentSize.height/1.5/PTM_RATIO);
    b2Vec2 anchor2 = b2Vec2(objectBodyB->GetWorldCenter().x, objectBodyB->GetWorldCenter().y);
    
    //pulleyAnchorA
    switch (posA) {
        case 1: //left
            pulleyAnchorA = b2Vec2(body->GetPosition().x - (sprite.contentSize.width-5)/2/PTM_RATIO, body->GetPosition().y);
            break;
        case 2: //right
            pulleyAnchorA = b2Vec2(body->GetPosition().x + (sprite.contentSize.width-5)/2/PTM_RATIO, body->GetPosition().y);
            break;
        case 3: //up
            pulleyAnchorA = b2Vec2(body->GetPosition().x, body->GetPosition().y + (sprite.contentSize.width-5)/2/PTM_RATIO);
            break;
        case 4: //down
            pulleyAnchorA = b2Vec2(body->GetPosition().x, body->GetPosition().y - (sprite.contentSize.width-5)/2/PTM_RATIO);
    }
    
    //pulleyAnchorB
    switch (posB) {
        case 1: //left
            pulleyAnchorB = b2Vec2(body->GetPosition().x - (sprite.contentSize.width-5)/2/PTM_RATIO, body->GetPosition().y);
            break;
        case 2: //right
            pulleyAnchorB = b2Vec2(body->GetPosition().x + (sprite.contentSize.width-5)/2/PTM_RATIO, body->GetPosition().y);
            break;
        case 3: //up
            pulleyAnchorB = b2Vec2(body->GetPosition().x, body->GetPosition().y + (sprite.contentSize.width-5)/2/PTM_RATIO);
            break;
        case 4: //down
            pulleyAnchorB = b2Vec2(body->GetPosition().x, body->GetPosition().y - (sprite.contentSize.width-5)/2/PTM_RATIO);
    }
  //  pulleyAnchorA = b2Vec2(body->GetPosition().x - (sprite.contentSize.width-5)/2/PTM_RATIO, body->GetPosition().y);
  //  pulleyAnchorB = b2Vec2(body->GetPosition().x + (sprite.contentSize.width-5)/2/PTM_RATIO, body->GetPosition().y);
    
    b2PulleyJointDef jointDef;
    jointDef.Initialize(objectBodyA, objectBodyB, pulleyAnchorA, pulleyAnchorB, anchor1, anchor2, 1.0f);
    
    pulleyJoint = (b2PulleyJoint *)world->CreateJoint(&jointDef);
    
}

//call every frame
- (void) drawRope
{
    CGPoint anchorA = toPixels(pulleyJoint->GetAnchorA());//toPixels(b2Vec2(objectBodyA->GetWorldCenter().x, objectBodyA->GetWorldCenter().y+spriteA.contentSize.height/2/PTM_RATIO));
    CGPoint anchorB = toPixels(pulleyJoint->GetAnchorB());//toPixels(b2Vec2(objectBodyB->GetWorldCenter().x, objectBodyB->GetWorldCenter().y+spriteB.contentSize.height/2/PTM_RATIO));
    CGPoint pulleyA = toPixels(pulleyAnchorA);
    CGPoint pulleyB = toPixels(pulleyAnchorB);
    
    //position
    CGPoint ropeAPos = CGPointMake((anchorA.x+pulleyA.x)/2, (anchorA.y+pulleyA.y)/2);
    CGPoint ropeBPos = CGPointMake((anchorB.x+pulleyB.x)/2, (anchorB.y+pulleyB.y)/2);
    
    self.leftRopeSirpte.position = ropeAPos;
    self.rightRopeSirpte.position = ropeBPos;
    
    //scale
    float distanceA = sqrtf(powf(anchorA.x-pulleyA.x, 2) + powf(anchorA.y-pulleyA.y,2));
    float distanceB = sqrtf(powf(anchorB.x-pulleyB.x, 2) + powf(anchorB.y-pulleyB.y,2));
    
    self.leftRopeSirpte.scaleY = distanceA/1000;
    self.rightRopeSirpte.scaleY = distanceB/1000;
    
    //rotation
    float angleA = atanf((anchorA.y-pulleyA.y)/(anchorA.x-pulleyA.x));
    float angleB = atanf((anchorB.y-pulleyB.y)/(anchorB.x-pulleyB.x));
    
    self.leftRopeSirpte.rotation = 90-angleA*180/3.14159;
    self.rightRopeSirpte.rotation = 90-angleB*180/3.14159;
    
}

- (void) scroll:(int)scrollDir
{
    switch (scrollDir) {
        case L:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(-step, 0));
            leftRopeSprite.position = ccpAdd(leftRopeSprite.position, CGPointMake(-step, 0));
            rightRopeSprite.position = ccpAdd(rightRopeSprite.position, CGPointMake(-step, 0));
            break;
        case R:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(step, 0));
            leftRopeSprite.position = ccpAdd(leftRopeSprite.position, CGPointMake(step, 0));
            rightRopeSprite.position = ccpAdd(rightRopeSprite.position, CGPointMake(step, 0));
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    [spriteA release];
    [spriteB release];
    [super dealloc];
}

@end
