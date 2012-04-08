//
//  Carrot.h
//  TrickLab
//
//  Created by Siyao Kong on 2/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

typedef enum {
    CARROT1,
    CARROT2,
    CARROT3,
}carrotActionTag;

@interface Carrot : GameObject {
    CCSprite *sprite1;
    CCSprite *sprite2;
    CCSprite *sprite3;
    
    bool sprite1Collected;
    bool sprite2Collected;
    bool sprite3Collected;

    int numOfCarrotCollected;
}

- (id) initWithPos1: (CGPoint)pos1 Pos2:(CGPoint)pos2 Pos3:(CGPoint)pos3;
- (NSString *)startAnimWithTag:(int)tag;
- (void)changeCarrotBar:(CCSprite *)sprite byFrame:(CCSpriteFrame *)frame;
- (void) scroll:(int)scrollDir;


@property (retain) CCSprite *sprite1;
@property (retain) CCSprite *sprite2;
@property (retain) CCSprite *sprite3;
@property bool sprite1Collected;
@property bool sprite2Collected;
@property bool sprite3Collected;
@property int numOfCarrotCollected;

@end
