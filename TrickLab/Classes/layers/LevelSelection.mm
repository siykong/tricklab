//
//  LevelSelection.m
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelSelection.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "SimpleAudioEngine.h"

#define LEVEL_SEL_BG_SPRITE @"level_sel_bg.png"
#define BACK_BTN_FRM @"back_btn.png"
#define BACK_BTN_SEL_FRM @"back_btn_sel.png"
#define LOCK_LEVEL_BTN_0_FRM @"btn_lock_0.png"
#define LOCK_LEVEL_BTN_ANIM @"btn_lock"
#define LEVEL_BTN_DAY_FRM @"btn_day.png"
#define LEVEL_BTN_NIGHT_FRM @"btn_night.png"
#define LEVEL_BTN_CARROT0_FRM @"level_btn_carrot_0.png"
#define LEVEL_BTN_SEL_CARROT0_FRM @"level_btn_carrot_0_sel.png"
#define LEVEL_BTN_CARROT1_FRM @"level_btn_carrot_1.png"
#define LEVEL_BTN_SEL_CARROT1_FRM @"level_btn_carrot_1_sel.png"
#define LEVEL_BTN_CARROT2_FRM @"level_btn_carrot_2.png"
#define LEVEL_BTN_SEL_CARROT2_FRM @"level_btn_carrot_2_sel.png"
#define LEVEL_BTN_CARROT3_FRM @"level_btn_carrot_3.png"
#define LEVEL_BTN_SEL_CARROT3_FRM @"level_btn_carrot_3_sel.png"
#define FNT_BTN @"Hobo Std"
#define FNT_SIZE_BTN 40
#define MUSIC_LEVEL_BG @"level_bg.wav"

@interface LevelSelection (PrivateMethods)

- (void) transitionScene:(int)levelSel;
- (void) playLockBtnAnim:(int)levelSel;
- (void) pressBtn:(int)levelSel;

@end

@implementation LevelSelection

@synthesize levelSelected;


+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    LevelSelection *levelSel = [LevelSelection node];
    [scene addChild: levelSel];
	
	return scene;
}

