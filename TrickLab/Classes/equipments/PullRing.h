//
//  PullRing.h
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

@interface PullRing : PhysicsObject{
    
    b2MouseJoint* mouseJoint;
}

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
- (void)createMouseJoint: (CGPoint) location GroundBody:(b2Body*)groundBody World:(b2World *)world;
- (void)modifyMouseJoint: (CGPoint) location;
- (void)destroyMouseJointWorld:(b2World *)world;
- (void) scroll:(int)scrollDir;

@end
