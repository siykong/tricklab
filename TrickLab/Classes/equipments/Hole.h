//
//  Hole.h
//  TrickLab
//
//  Created by Chao Huang on 2/12/12.
//  Copyright (c) 2012 USC. All rights reserved.
//

#import "GameObject.h"

@interface Hole : GameObject{
    CCSprite *sprite1;
    CCSprite *sprite2;
    
    float angle1;   //angle for hole (Radian)
    float angle2;
    
    Boolean teleportFlag;   //YES for allow teleport
    Boolean impulseFlag;   //YES for allow impulse
    
    float teleportRegionRadius; //radius of teleport region
    float ImpulseRegionRadius;  //radius of impulse region
}


- (id) initWithPos1: (CGPoint)pos1 Angle1: (float) ang1 Pos2:(CGPoint)pos2 Angle2: (float) ang2;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *sprite1;
@property (retain) CCSprite *sprite2;
@property Boolean teleportFlag;
@property Boolean impulseFlag;
@property float teleportRegionRadius;
@property float ImpulseRegionRadius;
@property float angle1;
@property float angle2;

@end
