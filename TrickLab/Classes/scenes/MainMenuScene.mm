//
//  MainMenuScene.m
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"
#import "CCAnimationCache+FileLoad.h"
#import "SimpleAudioEngine+SoundBatchPreload.h"



@implementation MainMenuScene

- (id) init
{
    if ((self=[super init])) {
   
        //load sprite frames
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animation_obj.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"credit.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ui.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tip.plist"];
        
        //load animation from plist
        [[CCAnimationCache sharedAnimationCache] addAnimationWithFile:@"animation_info.plist"];
        
        //load physics objects from plist
        [[GB2ShapeCache sharedShapeCache]addShapesWithFile:@"shapedefs.plist"];
        
        //load music/sfx
        [[SimpleAudioEngine sharedEngine] preloadFromFile:@"audio_info.plist"];
        
        //set default volume for sfx and music
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        audioEngine.effectsVolume = [[NSUserDefaults standardUserDefaults] floatForKey:@"effectsVolume"];
        audioEngine.backgroundMusicVolume = [[NSUserDefaults standardUserDefaults] floatForKey:@"musicsVolume"];
        
        //layer for play/settings button
        MainMenuLayer *menuLayer = [MainMenuLayer node];
        [self addChild:menuLayer z:MENU tag:MENU];         
        
    }
    return self;
}

@end
