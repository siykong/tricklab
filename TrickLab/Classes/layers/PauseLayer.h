//
//  PauseLayer.h
//  TrickLab
//
//  Created by Siyao Kong on 1/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    PAUSEBG,
    PAUSEBTNMENU,
    PAUSEFONT,
    BESTSCORE,
}pauselayerItemTag;

@interface PauseLayer : CCLayer {
    
}

- (id) initWithLevelNum:(int)levelSel;

@end
