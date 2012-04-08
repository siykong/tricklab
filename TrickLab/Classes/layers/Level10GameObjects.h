//
//  Level10GameObjects.h
//  TrickLab
//
//  Created by Siyao Kong on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BabyHamster.h"
#import "Cage.h"
#import "Pipe.h"
#import "MotherHamster.h"
#import "Cradle.h"
#import "Carrot.h"
#import "Floater.h"
#import "Bucket.h"
#import "PullRing.h"
#import "Pulley.h"
#import "ContactListener.h"
#import "GameObject.h"

@interface Level10GameObjects : CCLayer {
    CGSize screenSize;
    int levelSelected;
    int startContactWithBucket;

    b2World *world;
    b2Body *containerBody;  //ground body for mouseJoint use
    
    BabyHamster *babyHamster;
    MotherHamster *motherHamster;
    Cage *cage;
    Cage *cage2;
    Pipe *pipe2;
    Pipe *pipe1;
    Cradle *cradle;
    Carrot *carrot;
    Floater *floater;
    Floater *floater2;
    
    CCSprite *carrotBarSprite;
    
    ContactListener *contactListener;
    
    float timer;
    
    Bucket *bucket;
    PullRing *pullRing;
    Pulley *pulley;
    Blower *blower;
    Blower *blower2;
    Hole *hole;
    Owl *owl;
    
    bool initFlag;
    
    UITouch *pullRingTouch;
}

- (id) initWithLevelNumber:(int)levelSel;


@property b2World *world;
@property (retain) Cage *cage;
@property (retain) Cage *cage2;
@property (retain) BabyHamster *babyHamster;
@property (retain) MotherHamster *motherHamster;
@property (retain) Pipe *pipe2;
@property (retain) Pipe *pipe1;
@property (retain) Floater *floater;
@property (retain) Floater *floater2;
@property (retain) Blower *blower;
@property (retain) Blower *blower2;
@property (retain) Cradle *cradle;
@property (retain) Carrot *carrot;
@property (retain) CCSprite *carrotBarSprite;
@property (retain) Bucket *bucket;
@property (retain) PullRing *pullRing;
@property (retain) Pulley *pulley;
@property (retain) Hole *hole;
@property (retain) Owl *owl;
@property int levelSelected;

@end
