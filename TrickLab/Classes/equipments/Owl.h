//
//  Owl.h
//  TrickLab
//
//  Created by Chao Huang on 2/20/12.
//  Copyright (c) 2012 USC. All rights reserved.
//

#import "GameObject.h"

typedef enum {
    MOVE,
    SLEEP,
    WINK,
}owlActionTag;

@interface Owl : GameObject{
    CCSprite *sprite;
    
    float range;
    Boolean active;
    int positionArrayLength;
    CGPoint* positionArray;
    
    //animation
    int animationInterval;    
    float animationTag;
}

- (id) initWithPosArray: (CGPoint*)posArray PosLen: (int)posArrayLength Range: (float)rg IsActive:(Boolean)isActive;
- (void) owlAction;
- (NSString *)startAnimWithTag:(int)tag;
- (void)updateOwlAnimation;
- (void)owlAttackAnimation;
- (void) scroll:(int)scrollDir;

@property (retain) CCSprite *sprite;
@property float range;
@property Boolean active;
@property int positionArrayLength;
@property CGPoint *positionArray;
@property int animationInterval;

@end
