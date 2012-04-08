//
//  Blower.h
//  TrickLab
//
//  Created by student on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"
#import "GameScene.h"

typedef enum {
    BLOW,
}blowerActionTag;

@interface Blower : GameObject{
    CCSprite *sprite;
    
    float range;
    float blowWidth;
    float angular;
    
}

- (id) initWithPos: (CGPoint)pos Angular: (float)a Range: (float)rg;
- (NSString *)startAnimWithTag:(int)tag;
- (void) playParticleEffect;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *sprite;
@property float angular;
@property float range;
@property float blowWidth;

@end
