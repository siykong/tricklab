//
//  Hole.m
//  TrickLab
//
//  Created by Chao Huang on 2/12/12.
//  Copyright (c) 2012 USC. All rights reserved.
//

#import "Hole.h"

#define HOLE_SPRITE @"hole.png"
#define TELEPORT_REGION_RADIUS sprite1.contentSize.height/2
#define IMPULSE_REGION_RADIUS sprite1.contentSize.height/1.3

@implementation Hole

@synthesize sprite1;
@synthesize sprite2;
@synthesize teleportFlag;
@synthesize impulseFlag;
@synthesize teleportRegionRadius;
@synthesize ImpulseRegionRadius;
@synthesize angle1;
@synthesize angle2;

- (id) initWithPos1: (CGPoint)pos1 Angle1: (float) ang1 Pos2:(CGPoint)pos2 Angle2: (float) ang2
{
    if ((self=[super init])) {
        
        //hole1
        self.sprite1 = [CCSprite spriteWithFile:HOLE_SPRITE];
        sprite1.position = pos1;
        sprite1.rotation = -ang1*180/3.14159;
        
        //hole2
        self.sprite2 = [CCSprite spriteWithFile:HOLE_SPRITE];
        sprite2.position = pos2;
        sprite2.rotation = -ang2*180/3.14159;        
        
        //parameter
        teleportRegionRadius = TELEPORT_REGION_RADIUS;
        ImpulseRegionRadius = IMPULSE_REGION_RADIUS;
        
        teleportFlag = YES;
        impulseFlag = YES;
        
        angle1 = ang1;
        angle2 = ang2;        
    }
    
    return self;    
}

- (void) scroll:(int)scrollDir
{
    switch (scrollDir) {
        case L:            
            sprite1.position = ccpAdd(sprite1.position, CGPointMake(-step, 0));
            sprite2.position = ccpAdd(sprite2.position, CGPointMake(-step, 0));
            break;
        case R:            
            sprite1.position = ccpAdd(sprite1.position, CGPointMake(step, 0));
            sprite2.position = ccpAdd(sprite2.position, CGPointMake(step, 0));
            break;
            
        default:
            break;
    }
}

@end
