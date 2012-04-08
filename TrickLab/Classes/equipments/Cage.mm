//
//  Cage.m
//  TrickLab
//
//  Created by Siyao Kong on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Cage.h"

#define CAGE_FRONT_CLOSE_SPRITE @"cage_front_close.png"
#define CAGE_BACK_CLOSE_SPRITE @"cage_back_close.png"
#define CAGE_FRONT_OPEN_SPRITE @"cage_front_open.png"
#define CAGE_BACK_OPEN_SPRITE @"cage_back_open.png"
#define CAGE_CONTOUR_SHAPE @"cage_contour_shape"
#define CAGE_BODY_SHAPE @"cage_body_shape"
#define CAGE_ID @"CAGE"

@implementation Cage

@synthesize spriteBack;
@synthesize open;

- (id) initWithPos: (CGPoint)pos AndWorld: (b2World *)world
{
    if ((self=[super init])) { 
        
        //set obj id
        self.objId = CAGE_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFile:CAGE_FRONT_CLOSE_SPRITE];
        
        //create body def for cage
        b2BodyDef bodyDef;
        bodyDef.type = b2_staticBody;
        bodyDef.position = toMeters(pos);
        bodyDef.userData = self;
        
        //add cage back img as normal sprite
        [self addSpriteAt:pos WithFile:CAGE_BACK_CLOSE_SPRITE];
        
        //create body for cage
        body = world->CreateBody(&bodyDef);
        
        //create shape for cage body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:CAGE_BODY_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:CAGE_BODY_SHAPE]];
        
        //create contour body for cage
        bodyDef.type = b2_staticBody;
        bodyDef.position = toMeters(pos);
        b2Body *contourBody = world->CreateBody(&bodyDef);
        
        //create shape for cage contour body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:contourBody forShapeName:CAGE_CONTOUR_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:CAGE_CONTOUR_SHAPE]];
        [spriteBack setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:CAGE_CONTOUR_SHAPE]];

        open = NO;
    }
    
    return self;
}

- (void) addSpriteAt: (CGPoint)pos WithFile:(NSString *)spriteFile
{
    //CCLOG(@"Cage::addSpriteAt");
    
    if ([spriteFile isEqualToString:CAGE_FRONT_CLOSE_SPRITE]){ //cage front
        self.sprite = [CCSprite spriteWithFile:spriteFile];
        self.sprite.position = pos;
    }
    else { //cage back
        self.spriteBack = [CCSprite spriteWithFile:spriteFile];
        self.spriteBack.position = pos;
    }
}

- (void) deactivate
{
    open = YES;
    //set to false to put body to sleep, true to wake it.
    body->SetAwake(NO);
    body->SetActive(NO);
    [sprite setTexture:[[CCTextureCache sharedTextureCache] addImage:CAGE_FRONT_OPEN_SPRITE]];
    [spriteBack setTexture:[[CCTextureCache sharedTextureCache] addImage:CAGE_BACK_OPEN_SPRITE]];
}

- (void) activate
{
    open = NO;
    body->SetAwake(YES);
    body->SetActive(YES);
    [sprite setTexture:[[CCTextureCache sharedTextureCache] addImage:CAGE_FRONT_CLOSE_SPRITE]];
    [spriteBack setTexture:[[CCTextureCache sharedTextureCache] addImage:CAGE_BACK_CLOSE_SPRITE]];
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

-(void)dealloc
{
    [spriteBack release];
    [super dealloc];
}


@end
