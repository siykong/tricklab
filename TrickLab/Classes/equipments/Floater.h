//
//  Floater.h
//  TrickLab
//
//  Created by Siyao Kong on 1/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

typedef enum
{
    UP,
    DOWN,
    LEFT,
    RIGHT,
    STATIC,
}floaterAutoMoveDir;

typedef enum {
    ROTATE,
}floaterActionTag;

@interface Floater : PhysicsObject {    
    b2WeldJoint *jointWithBabyHamster;
    bool startContactWithBabyHamster;
    bool endContactWithBabyHamster;
    int dir;
    int originDir;
    CGPoint originPos;//for auto move
    bool steadyImpluse; //check if babyhamster reach the verticle speed
}

- (id) initWithPos: (CGPoint)pos move:(int)moveDir AndWorld: (b2World *)world;
- (void) updateStatusWithVel:(float)babyVel mass:(float)babyMass;
- (NSString *)startAnimWithTag:(int)tag;
- (void) autoMoveWithDistance:(int)dist;
- (void) scroll:(int)scrollDir;

@property b2WeldJoint *jointWithBabyHamster;
@property bool startContactWithBabyHamster;
@property bool endContactWithBabyHamster;

@end
