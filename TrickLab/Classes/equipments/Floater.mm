//
//  Floater.m
//  TrickLab
//
//  Created by Siyao Kong on 1/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Floater.h"

#define FLOATER_STATIC_FRM @"floater_static.png"
#define FLOATER_ANIM @"floater"
#define FLOATER_SHAPE @"floater_shape"
#define FLOATER_ID @"FLOATER"

@interface Floater (PrivateMethods)

- (void) activate;
- (void) deactivate;
- (void) applyForceWhenContactWithBabyHamster:(float)babyMass vel:(float)babyVel;

@end


@implementation Floater

@synthesize jointWithBabyHamster;
@synthesize startContactWithBabyHamster;
@synthesize endContactWithBabyHamster;

- (id) initWithPos: (CGPoint)pos move:(int)moveDir AndWorld: (b2World *)world
{
    if ((self=[super init])) {
        
        //set obj id
        self.objId = FLOATER_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFrameName:FLOATER_STATIC_FRM];
        
        //create body def for floater
        b2BodyDef bodyDef;
        bodyDef.type = b2_staticBody;
        bodyDef.position = toMeters(pos);
        bodyDef.userData = self;
        bodyDef.angularDamping = 2.0f;
        
        //create body for floater
        body = world->CreateBody(&bodyDef);
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:FLOATER_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:FLOATER_SHAPE]];
                
        //set to false to put body to sleep, true to wake it.
        body->SetAwake(NO);
        body->SetActive(NO);
        
        startContactWithBabyHamster = NO;
        endContactWithBabyHamster = NO;
        
        originDir = moveDir;
        dir = moveDir;
        originPos = sprite.position;
        
        steadyImpluse = NO;
    }
    
    return self;
}

//activate/deactivate floater, apply force to floater
- (void) updateStatusWithVel:(float)babyVel mass:(float)babyMass
{
    if (startContactWithBabyHamster) {
        [self activate];
    }    
    
    [self applyForceWhenContactWithBabyHamster:babyMass vel:babyVel];
    
    //if (!checkObjectInBoundry(sprite)) {
        //[self deactivate];
    //}
}

//make floater fly up
- (void) applyForceWhenContactWithBabyHamster:(float)babyMass vel:(float)babyVel
{
    //CCLOG(@"Floater::applyForceWhenContactWithBabyHamster");

    if (body->IsAwake()){
        if (!steadyImpluse && babyVel < 2.0) {
            body->ApplyLinearImpulse(b2Vec2(0.0f,(body->GetMass()+babyMass)*10*2/PTM_RATIO), body->GetPosition());
        }
        else if (!steadyImpluse) {
            body->ApplyLinearImpulse(b2Vec2(0.0f,(body->GetMass()+babyMass)*9.8/PTM_RATIO), body->GetPosition());
            steadyImpluse = YES;
        }
        else if (steadyImpluse && babyVel < -0.5) {
            steadyImpluse = NO;
        }
        else if (steadyImpluse && babyVel >= 2.0) {
            body->ApplyLinearImpulse(b2Vec2(0.0f,(body->GetMass()+babyMass)*9.6/PTM_RATIO), body->GetPosition());
        }
        else if (steadyImpluse && babyVel < 2.0) {
            body->ApplyLinearImpulse(b2Vec2(0.0f,(body->GetMass()+babyMass)*9.8/PTM_RATIO), body->GetPosition());
        }
    }    
}

- (void) autoMoveWithDistance:(int)dist
{    
    CGPoint pos = sprite.position;
    
    float lowerBound, upperBound;
    float leftBound, rightBound;
    if (originDir == DOWN) {
        lowerBound = originPos.y;
        upperBound = originPos.y-dist;
    }
    else if (originDir == UP) {
        lowerBound = originPos.y+dist;
        upperBound = originPos.y;
    }
    else if (originDir == RIGHT) {
        leftBound = originPos.x;
        rightBound = originPos.x+dist;
    }
    else if (originDir == LEFT) {
        leftBound = originPos.x-dist;
        rightBound = originPos.x;
    }
    
    if (dir == DOWN) {
        pos.y -= 2;        
        if (pos.y < upperBound) {
            dir = UP;
        }
    }
    else if (dir == UP) {
        pos.y += 2;
        if (pos.y > lowerBound) {
            dir = DOWN;
        }
    }
    else if (dir == RIGHT) {
        pos.x += 2;
        if (pos.x > rightBound) {
            dir = LEFT;
        }
    }
    else if (dir == LEFT) {
        pos.x -= 2;
        if (pos.x < leftBound) {
            dir = RIGHT;
        }
    }
    sprite.position = pos;   
    body->SetTransform(toMeters(pos), 0);
}

//change floater from static to dynamic
- (void) activate
{
    //CCLOG(@"Floater::activate");
    
    body->SetType(b2_dynamicBody);
    body->SetAwake(YES);    
    body->SetActive(YES);
}

//change floater from dynamic to static
- (void) deactivate
{
    //CCLOG(@"Floater::deactivate");
    
    body->SetType(b2_staticBody);
    body->SetAwake(NO);    
    body->SetActive(NO);
}

- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case ROTATE:
            animName = FLOATER_ANIM;
            break;
            
        default:
            break;
    }
    [sprite setDisplayFrameWithAnimationName:animName index:0];
    return animName;
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
