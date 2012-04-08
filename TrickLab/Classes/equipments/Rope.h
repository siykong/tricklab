//
//  Rope.h
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"

@interface Rope : NSObject {
    CGSize winSize;
    CCSprite** sprite;
    int32 segment;
    b2Body **ropeUnitBody;
    b2RopeJoint **joint;
    b2RopeJoint* headJoint;
    b2RopeJoint* tailJoint;
    
}

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world AndSegment:(int32) seg;
- (CCSprite *) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile WithIndex:(int32)index;
- (CCSprite *) getSpriteAtIndex:(int32)index;
- (void) attachToRopeHead: (b2Body *)objectBody World: (b2World *)world;
- (void)attachToRopeTail:(b2Body *)objectBody World: (b2World *)world;



@end
