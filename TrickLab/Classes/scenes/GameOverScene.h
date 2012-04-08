//
//  GameOverScene.h
//  TrickLab
//
//  Created by Siyao Kong on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelSelection.h"

typedef enum {
    GAMEOVERBG,
    GAMEOVERCARROTBAR,
    GAMEOVERBTNMENU,
    GAMEOVERFONT,
    SCORE,
    CARROTDROP,
    PARTICLE,
}gameoverItemTag;

@interface GameOverScene : CCLayer {
    CGSize screenSize;
    
    int displayScore;
    int finalScore;
    int preScore;
    int cradleBonus;
    int carrotBonus;
    float timeBonus;
    
    CCLabelTTF *scoreItemLabel;
    CCLabelTTF *scoreLabel;
}

+ (CCScene *) scene:(int)levelSel carrot:(int)num timeUsed:(float)timer;
- (id) initWithLevel:(int)levelSel carrot:(int)num timeUsed:(float)timer;

@property (retain) CCLabelTTF *scoreItemLabel;
@property (retain) CCLabelTTF *scoreLabel;

@end
