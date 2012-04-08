//
//  Pipe.h
//  TrickLab
//
//  Created by Siyao Kong on 2/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

#define PIPE1 0
#define PIPE2 1
#define PIPE3 2
#define PIPE4 3

@interface Pipe : PhysicsObject {
    
}

- (id) initWithPos: (CGPoint)pos shape:(int)shapeNum AndWorld: (b2World *)world;
- (void) scroll:(int)scrollDir;

@end
