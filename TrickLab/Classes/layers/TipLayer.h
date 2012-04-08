//
//  TipLayer.h
//  TrickLab
//
//  Created by Siyao Kong on 3/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    TIP_BG,
    TIP_CONT,
    LABEL,
}tipTag;

@interface TipLayer : CCLayer {
    CCSprite *parchmentSprite;
}

- (id) initWithLevelNumber:(int)levelSel;

@property (retain) CCSprite *parchmentSprite;

@end
