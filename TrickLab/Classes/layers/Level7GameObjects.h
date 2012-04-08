//
//  Level7GameObjects.h
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "BabyHamster.h"
#import "Floater.h"
#import "Rope.h"
#import "Bucket.h"
#import "PullRing.h"
#import "Pulley.h"
#import "Cage.h"
#import "Pipe.h"
#import "MotherHamster.h"
#import "Cradle.h"
#import "Stone.h"
#import "Carrot.h"
#import "ContactListener.h"


@interface Level7GameObjects : CCLayer {
    CGSize screenSize;
    int levelSelected;
    int startContactWithBucket;
    
    b2World *world;
    b2Body *containerBody;  //ground body for mouseJoint use
    
    BabyHamster *babyHamster;
    MotherHamster *motherHamster;
    Cage *cage;
    Pipe *pipe;
    Floater *floater;
    Bucket *bucket;
    PullRing *pullRing;
    Pulley *pulley;
    Cradle *cradle;
    Stone *stone;
    Carrot *carrot;
    Blower *blower;
    
    CCSprite *carrotBarSprite;
    
    ContactListener *contactListener;
    
    float timer;
    
    UITouch *pullRingTouch;
}

- (id) initWithLevelNumber:(int)levelSel;

@property b2World *world;
@property (retain) Cage *cage;
@property (retain) BabyHamster *babyHamster;
@property (retain) MotherHamster *motherHamster;
@property (retain) Pipe *pipe;
@property (retain) Floater *floater;
@property (retain) Bucket *bucket;
@property (retain) PullRing *pullRing;
@property (retain) Pulley *pulley;
@property (retain) Cradle *cradle;
@property (retain) Stone *stone;
@property (retain) Carrot *carrot;
@property (retain) Blower *blower;
@property (retain) CCSprite *carrotBarSprite;
@property int levelSelected;

@end
