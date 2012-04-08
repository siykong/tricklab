//
//  PhysicsObjects.h
//  TrickLab
//
//  Created by Siyao Kong on 3/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

@interface PhysicsObject : GameObject {
    NSString *objId;
    CCSprite *sprite;
    b2Body *body;
}

- (void) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile;
- (void) addSpriteAt: (CGPoint)pos WithFrameName:(NSString *)spriteFramename;

@property (retain) NSString *objId;
@property (retain) CCSprite *sprite;
@property b2Body *body;

@end