- (id) init
{
    if( (self=[super init])) {
        CCLOG(@"level selection init");
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //init levelSelected
        levelSelected = LEVEL_INVALID;
        
        //level selection background
        CCSprite *levelSelBg = [CCSprite spriteWithFile:LEVEL_SEL_BG_SPRITE];
        levelSelBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:levelSelBg z:LEVELSELBG];        
        
        //back button (back to main menu)
        CCMenuItemSprite *backBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:BACK_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:BACK_BTN_SEL_FRM] block:^(id sender){
            CCLOG(@"back button");
            CCScene *mainmenuScene = [MainMenuScene node];
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:mainmenuScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }];
        backBtn.position = ccp(screenSize.width*0.1f, screenSize.height*0.08f);
        
        //set default value for lock level flag for level1
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"level1_unlockLevel"];
        
        //store num of carrots collected in each level and decide which btn sprite to use
        for (int i=0; i<LEVEL_MAX-1; i++) {

            numOfCarrotCollected[i] = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"level%i_numOfCarrotCollected",i+1]]; 
            
            //lock level or not
            unlockLevel = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"level%i_unlockLevel",i+1]];
            if (!unlockLevel) {
                levelBtn[i] = LOCK_LEVEL_BTN_0_FRM;
                levelSelBtn[i] = LOCK_LEVEL_BTN_0_FRM;
            }
            else {
                switch (numOfCarrotCollected[i]) {
                    case 0:
                        levelBtn[i] = LEVEL_BTN_CARROT0_FRM;
                        levelSelBtn[i] = LEVEL_BTN_SEL_CARROT0_FRM;
                        break;
                    case 1:
                        levelBtn[i] = LEVEL_BTN_CARROT1_FRM;
                        levelSelBtn[i] = LEVEL_BTN_SEL_CARROT1_FRM;
                        break;
                    case 2:
                        levelBtn[i] = LEVEL_BTN_CARROT2_FRM;
                        levelSelBtn[i] = LEVEL_BTN_SEL_CARROT2_FRM;
                        break;
                    case 3:
                        levelBtn[i] = LEVEL_BTN_CARROT3_FRM;
                        levelSelBtn[i] = LEVEL_BTN_SEL_CARROT3_FRM;
                        break;
                        
                    default:
                        break;
                }
            }           
        }
        
        //level selection buttons
        btnSprite[LEVEL_1-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_1-1]];
        CCMenuItemSprite *level1Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_1-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_1-1]] block:^(id sender){
            [self pressBtn:LEVEL_1];
        }];
        level1Btn.position = ccp(screenSize.width*0.2f, screenSize.height*0.7f);
        
        btnSprite[LEVEL_2-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_2-1]];
        CCMenuItemSprite *level2Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_2-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_2-1]] block:^(id sender){
            [self pressBtn:LEVEL_2];
        }];
        level2Btn.position = ccp(screenSize.width*0.4f, screenSize.height*0.7f);
        
        btnSprite[LEVEL_3-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_3-1]];
        CCMenuItemSprite *level3Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_3-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_3-1]] block:^(id sender){
            [self pressBtn:LEVEL_3];
        }];
        level3Btn.position = ccp(screenSize.width*0.6f, screenSize.height*0.7f);
        
        btnSprite[LEVEL_4-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_4-1]];
        CCMenuItemSprite *level4Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_4-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_4-1]] block:^(id sender){
            [self pressBtn:LEVEL_4];
        }];
        level4Btn.position = ccp(screenSize.width*0.8f, screenSize.height*0.7f);
        
        btnSprite[LEVEL_5-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_5-1]];
        CCMenuItemSprite *level5Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_5-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_5-1]] block:^(id sender){
            [self pressBtn:LEVEL_5];
        }];
        level5Btn.position = ccp(screenSize.width*0.2f, screenSize.height*0.5f);
        
        btnSprite[LEVEL_6-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_6-1]];
        CCMenuItemSprite *level6Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_6-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_6-1]] block:^(id sender){
            [self pressBtn:LEVEL_6];
        }];
        level6Btn.position = ccp(screenSize.width*0.4f, screenSize.height*0.5f);
        
        btnSprite[LEVEL_7-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_7-1]];
        CCMenuItemSprite *level7Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_7-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_7-1]] block:^(id sender){
            [self pressBtn:LEVEL_7];
        }];
        level7Btn.position = ccp(screenSize.width*0.6f, screenSize.height*0.5f);
        
        btnSprite[LEVEL_8-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_8-1]];
        CCMenuItemSprite *level8Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_8-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_8-1]] block:^(id sender){
            [self pressBtn:LEVEL_8];            
        }];
        level8Btn.position = ccp(screenSize.width*0.8f, screenSize.height*0.5f);
        
        btnSprite[LEVEL_9-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_9-1]];
        CCMenuItemSprite *level9Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_9-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_9-1]] block:^(id sender){
            [self pressBtn:LEVEL_9];
        }];
        level9Btn.position = ccp(screenSize.width*0.2f, screenSize.height*0.3f);
        
        btnSprite[LEVEL_10-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_10-1]];
        CCMenuItemSprite *level10Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_10-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_10-1]] block:^(id sender){
            [self pressBtn:LEVEL_10];
        }];
        level10Btn.position = ccp(screenSize.width*0.4f, screenSize.height*0.3f);
        
        btnSprite[LEVEL_11-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_11-1]];
        CCMenuItemSprite *level11Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_11-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_11-1]] block:^(id sender){
            [self pressBtn:LEVEL_11];
        }];
        level11Btn.position = ccp(screenSize.width*0.6f, screenSize.height*0.3f);
        
        btnSprite[LEVEL_12-1] = [CCSprite spriteWithSpriteFrameName:levelBtn[LEVEL_12-1]];
        CCMenuItemSprite *level12Btn = [CCMenuItemSprite itemWithNormalSprite:btnSprite[LEVEL_12-1] selectedSprite:[CCSprite spriteWithSpriteFrameName:levelSelBtn[LEVEL_12-1]] block:^(id sender){
            [self pressBtn:LEVEL_12];
        }];
        level12Btn.position = ccp(screenSize.width*0.8f, screenSize.height*0.3f);
        
        CCMenu *menu = [CCMenu menuWithItems:backBtn, level1Btn, level2Btn, level3Btn, level4Btn, level5Btn, level6Btn, level7Btn, level8Btn, level9Btn, level10Btn, level11Btn, level12Btn, nil];
        menu.position = CGPointZero;
        [self addChild:menu z:LEVELSELBTNMENU];       
        
        //add font
        CCLabelTTF *level1Label = [CCLabelTTF labelWithString:@"1" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level1Label.color = ccBLACK;
        level1Label.position = ccp(level1Btn.position.x, level1Btn.position.y*1.03);
        [self addChild:level1Label z:LEVELSELFONT];
        
        CCLabelTTF *level2Label = [CCLabelTTF labelWithString:@"2" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level2Label.color = ccBLACK;
        level2Label.position = ccp(level2Btn.position.x, level2Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level2_unlockLevel"]) {
            [self addChild:level2Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level3Label = [CCLabelTTF labelWithString:@"3" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level3Label.color = ccBLACK;
        level3Label.position = ccp(level3Btn.position.x, level3Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level3_unlockLevel"]) {
            [self addChild:level3Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level4Label = [CCLabelTTF labelWithString:@"4" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level4Label.color = ccBLACK;
        level4Label.position = ccp(level4Btn.position.x, level4Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level4_unlockLevel"]) {
            [self addChild:level4Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level5Label = [CCLabelTTF labelWithString:@"5" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level5Label.color = ccBLACK;
        level5Label.position = ccp(level5Btn.position.x, level5Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level5_unlockLevel"]) {
            [self addChild:level5Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level6Label = [CCLabelTTF labelWithString:@"6" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level6Label.color = ccBLACK;
        level6Label.position = ccp(level6Btn.position.x, level6Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level6_unlockLevel"]) {
            [self addChild:level6Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level7Label = [CCLabelTTF labelWithString:@"7" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level7Label.color = ccBLACK;
        level7Label.position = ccp(level7Btn.position.x, level7Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level7_unlockLevel"]) {
            [self addChild:level7Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level8Label = [CCLabelTTF labelWithString:@"8" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level8Label.color = ccBLACK;
        level8Label.position = ccp(level8Btn.position.x, level8Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level8_unlockLevel"]) {
            [self addChild:level8Label z:LEVELSELFONT];
        }        
        
        CCLabelTTF *level9Label = [CCLabelTTF labelWithString:@"9" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level9Label.color = ccBLACK;
        level9Label.position = ccp(level9Btn.position.x, level9Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level9_unlockLevel"]) {
            [self addChild:level9Label z:LEVELSELFONT];
        }
        
        CCLabelTTF *level10Label = [CCLabelTTF labelWithString:@"10" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        level10Label.color = ccBLACK;
        level10Label.position = ccp(level10Btn.position.x, level10Btn.position.y*1.03);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level10_unlockLevel"]) {
            [self addChild:level10Label z:LEVELSELFONT];
        }
        
        CCSprite *dayLevelSprite = [CCSprite spriteWithSpriteFrameName:LEVEL_BTN_DAY_FRM];
        dayLevelSprite.position = level11Btn.position;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level11_unlockLevel"]) {
            [self addChild:dayLevelSprite z:LEVELSELFONT];
        }
        
        CCSprite *nightLevelSprite = [CCSprite spriteWithSpriteFrameName:LEVEL_BTN_NIGHT_FRM];
        nightLevelSprite.position = level12Btn.position;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"level12_unlockLevel"]) {
            [self addChild:nightLevelSprite z:LEVELSELFONT];
        }
        
        self.isTouchEnabled = YES;
        
    }
    
    return self;
}

- (void) transitionScene:(int)levelSel
{
    //play bg music
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:MUSIC_LEVEL_BG];
    
    CCScene *gameScene = [[(GameScene *)[GameScene alloc] initWithLevelNumber:levelSel] autorelease];
    CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:gameScene withColor:ccWHITE];
    [[CCDirector sharedDirector] replaceScene:transitionScene];
}

- (void) playLockBtnAnim:(int)levelSel
{
    CCAction *action = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:LOCK_LEVEL_BTN_ANIM times:1];
    [btnSprite[levelSel] runAction:action];
}

- (void) pressBtn:(int)levelSel
{
    CCLOG(@"level%i button",levelSel);
    unlockLevel = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"level%i_unlockLevel", levelSel]];
    if (unlockLevel) {
        //transition to game scene
        [self transitionScene:levelSel];
    }
    else {
        [self playLockBtnAnim:levelSel-1];
    } 
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"touch at levelselection");
}

- (void)dealloc
{
  
    [super dealloc];
}

@end
