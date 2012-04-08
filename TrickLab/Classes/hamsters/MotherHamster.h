//
//  MotherHamster.h
//  TrickLab
//
//  Created by Siyao Kong on 2/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

#define NUM_OF_ALTERNATIVE_ANIM 3

typedef enum {
    REGULAR,
    HANDKERCHIEF,
    TWIST,
    SWEAT,
    SAD,
    HAPPY,
}momActionTag;

@interface MotherHamster : GameObject {
    CCSprite *sprite;
}

- (id) initWithPos: (CGPoint)pos;
- (NSString *)startAnimWithTag:(int)tag;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *sprite;

@end
