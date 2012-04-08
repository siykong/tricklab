//
//  SettingsLayer.h
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

typedef enum {
    SETTINGSBG,
    PARCHMENT,
    SETTINGSBTNMENU,
    SETTINGSFONT,
}settingsItemTag;

@interface SettingsLayer : CCLayer {
    SimpleAudioEngine *audioEngine;
    
    CCMenuItemSprite *noSoundBtn;
    CCMenuItemSprite *soundBtn;
    
    CCMenuItemSprite *noMusicBtn;
    CCMenuItemSprite *musicBtn;
}

@property (retain) SimpleAudioEngine *audioEngine;
@property (retain) CCMenuItemSprite *noSoundBtn;
@property (retain) CCMenuItemSprite *soundBtn;
@property (retain) CCMenuItemSprite *noMusicBtn;
@property (retain) CCMenuItemSprite *musicBtn;

@end
