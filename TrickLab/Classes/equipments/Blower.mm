//
//  Blower.m
//  TrickLab
//
//  Created by student on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Blower.h"

#define BLOWER_SPRITE @"blower_right_0.png"
#define BLOWER_ANIM @"blower_right"
#define BLOW_WIDTH 0.1*winSize.width


@implementation Blower

@synthesize sprite;
@synthesize angular;
@synthesize range;
@synthesize blowWidth;


- (id) initWithPos: (CGPoint)pos Angular: (float)a Range: (float)rg
{
    if ((self=[super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        //status
        angular  = a;
        range = rg;
        blowWidth = BLOW_WIDTH;
        
        //sprite
        self.sprite = [CCSprite spriteWithSpriteFrameName:BLOWER_SPRITE];
        self.sprite.position = pos;  
        self.sprite.rotation = -a;
    }   
    
    return self;
}

- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case BLOW:
            animName = BLOWER_ANIM;
            break;
            
        default:
            break;
    }
    
    [sprite setDisplayFrameWithAnimationName:animName index:0];
    
    return animName;
}

- (void) playParticleEffect
{
    //calc emit pos
    CGPoint blowerPos;
    float x = cosf(CC_DEGREES_TO_RADIANS(angular)) * sprite.contentSize.width/2;
    float y = sinf(CC_DEGREES_TO_RADIANS(angular)) * sprite.contentSize.width/2;
    if (angular >= -180 && angular <= 180) {
        blowerPos = CGPointMake((sprite.position.x+x), (sprite.position.y+y));
    }
 
    CCParticleSystem *particleBlower = [CCParticleSystemQuad particleWithFile:@"particle_blower.plist"];
    particleBlower.angle = angular;
    particleBlower.position = blowerPos;
    [sprite.parent addChild:particleBlower z:BLOWERTAG tag:BLOWERTAG];
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
