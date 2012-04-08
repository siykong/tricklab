//
//  Carrot.m
//  TrickLab
//
//  Created by Siyao Kong on 2/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Carrot.h"

#define CARROT_0_FRM @"carrot_obj_0.png"
#define CARROT_3_FRM @"carrot_obj_3.png"
#define CARROT_6_FRM @"carrot_obj_6.png"
#define CARROT1_ANIM @"carrot1"
#define CARROT2_ANIM @"carrot2"
#define CARROT3_ANIM @"carrot3"


@implementation Carrot

@synthesize sprite1;
@synthesize sprite2;
@synthesize sprite3;
@synthesize sprite1Collected;
@synthesize sprite2Collected;
@synthesize sprite3Collected;
@synthesize numOfCarrotCollected;

- (id) initWithPos1: (CGPoint)pos1 Pos2:(CGPoint)pos2 Pos3:(CGPoint)pos3
{
    if ((self=[super init])) {
        
        //carrot1
        self.sprite1 = [CCSprite spriteWithSpriteFrameName:CARROT_0_FRM];
        sprite1.position = pos1;
        sprite1Collected = NO;        

        
        //carrot2
        self.sprite2 = [CCSprite spriteWithSpriteFrameName:CARROT_3_FRM];
        sprite2.position = pos2;
        sprite2Collected = NO;

        
        //carrot3
        self.sprite3 = [CCSprite spriteWithSpriteFrameName:CARROT_6_FRM];
        sprite3.position = pos3;
        sprite3Collected = NO;

        numOfCarrotCollected = 0;
    }
    
    return self;
}

- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case CARROT1:
            animName = CARROT1_ANIM;
            [sprite1 setDisplayFrameWithAnimationName:animName index:0];
            break;
        case CARROT2:
            animName = CARROT2_ANIM;
            [sprite2 setDisplayFrameWithAnimationName:animName index:0];
            break;
        case CARROT3:
            animName = CARROT3_ANIM;
            [sprite3 setDisplayFrameWithAnimationName:animName index:0];
            break;
            
        default:
            break;
    }
    
    return animName;
}

- (void)changeCarrotBar:(CCSprite *)sprite byFrame:(CCSpriteFrame *)frame
{
    [sprite setDisplayFrame:frame];
}

- (void) scroll:(int)scrollDir
{
    switch (scrollDir) {
        case L:            
            sprite1.position = ccpAdd(sprite1.position, CGPointMake(-step, 0));
            sprite2.position = ccpAdd(sprite2.position, CGPointMake(-step, 0));
            sprite3.position = ccpAdd(sprite3.position, CGPointMake(-step, 0));
            break;
        case R:            
            sprite1.position = ccpAdd(sprite1.position, CGPointMake(step, 0));
            sprite2.position = ccpAdd(sprite2.position, CGPointMake(step, 0));
            sprite3.position = ccpAdd(sprite3.position, CGPointMake(step, 0));
            break;
            
        default:
            break;
    }
}

- (void) dealloc
{
    [sprite1 release];
    [sprite2 release];
    [sprite3 release];
    [super dealloc];
}

@end
