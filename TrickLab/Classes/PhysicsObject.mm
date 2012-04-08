//
//  PhysicsObjects.m
//  TrickLab
//
//  Created by Siyao Kong on 3/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"


@implementation PhysicsObject

@synthesize objId;
@synthesize sprite;
@synthesize body;

- (id)init {
    
    if ((self = [super init])) {
        
    }
    return self;
}

- (void) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile
{
    //CCLOG(@"PhysicsObject::addSpriteAt");
    
    self.sprite = [CCSprite spriteWithFile:spriteFile];
    self.sprite.position = pos;
}

- (void) addSpriteAt: (CGPoint)pos WithFrameName:(NSString *)spriteFramename
{
    //CCLOG(@"PhysicsObject::addSpriteAt");
    
    self.sprite = [CCSprite spriteWithSpriteFrameName:spriteFramename];
    self.sprite.position = pos;
}

- (void)dealloc {
    [objId release];
    [sprite release];
    [super dealloc];
}

@end
