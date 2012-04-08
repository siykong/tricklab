//
//  Basket.m
//  TrickLab
//
//  Created by Chao Huang on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Bucket.h"

#define BUCKET_FRONT_SPRITE @"bucket_front.png"
#define BUCKET_BACK_SPRITE @"bucket_back.png"
#define BUCKET_SHAPE @"bucket_shape"
#define BUCKET_DAMPING 0.5
#define BUCKET_ID @"BUCKET"

@implementation Bucket

@synthesize spriteBack;
@synthesize jointWithBabyHamster;

- (id)initWithPos: (CGPoint)pos AndWorld: (b2World *)world
{
    self = [super init];
    if (self) {
        
        //set obj id
        self.objId = BUCKET_ID;
        
        //set obj front sprite
        [self addSpriteAt:pos WithFile:BUCKET_FRONT_SPRITE];
        
        //create body def for bucket
        b2BodyDef bodyDef;
        bodyDef.position = toMeters(pos);
        bodyDef.type = b2_dynamicBody;
        bodyDef.angularDamping = 0.1f;
        bodyDef.userData = self;//bucket front img
        bodyDef.linearDamping = BUCKET_DAMPING;
        
        //add bucket back img
        [self addSpriteAt:pos WithFile:BUCKET_BACK_SPRITE];        
        
        //create body for bucket
        body = world->CreateBody(&bodyDef);
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:BUCKET_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:BUCKET_SHAPE]];
        [spriteBack setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:BUCKET_SHAPE]];    
    }
    
    return self;
}

//add object sprite
- (void) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile
{
    //CCLOG(@"Bucket::addSpriteAt");
    
    if ([spriteFile isEqualToString:BUCKET_FRONT_SPRITE]){ //bucket front
        self.sprite = [CCSprite spriteWithFile:spriteFile];
        self.sprite.position = pos;
    }
    else { //bucket back
        self.spriteBack = [CCSprite spriteWithFile:spriteFile];
        self.spriteBack.position = pos;
    }
}

- (float) getBodyRotation{
    return body->GetAngle();
}

- (void) scroll:(int)scrollDir
{
    switch (scrollDir) {
        case L:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(-step, 0));
            spriteBack.position = ccpAdd(spriteBack.position, CGPointMake(-step, 0));
            break;
        case R:            
            sprite.position = ccpAdd(sprite.position, CGPointMake(step, 0));
            spriteBack.position = ccpAdd(spriteBack.position, CGPointMake(-step, 0));
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    [spriteBack release];
    [super dealloc];
}

@end
