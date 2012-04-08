//
//  Stone.m
//  TrickLab
//
//  Created by Chao Huang on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Stone.h"

#define STONE_SPRITE @"stone.png"
#define STONE_SHAPE @"stone_shape"
#define STONE_ID @"STONE"

@implementation Stone


- (id)initWithPos: (CGPoint)pos AndWorld: (b2World *)world;
{
    self = [super init];
    if (self) {
        
        //set obj id
        self.objId = STONE_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFile:STONE_SPRITE];

        //create body def for stone
        b2BodyDef bodyDef;
        bodyDef.position = toMeters(pos);
        bodyDef.type = b2_staticBody;
        bodyDef.userData = self;
        
        //create body for stone
        body = world->CreateBody(&bodyDef);
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:STONE_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:STONE_SHAPE]];
         
    }
    
    return self;
    
}

@end
