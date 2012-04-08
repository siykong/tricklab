//
//  Basket.h
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

@interface Bucket : PhysicsObject{
    //inherit ccsprite sprite from super class, which is spritefront for bucket
    CCSprite *spriteBack;   
    
    b2WeldJoint *jointWithBabyHamster;
}

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
- (float) getBodyRotation;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *spriteBack;
@property b2WeldJoint *jointWithBabyHamster;

@end
