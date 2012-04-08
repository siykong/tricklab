//
//  Cradle.h
//  TrickLab
//
//  Created by Siyao Kong on 2/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"

typedef enum {
    SWING,
    SUCCEED,
}cradleActionTag;

@interface Cradle : PhysicsObject {

}

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
- (NSString *)startAnimWithTag:(int)tag;
- (void) scroll:(int)scrollDir;

@end
