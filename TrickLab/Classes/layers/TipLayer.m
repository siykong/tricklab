//
//  TipLayer.m
//  TrickLab
//
//  Created by Siyao Kong on 3/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TipLayer.h"
#import "CCTouchDispatcher.h"

#define TIP_PARCHMENT_SPRITE @"parchment.png"
#define FNT_HANDWRITE @"DK Porcupine Pickle"
#define FNT_SIZE_HANDWRITE 40

@implementation TipLayer

@synthesize parchmentSprite;

- (id) initWithLevelNumber:(int)levelSel
{
    if ((self=[super init])) {
        
        //1:tip; 0:no tip
        int levelTip[] = {1,1,1,1,1,0,1,1,0,0,1,0};
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        if (levelTip[levelSel-1] == 1) {
            self.parchmentSprite = [CCSprite spriteWithFile:TIP_PARCHMENT_SPRITE];
            parchmentSprite.position = ccp(screenSize.width/2, screenSize.height/2);
            [self addChild:parchmentSprite z:TIP_BG tag:TIP_BG]; 
            
            CCSprite *tip = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"tip_level_%i.png",levelSel]];
            tip.position = ccp(parchmentSprite.position.x, parchmentSprite.position.y*0.95);
            [self addChild:tip z:TIP_CONT tag:TIP_CONT];
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap to continue" fontName:FNT_HANDWRITE fontSize:FNT_SIZE_HANDWRITE];   
            label.color = ccBLACK;
            label.position = ccp(parchmentSprite.position.x, parchmentSprite.position.y*1.44);
            [self addChild:label z:LABEL tag:LABEL];
            
            id fadeout = [CCFadeOut actionWithDuration:2];
            [label runAction:fadeout];
            
            self.isTouchEnabled = YES;
        }        
    }
    
    return self;
}

- (CGPoint) locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (void) registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:-128 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{    
    CGPoint touchPoint = [self locationFromTouch:touch];

    if (([self getChildByTag:TIP_BG] != nil) && CGRectContainsPoint(parchmentSprite.boundingBox, touchPoint)) {
        CCLOG(@"======tip");
        [self removeAllChildrenWithCleanup:YES];
        return YES;
    }
    
    return NO;
}

- (void)dealloc
{
    [parchmentSprite release];
    [super dealloc];
}

@end
