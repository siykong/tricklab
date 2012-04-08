//
//  MainMenuLayer.h
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    MAINMENUBG,
    MAINMENUBTNMENU,
    MAINMENUFONT,
    CREDITPARCHMENT,
    CREDIT,
    CARROTGLOW,
    GROUND,
    ARROW_UP,
    ARROW_DOWN,
}mainmenuItemTag;

@interface MainMenuLayer : CCLayer {
    CCSprite *arrowUp;
    CCSprite *arrowDown;
    CCSprite *carrotSprite;
    CCSprite *parchmentSprite;
    bool creditOpen;
    CGPoint carrotOriginPos;
    
    CCSprite *credit;
    CCSprite *creditSprite1;
    CCSprite *creditSprite2;
    bool flagForCredit1;
    bool flagForCredit2;
    
    CGSize screenSize;
}

@property (retain) CCSprite *arrowUp;
@property (retain) CCSprite *arrowDown;
@property (retain) CCSprite *parchmentSprite;
@property (retain) CCSprite *carrotSprite;
@property (retain) CCSprite *creditSprite1;
@property (retain) CCSprite *creditSprite2;
@property (retain) CCSprite *credit;

@end
