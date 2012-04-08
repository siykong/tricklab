//
//  Cradle.m
//  TrickLab
//
//  Created by Siyao Kong on 2/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Cradle.h"

#define CRADLE_SWING_0_FRM @"cradle_swing_0.png"
#define CRADLE_SWING_ANIM @"cradle_swing"
#define CRADLE_SUCCEED_ANIM @"cradle_succeed"
#define CRADLE_SHAPE @"cradle_shape"
#define CRADLE_ID @"CRADLE"


@implementation Cradle

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world
{
    if ((self=[super init])) {   
        
        //set obj id
        self.objId = CRADLE_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFrameName:CRADLE_SWING_0_FRM];
        
        //create body def for cradle
        b2BodyDef bodyDef;
        bodyDef.position = toMeters(pos);
        bodyDef.type = b2_staticBody;
        bodyDef.userData = self;
        
        //create body for stone
        body = world->CreateBody(&bodyDef);
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:CRADLE_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:CRADLE_SHAPE]];
    }
    
    return self;
}

- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case SWING:
            animName = CRADLE_SWING_ANIM;
            break;
        case SUCCEED:
            animName = CRADLE_SUCCEED_ANIM;
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
