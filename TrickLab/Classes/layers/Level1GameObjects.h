//
//  Level1GameObjects.h
//  TrickLab
//
//  Created by Siyao Kong on 2/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "BabyHamster.h"
#import "Cage.h"
#import "Pipe.h"
#import "MotherHamster.h"
#import "Cradle.h"
#import "Carrot.h"
#import "ContactListener.h"


@interface Level1GameObjects : CCLayer {
    CGSize screenSize;
    int levelSelected;
    
    b2World *world;
    b2Body *containerBody;  //ground body for mouseJoint use
    
    BabyHamster *babyHamster;
    MotherHamster *motherHamster;
    Cage *cage;
    Pipe *pipe1;
    Pipe *pipe3;
    Cradle *cradle;
    Carrot *carrot;
    
    CCSprite *carrotBarSprite;
    
    ContactListener *contactListener;
    
    float timer;
}

- (id) initWithLevelNumber:(int)levelSel;

@property b2World *world;
@property (retain) Cage *cage;
@property (retain) BabyHamster *babyHamster;
@property (retain) MotherHamster *motherHamster;
@property (retain) Pipe *pipe1;
@property (retain) Pipe *pipe3;
@property (retain) Cradle *cradle;
@property (retain) Carrot *carrot;
@property (retain) CCSprite *carrotBarSprite;
@property int levelSelected;

@end

