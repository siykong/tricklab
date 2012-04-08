//
//  LevelSelection.h
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    LEVELSELBG,
    LEVELSELBTNMENU,
    LEVELSELFONT,
}levelSelItemTag;

typedef enum {
    LEVEL_INVALID = 0,
    LEVEL_1,
    LEVEL_2,
    LEVEL_3,
    LEVEL_4,
    LEVEL_5,
    LEVEL_6,
    LEVEL_7,
    LEVEL_8,
    LEVEL_9,
    LEVEL_10,
    LEVEL_11,
    LEVEL_12,
    LEVEL_MAX,
}levelSelTag;

@interface LevelSelection : CCLayer {
    int levelSelected;
    int numOfCarrotCollected[LEVEL_MAX-1];
    NSString *levelBtn[LEVEL_MAX-1];
    NSString *levelSelBtn[LEVEL_MAX-1];
    bool unlockLevel;
    CCSprite *btnSprite[LEVEL_MAX-1];
}

+ (CCScene *) scene;

@property int levelSelected;


@end
