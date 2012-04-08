//
//  SettingsLayer.m
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"
#import "LevelSelection.h"


#define SETTINGS_BG_SPRITE @"Default-Portrait.png"
#define SETTINGS_PARCHMENT_SPRITE @"parchment.png"
#define SETTINGS_TEXT_SPRITE @"settings_text.png"
#define MUSIC_BTN_FRM @"music_btn.png"
#define MUSIC_BTN_SEL_FRM @"music_btn_sel.png"
#define NO_MUSIC_BTN_FRM @"no_music_btn.png"
#define NO_MUSIC_BTN_SEL_FRM @"no_music_btn_sel.png"
#define SOUND_BTN_FRM @"sound_btn.png"
#define SOUND_BTN_SEL_FRM @"sound_btn_sel.png"
#define NO_SOUND_BTN_FRM @"no_sound_btn.png"
#define NO_SOUND_BTN_SEL_FRM @"no_sound_btn_sel.png"
#define LONG_BTN_FRM @"long_btn.png"
#define LONG_BTN_SEL_FRM @"long_btn_sel.png"
#define FNT_BTN @"Hobo Std"
#define FNT_HANDWRITE @"DK Porcupine Pickle"
#define FNT_SIZE_BTN 35
#define FNT_SIZE_HANDWRITE 40

@interface SettingsLayer (PrivateMethods)

- (void) resumeAndCleanup;
- (void) soundSwitch;
- (void) musicSwitch;

@end

@implementation SettingsLayer

@synthesize audioEngine;
@synthesize noMusicBtn;
@synthesize musicBtn;
@synthesize noSoundBtn;
@synthesize soundBtn;

- (id)init
{
    if ((self=[super init])) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        
        CCSprite *settingsLayerBg = [CCSprite spriteWithFile:SETTINGS_BG_SPRITE];
        settingsLayerBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:settingsLayerBg z:SETTINGSBG];         
        
        CCSprite *parchmentSprite = [CCSprite spriteWithFile:SETTINGS_PARCHMENT_SPRITE];
        parchmentSprite.position = ccp(screenSize.width/2, screenSize.height*0.6);
        [self addChild:parchmentSprite z:PARCHMENT];
        
        CCSprite *settingsLabel = [CCSprite spriteWithFile:SETTINGS_TEXT_SPRITE];
        settingsLabel.position = ccp(parchmentSprite.position.x, parchmentSprite.position.y*1.2);
        [self addChild:settingsLabel z:SETTINGSFONT];
        
        self.audioEngine = [SimpleAudioEngine sharedEngine];
        
        
        //music control button
        CCMenuItemSprite *visibleMusicBtn, *invisibleMusicBtn;
        self.noMusicBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:NO_MUSIC_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:NO_MUSIC_BTN_SEL_FRM]];
        self.musicBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:MUSIC_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:MUSIC_BTN_SEL_FRM]];
        if (audioEngine.backgroundMusicVolume == 0) {
            visibleMusicBtn = noMusicBtn;
            invisibleMusicBtn = musicBtn;
        }
        else {
            visibleMusicBtn = musicBtn;
            invisibleMusicBtn = noMusicBtn;
        }  
        CCMenuItemToggle *musicBtnMenu = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicSwitch) items:visibleMusicBtn, invisibleMusicBtn, nil];
        musicBtnMenu.position = ccp(screenSize.width*0.38, screenSize.height*0.62);  
         
        
        //sound control button
        CCMenuItemSprite *visibleSoundBtn, *invisibleSoundBtn;
        self.noSoundBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:NO_SOUND_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:NO_SOUND_BTN_SEL_FRM]];
        self.soundBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:SOUND_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:SOUND_BTN_SEL_FRM]];
        if (audioEngine.effectsVolume == 0) {
            visibleSoundBtn = noSoundBtn;
            invisibleSoundBtn = soundBtn;
        }
        else {
            visibleSoundBtn = soundBtn;
            invisibleSoundBtn = noSoundBtn;
        }        
        CCMenuItemToggle *soundBtnMenu = [CCMenuItemToggle itemWithTarget:self selector:@selector(soundSwitch) items:visibleSoundBtn, invisibleSoundBtn, nil];
        soundBtnMenu.position = ccp(screenSize.width*0.62, screenSize.height*0.62);
        
        //reset game stats button
        CCMenuItemSprite *resetBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            //reset game stats
            for (int i=0; i<LEVEL_MAX-1; i++) {
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"level%i_numOfCarrotCollected",i+1]];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"level%i_bestScore",i+1]];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"level%i_unlockLevel",i+1]];                
            }
            
        }]; 
        resetBtn.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
        
        //back button
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"back" fontName:FNT_HANDWRITE fontSize:FNT_SIZE_HANDWRITE];   
        backLabel.color = ccBLACK;
        CCMenuItemLabel *backBtn = [CCMenuItemLabel itemWithLabel:backLabel block:^(id sender){
            [self resumeAndCleanup];
        }];
        backBtn.position = ccp(screenSize.width*0.65, screenSize.height*0.4);
        
        CCMenu *menu = [CCMenu menuWithItems:musicBtnMenu, soundBtnMenu, resetBtn, backBtn, nil];
        menu.position = CGPointZero;    
        [self addChild:menu z:SETTINGSBTNMENU];
        
        //add font
        CCLabelTTF *resetLabel = [CCLabelTTF labelWithString:@"Reset Game" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        resetLabel.color = ccBLACK;
        resetLabel.position = ccp(resetBtn.position.x, resetBtn.position.y*0.99);
        [self addChild:resetLabel z:SETTINGSFONT];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void) resumeAndCleanup
{
    [self.parent removeChild:self cleanup:YES];
}

- (void) soundSwitch
{
    //play/stop sound            
    float effectsVolume = audioEngine.effectsVolume;
    effectsVolume = effectsVolume>0?0:1;   
    audioEngine.effectsVolume = effectsVolume;
    [[NSUserDefaults standardUserDefaults] setFloat:effectsVolume forKey:@"effectsVolume"];
    CCLOG(@"=======effectsVolume:%f",audioEngine.effectsVolume);
}

- (void) musicSwitch
{
    //play/stop music           
    float musicsVolume = audioEngine.backgroundMusicVolume;
    musicsVolume = musicsVolume>0?0:1;
    audioEngine.backgroundMusicVolume = musicsVolume;
    [[NSUserDefaults standardUserDefaults] setFloat:musicsVolume forKey:@"musicsVolume"];
    CCLOG(@"=======musicsVolume:%f",audioEngine.backgroundMusicVolume);
}

- (void) registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:-128 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)dealloc {
    [noSoundBtn release];
    [soundBtn release];
    [noMusicBtn release];
    [musicBtn release];
    [super dealloc];
}

@end
