//
//  PauseLayer.m
//  TrickLab
//
//  Created by Siyao Kong on 1/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PauseLayer.h"
#import "GameScene.h"
#import "LevelSelection.h"
#import "CCTouchDispatcher.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

#define PAUSE_BG_SPRITE @"pause_layer_bg.png"
#define LONG_BTN_FRM @"long_btn.png"
#define LONG_BTN_SEL_FRM @"long_btn_sel.png"
#define FNT_BTN @"Hobo Std"
#define FNT_SIZE_BTN 35
#define FNT_HANDWRITE @"DK Porcupine Pickle"
#define FNT_SIZE_HANDWRITE 35


@interface PauseLayer (PrivateMethods)

- (void) resumeAndCleanup;

@end


@implementation PauseLayer

- (id) initWithLevelNum:(int)levelSel
{
    if ((self=[super init])) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *pauseLayerBg = [CCSprite spriteWithFile:PAUSE_BG_SPRITE];
        pauseLayerBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:pauseLayerBg z:PAUSEBG];
        
        //show best score
        int bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"level%i_bestScore",levelSel]];
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"best score: %i",bestScore] fontName:FNT_HANDWRITE fontSize:FNT_SIZE_HANDWRITE];   
        scoreLabel.color = ccBLACK;
        scoreLabel.position = ccp(screenSize.width*0.8, screenSize.height*0.9);
        [self addChild:scoreLabel z:BESTSCORE];
 
        //resume button
        CCMenuItemSprite *resumeBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            //resume music
            [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
            [self resumeAndCleanup];
        }];
        resumeBtn.position = ccp(screenSize.width/2, screenSize.height/2); 
        
        //next level button
        CCMenuItemSprite *nextLevelBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){   
            CCLOG(@"GameScene::nextBtn::levelSel:%i",levelSel+1);
            //resume auto rotate
            [(AppController *)[[CCDirector sharedDirector] delegate] setIsAccelerometerEnabled:NO]; 
            
            CCScene *nextScene;
            if (levelSel == LEVEL_MAX - 1) {
                //stop music
                [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];                
                nextScene = [LevelSelection scene];
            }
            else {
                //resume music
                [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
                //replace scene with next level            
                nextScene = [[(GameScene *)[GameScene alloc] initWithLevelNumber:levelSel+1] autorelease];
            }                        
            [self resumeAndCleanup];            
            //replace scene with next level
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:nextScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
             
        }]; 
        nextLevelBtn.position = ccp(screenSize.width/2, screenSize.height*0.41); 
        
        //select level button
        CCMenuItemSprite *selLevelBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            //resume auto rotate
            [(AppController *)[[CCDirector sharedDirector] delegate] setIsAccelerometerEnabled:NO];
            //stop music
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            
            CCScene *levelSelScene = [LevelSelection node];
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:levelSelScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
            [self resumeAndCleanup];
        }]; 
        selLevelBtn.position = ccp(screenSize.width/2, screenSize.height*0.32); 
        
        CCMenu *menu = [CCMenu menuWithItems:resumeBtn, nextLevelBtn, selLevelBtn, nil];
        menu.position = CGPointZero;
        
        [self addChild:menu z:PAUSEBTNMENU];
        
        //add font
        CCLabelTTF *resumeLabel = [CCLabelTTF labelWithString:@"Continue" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        resumeLabel.color = ccBLACK;
        resumeLabel.position = ccp(resumeBtn.position.x, resumeBtn.position.y*0.99);
        [self addChild:resumeLabel z:PAUSEFONT];
        
        CCLabelTTF *nextLevelLabel = [CCLabelTTF labelWithString:@"Next Level" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        nextLevelLabel.color = ccBLACK;
        nextLevelLabel.position = ccp(nextLevelBtn.position.x, nextLevelBtn.position.y*0.99);
        [self addChild:nextLevelLabel z:PAUSEFONT];
        
        CCLabelTTF *levelSelLabel = [CCLabelTTF labelWithString:@"Select Level" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        levelSelLabel.color = ccBLACK;
        levelSelLabel.position = ccp(selLevelBtn.position.x, selLevelBtn.position.y*0.99);
        [self addChild:levelSelLabel z:PAUSEFONT];
         
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void) resumeAndCleanup
{
    [[CCDirector sharedDirector] resume];
    [self.parent removeChild:self cleanup:YES];
}

- (void) registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:-128 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}


@end
