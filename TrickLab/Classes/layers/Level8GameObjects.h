//
//  Level8GameObjects.h
//  TrickLab
//
//  Created by Siyao Kong on 3/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "BabyHamster.h"
#import "Cage.h"
#import "Pipe.h"
#import "MotherHamster.h"
#import "Cradle.h"
#import "Carrot.h"
#import "Floater.h"
#import "Blower.h"
#import "Hole.h"
#import "ContactListener.h"


@interface Level8GameObjects : CCLayer {
    CGSize screenSize;
    int levelSelected;
    
    b2World *world;
    b2Body *containerBody;  //ground body for mouseJoint use
    
    BabyHamster *babyHamster;
    MotherHamster *motherHamster;
    Cage *cage1;
    Cage *cage2;
    Cradle *cradle;
    Carrot *carrot;
    Floater *floater1;
    Blower *blower1;
    Owl *owl;    
    CCSprite *carrotBarSprite;
    
    ContactListener *contactListener;
    
    float timer;
}

- (id) initWithLevelNumber:(int)levelSel;


@property b2World *world;
@property (retain) Cage *cage1;
@property (retain) Cage *cage2;
@property (retain) BabyHamster *babyHamster;
@property (retain) MotherHamster *motherHamster;
@property (retain) Floater *floater1;
@property (retain) Blower *blower1;
@property (retain) Owl *owl;
@property (retain) Cradle *cradle;
@property (retain) Carrot *carrot;
@property (retain) CCSprite *carrotBarSprite;
@property int levelSelected;

@end
