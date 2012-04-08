//
//  PullRing.m
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRing.h"

#define MAXFORCE 5000.0f
#define PULLRING_SPRITE @"pullRing.png"
#define PULLRING_SHAPE @"pullRing_shape"
#define PULLRING_ID @"PULLRING"

@implementation PullRing

- (id)initWithPos: (CGPoint)pos AndWorld: (b2World *)world
{
    self = [super init];
    if (self) {
        
        //set obj id
        self.objId = PULLRING_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFile:PULLRING_SPRITE];
        
        //create body def for pullring
        b2BodyDef bodyDef;
        bodyDef.position = toMeters(pos);
        bodyDef.type = b2_dynamicBody;
        bodyDef.userData = self;
        
        //create body for pullring
        body = world->CreateBody(&bodyDef);
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:PULLRING_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:PULLRING_SHAPE]];
    }
    
    return self;
}

//add object sprite
- (void) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile
{
    //CCLOG(@"PullRing::addSpriteAt");
    
    self.sprite = [CCSprite spriteWithFile:spriteFile];
    CGPoint position = CGPointMake(0,0);
    self.sprite.position = position;
}

//player control pullRing by mouseJoint
- (void) createMouseJoint:(CGPoint)location GroundBody:(b2Body*)groundBody World:(b2World *)world
{
    if (mouseJoint != NULL)
        return;
    
    //jointDef
    b2MouseJointDef md;
    md.bodyA = groundBody;
    md.bodyB = body;
    md.target = toMeters(location);
    md.collideConnected = true;
    md.maxForce = MAXFORCE;
    
    mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
    
}

- (void) modifyMouseJoint:(CGPoint)location
{
    if (mouseJoint == NULL)
        return;
    
    mouseJoint->SetTarget(toMeters(location));
}

-(void) destroyMouseJointWorld:(b2World *)world
{
    if (mouseJoint)
    {
        world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
    
}

- (void) scroll:(int)scrollDir
{
    switch (scrollDir) {
        case L:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(-step, 0));
            break;
        case R:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(step, 0));
            break;
            
        default:
            break;
    }
}

@end
