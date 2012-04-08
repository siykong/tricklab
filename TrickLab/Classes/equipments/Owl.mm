//
//  Owl.m
//  TrickLab
//
//  Created by Chao Huang on 2/20/12.
//  Copyright (c) 2012 USC. All rights reserved.
//

#import "Owl.h"

#define OWL_SPRITE @"owl_sleep.png"
#define OWL_MOVE @"owl_move"
#define OWL_SLEEP @"owl_sleep"
#define OWL_WINK @"owl_wink"
#define MOVING_DURATION 4
#define MOVE_DELAY 4
#define SLEEP_DURATION 4
#define WINK_DURATION 4
#define ANIMATION_INTERVAL 4.0f

@implementation Owl


@synthesize sprite;
@synthesize range;
@synthesize active;
@synthesize positionArrayLength;
@synthesize positionArray;
@synthesize animationInterval;


- (id) initWithPosArray: (CGPoint*)posArray PosLen: (int)posArrayLength Range: (float)rg IsActive:(Boolean)isActive
{    
    if ((self=[super init])) {
        //range
        range = rg;  
        
        //active
        active = isActive;
        
        //position array
        positionArrayLength = posArrayLength;
        positionArray = new CGPoint[positionArrayLength];
        for (int i=0; i<positionArrayLength; i++)
            positionArray[i] = posArray[i];
        
        //sprite
        self.sprite = [CCSprite spriteWithFile:OWL_SPRITE];
        self.sprite.position = posArray[0];
        
        [self owlAction];
    }    
    
    return self;
}

- (void) owlAction
{
    if (positionArrayLength < 1)
        return;
    else if (positionArrayLength == 1)      //single position
    {
        CCAction *owlWinkAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[self startAnimWithTag:WINK] times:2];
        [sprite runAction:owlWinkAction];
        animationTag = SLEEP;
        animationInterval = ANIMATION_INTERVAL;
    }
    else        //multiple position
    {
        //position
        CCMoveTo* move;
        CCEaseInOut* easeMove;
        CCDelayTime* delay;
        CCSequence* sequence;
    
        //init
        CCDelayTime* idle = [CCDelayTime actionWithDuration:0.0f];
    
        //animation
        CCAction *owlMoveAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[self startAnimWithTag:MOVE] times:2];
        [sprite runAction:owlMoveAction];
        animationTag = WINK;
        animationInterval = ANIMATION_INTERVAL;
    
        delay = [CCDelayTime actionWithDuration:MOVE_DELAY];
        sequence = [CCSequence actions:idle, nil];
    
        for (int i=1; i<positionArrayLength; i++)
        {
        
            move = [CCMoveTo actionWithDuration:MOVING_DURATION position:positionArray[i]];
            easeMove = [CCEaseInOut actionWithAction:move rate:3];
        
            sequence = [CCSequence actionOne:sequence two:easeMove];
            sequence = [CCSequence actionOne:sequence two:delay];
        
        }
    
        move = [CCMoveTo actionWithDuration:MOVING_DURATION position:positionArray[0]];
        easeMove = [CCEaseInOut actionWithAction:move rate:3];
    
        sequence = [CCSequence actionOne:sequence two:easeMove];
        sequence = [CCSequence actionOne:sequence two:delay];    
    
        CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
        [sprite runAction:repeat];
    }
}


- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case MOVE:
            animName = OWL_MOVE;
            break;
        case SLEEP:
            animName = OWL_SLEEP;
            break;
        case WINK:
            animName = OWL_WINK;
            break;
            
        default:
            break;
    }
    
    [sprite setDisplayFrameWithAnimationName:animName index:0];
    return animName;
}

- (void)updateOwlAnimation
{
    if (positionArrayLength < 1)
        return;
    else if (positionArrayLength == 1)//single position
    {
        if (animationTag == SLEEP)
        {
            CCAction *owlSleepAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[self startAnimWithTag:SLEEP] times:2];
            [sprite runAction:owlSleepAction];
            animationTag = WINK;
            active = NO;
        }
        else if (animationTag == WINK)
        {
            CCAction *owlWinkAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[self startAnimWithTag:WINK] times:2];
            [sprite runAction:owlWinkAction];
            animationTag = SLEEP;
            active = YES;
        }
    }
    else     //multiple position
    {
        if (animationTag == MOVE)
        {
            CCAction *owlMoveAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[self startAnimWithTag:MOVE] times:2];
            [sprite runAction:owlMoveAction];
            animationTag = WINK;
        }
        else if (animationTag == WINK)
        {
            CCAction *owlWinkAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[self startAnimWithTag:WINK] times:2];
            [sprite runAction:owlWinkAction];
            animationTag = MOVE;
        }
        
    }
    
}

- (void)owlAttackAnimation
{
    CCAction *owlMoveAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[self startAnimWithTag:MOVE]];
    [sprite runAction:owlMoveAction];
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

- (void)dealloc {
    [sprite release];
    [super dealloc];
}

@end
