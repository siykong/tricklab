//
//  Rope.m
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Rope.h"

#define ROPEUNIT_RADIUS 0.005*winSize.width
#define ROPEUNIT_DENSITY 0.0f
#define ROPEUNIT_FRICTION 0.0f
#define ROPE_SPRITE @"Icon-Small.png"

@implementation Rope

- (id)initWithPos:(CGPoint)pos AndWorld:(b2World *)world AndSegment:(int32)seg
{
    CCLOG(@"Rope::init");
    self = [super init];
    if (self) {
        winSize = [[CCDirector sharedDirector] winSize];
        
        //init rope
        segment = seg;
        b2BodyDef ropeUnitBodyDef;
        ropeUnitBody = new b2Body*[segment];
        joint = new b2RopeJoint*[segment-1];
        sprite = new CCSprite*[segment];
        
        
        
        //rope unit
        for (int i=0; i<segment; i++) {
            //bodyDef
            ropeUnitBodyDef.position.Set((pos.x-ROPEUNIT_RADIUS*segment + i*ROPEUNIT_RADIUS*2)/PTM_RATIO, pos.y/PTM_RATIO);
            CCLOG(@"Rope::init %f",ropeUnitBodyDef.position.x);
            ropeUnitBodyDef.type = b2_dynamicBody;
            ropeUnitBodyDef.userData = [self addSpriteAt:toPixels(ropeUnitBodyDef.position) WithFile:ROPE_SPRITE WithIndex:i];
            ropeUnitBody[i] = world->CreateBody(&ropeUnitBodyDef);
            
            //shape
            b2CircleShape ropeUnitShape;
            ropeUnitShape.m_radius = ROPEUNIT_RADIUS/PTM_RATIO;
            
            //fixture;
            b2FixtureDef fixture;
            fixture.shape = &ropeUnitShape;
            fixture.density = ROPEUNIT_DENSITY;
            fixture.friction = ROPEUNIT_FRICTION;
            ropeUnitBody[i]->CreateFixture(&fixture);
            
            //joint
            if (i>0){
                b2RopeJointDef jointDef;
                jointDef.bodyA = ropeUnitBody[i-1];
                jointDef.bodyB = ropeUnitBody[i];
                jointDef.localAnchorA = b2Vec2_zero;
                jointDef.localAnchorB = b2Vec2_zero;
                jointDef.maxLength = ROPEUNIT_RADIUS*2/PTM_RATIO;
                b2RevoluteJointDef jd;
                
                joint[i-1] = (b2RopeJoint*)world->CreateJoint(&jointDef);
            }
        }
        
    }
    
    return self;
}

//add object sprite
- (CCSprite *) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile WithIndex:(int32)index
{
    //CCLOG(@"Rope::addSpriteAt");
    
    sprite[index] = [CCSprite spriteWithFile:spriteFile];
    sprite[index].position = pos;
    
    return sprite[index];
}

- (CCSprite *) getSpriteAtIndex:(int32)index
{
    return sprite[index];
}

//add joint between basket/pullring and rope
- (void)attachToRopeHead:(b2Body *)objectBody World: (b2World *)world
{
    b2RopeJointDef jointDef;
    jointDef.bodyA = ropeUnitBody[0];
    jointDef.bodyB = objectBody;
    jointDef.localAnchorA = b2Vec2_zero;
    jointDef.localAnchorB = b2Vec2_zero;
    jointDef.maxLength = ROPEUNIT_RADIUS*2/PTM_RATIO;
    headJoint = (b2RopeJoint*)world->CreateJoint(&jointDef);    
}

//add joint between basket/pullring and rope
- (void)attachToRopeTail:(b2Body *)objectBody World: (b2World *)world
{
    b2RopeJointDef jointDef;
    jointDef.bodyA = ropeUnitBody[segment-1];
    jointDef.bodyB = objectBody;
    jointDef.localAnchorA = b2Vec2_zero;
    jointDef.localAnchorB = b2Vec2_zero;
    jointDef.maxLength = ROPEUNIT_RADIUS*2/PTM_RATIO;
    tailJoint = (b2RopeJoint*)world->CreateJoint(&jointDef);    
}

- (void)dealloc {
    
    [super dealloc];
}

@end
