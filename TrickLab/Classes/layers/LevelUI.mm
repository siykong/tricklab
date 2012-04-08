//
//  Level1UI.m
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelUI.h"
#import "GameScene.h"
#import "PauseLayer.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

#define MENU_BTN_FRN @"menu_btn.png"
#define MENU_BTN_SEL_FRM @"menu_btn_sel.png"
#define REPLAY_BTN_FRM @"replay_btn.png"
#define REPLAY_BTN_SEL_FRM @"replay_btn_sel.png"


@implementation LevelUI

- (id) initWithLevelNumber:(int)levelSel
{
    if ((self=[super init])) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];   
                
        //replay button
        CCMenuItemSprite *replayBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:REPLAY_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:REPLAY_BTN_SEL_FRM] block:^(id sender){
            //resume auto rotate
            [(AppController *)[[CCDirector sharedDirector] delegate] setIsAccelerometerEnabled:NO];
            CCLOG(@"LevelUI::replayBtn::levelSel:%i",levelSel);
            CCScene *gameScene = [[(GameScene *)[GameScene alloc] initWithLevelNumber:levelSel] autorelease];
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:gameScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }];
        replayBtn.position = ccp(screenSize.width*0.75f, screenSize.height*0.975f);
        
        //menu button (pause game scene)
        CCMenuItemSprite *menuBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:MENU_BTN_FRN] selectedSprite:[CCSprite spriteWithSpriteFrameName:MENU_BTN_SEL_FRM] block:^(id sender){
            //pause music
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
            //pause game scene
            [[CCDirector sharedDirector] pause];
            PauseLayer *pause = [[(PauseLayer *)[PauseLayer alloc] initWithLevelNum:levelSel] autorelease];
            pause.position = CGPointZero;
            [self.parent addChild:pause z:PAUSE tag:PAUSE];
        }];
        menuBtn.position = ccp(screenSize.width*0.9f, screenSize.height*0.975f);           
        
        CCMenu *menu = [CCMenu menuWithItems:replayBtn, menuBtn, nil];
        menu.position = CGPointZero;
        [self addChild:menu];         

        self.isTouchEnabled = YES;

    }
    
    return self;
}

@end
