//
//  Cage.h
//  TrickLab
//
//  Created by Siyao Kong on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

@interface Cage : PhysicsObject {
    //inherit ccsprite sprite from super class, which is spritefront for cage
    CCSprite *spriteBack;  
    
    bool open;
}

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
- (void) deactivate;
- (void) activate;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *spriteBack;
@property bool open;

@end
