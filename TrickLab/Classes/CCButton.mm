//
//  CCButton.m
//  TrickLab
//
//  Created by Siyao Kong on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CCButton.h"

@interface CCButton (PrivateMethods)

- (void) initWithNormalSpriteFrm:(NSString *)normalSpriteFrm selSpriteFrm:(NSString *)selSpriteFrm;

@end

@implementation CCButton

@synthesize normalSprite;
@synthesize selectedSprite;
@synthesize button;


+ (id) buttonWithPos:(CGPoint)pos normalSpriteFrm:(NSString *)normalSpriteFrm selSpriteFrm:(NSString *)selSpriteFrm replaceScene:(CCScene *)scene
{
    return [[[self alloc] initWithPos:pos normalSpriteFrm:normalSpriteFrm selSpriteFrm:selSpriteFrm replaceScene:scene] autorelease];
}

- (id) initWithPos:(CGPoint)pos normalSpriteFrm:(NSString *)normalSpriteFrm selSpriteFrm:(NSString *)selSpriteFrm replaceScene:(CCScene *)scene
{
    if ((self=[super init])) {
        
        [self initWithNormalSpriteFrm:normalSpriteFrm selSpriteFrm:selSpriteFrm];
        
        button = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite block:^(id sender){
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:scene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }];
        button.position = pos;
    }    
    
    return self;
}

- (void) initWithNormalSpriteFrm:(NSString *)normalSpriteFrm selSpriteFrm:(NSString *)selSpriteFrm
{
    normalSprite = [CCSprite spriteWithSpriteFrameName:normalSpriteFrm];
    selectedSprite = [CCSprite spriteWithSpriteFrameName:selSpriteFrm];
}

@end
