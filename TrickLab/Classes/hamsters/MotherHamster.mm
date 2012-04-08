//
//  MotherHamster.m
//  TrickLab
//
//  Created by Siyao Kong on 2/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MotherHamster.h"

#define MOM_REGULAR_0_FRM @"mom_regular_0.png"
#define MOM_REGULAR_ANIM @"mom_regular"
#define MOM_SWEAT_ANIM @"mom_sweat"
#define MOM_SAD_ANIM @"mom_sad"
#define MOM_HAPPY_ANIM @"mom_happy"
#define MOM_TWIST_ANIM @"mom_twist"
#define MOM_HANDKERCHIEF_ANIM @"mom_handkerchief"


@interface MotherHamster (PrivateMethods)

- (CCSprite *) addSpriteAt: (CGPoint)pos WithFrameName:(NSString *)spriteFramename;

@end

@implementation MotherHamster

@synthesize sprite;

- (id) initWithPos: (CGPoint)pos
{
    if ((self=[super init])) {
        
        self.sprite = [self addSpriteAt:pos WithFrameName:MOM_REGULAR_0_FRM];
        sprite.position = pos;
        
    }
    
    return self;
}

//add object sprite
- (CCSprite *) addSpriteAt: (CGPoint)pos WithFrameName:(NSString *)spriteFramename
{
    //CCLOG(@"MotherHamster::addSpriteAt");
    
    self.sprite = [CCSprite spriteWithSpriteFrameName:spriteFramename];
    self.sprite.position = pos;
    
    return sprite;
}

- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case SWEAT:
            animName = MOM_SWEAT_ANIM;
            break;
        case SAD:
            animName = MOM_SAD_ANIM;
            break;
        case HAPPY:
            animName = MOM_HAPPY_ANIM;
            break;
        case REGULAR:
            animName = MOM_REGULAR_ANIM;
            break;
        case HANDKERCHIEF:
            animName = MOM_HANDKERCHIEF_ANIM;
            break;
        case TWIST:
            animName = MOM_TWIST_ANIM;
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

- (void)dealloc {
    [sprite release];
    [super dealloc];
}

@end
