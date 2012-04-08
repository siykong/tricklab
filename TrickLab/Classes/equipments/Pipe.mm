//
//  Pipe.m
//  TrickLab
//
//  Created by Siyao Kong on 2/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Pipe.h"

#define PIPE1_SPRITE @"pipe1.png"
#define PIPE2_SPRITE @"pipe2.png"
#define PIPE3_SPRITE @"pipe3.png"
#define PIPE4_SPRITE @"pipe4.png"
#define PIPE1_SHAPE @"pipe1_shape"
#define PIPE2_SHAPE @"pipe2_shape"
#define PIPE3_SHAPE @"pipe3_shape"
#define PIPE4_SHAPE @"pipe4_shape"
#define PIPE_ID @"PIPE"


@implementation Pipe

- (id) initWithPos: (CGPoint)pos shape:(int)shapeNum AndWorld: (b2World *)world
{
    if ((self=[super init])) {
        
        //set obj id
        self.objId = PIPE_ID;        
        
        //create body def for pipe
        b2BodyDef bodyDef;
        bodyDef.type = b2_staticBody;
        bodyDef.position = toMeters(pos);
        bodyDef.userData = self;
        
        //create shape and fixture for body
        switch (shapeNum) {
            case PIPE1:
                [self addSpriteAt:pos WithFile:PIPE1_SPRITE];  
                //create body for pipe
                body = world->CreateBody(&bodyDef);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:PIPE1_SHAPE];
                [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:PIPE1_SHAPE]];
                break;
            case PIPE2:
                [self addSpriteAt:pos WithFile:PIPE2_SPRITE]; 
                //create body for pipe
                body = world->CreateBody(&bodyDef);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:PIPE2_SHAPE];
                [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:PIPE2_SHAPE]];
                break;
            case PIPE3:
                [self addSpriteAt:pos WithFile:PIPE3_SPRITE];  
                //create body for pipe
                body = world->CreateBody(&bodyDef);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:PIPE3_SHAPE];
                [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:PIPE3_SHAPE]];
                break;
            case PIPE4:
                [self addSpriteAt:pos WithFile:PIPE4_SPRITE];  
                //create body for pipe
                body = world->CreateBody(&bodyDef);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:PIPE4_SHAPE];
                [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:PIPE4_SHAPE]];
                break;
                
            default:
                break;
        } 
                
    }
    return self;
}

- (void) scroll:(int)scrollDir
{
    switch (scrollDir) {
        case L:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(-step, 0));
            break;
        case R:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(step, 0));
            break;
            
        default:
            break;
    }
}

@end
