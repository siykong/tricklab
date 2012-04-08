//
//  BabyHamster.h
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"
#import "Floater.h"
#import "Cage.h"
#import "Bucket.h"
#import "Blower.h"
#import "Carrot.h"
#import "Cradle.h"
#import "Hole.h"
#import "Owl.h"
#import "MotherHamster.h"
#import "Pipe.h"

typedef enum {
    BLINK,
    DEAD,
    EATEN,
}babyActionTag;

@interface BabyHamster : PhysicsObject {
    
    bool succeed;
    bool failure;
    int levelSelected;
    
    bool contactWithPipe;    
    
    //teleport
    Boolean teleportingFlag;
    b2Vec2 teleportPos;
    b2Vec2 teleportVel;
    
    //owl
    Boolean vulnerableToOwl;
}

- (id) initWithPos: (CGPoint)pos level:(int)levelSel AndWorld: (b2World *)world;
- (void) checkContactWithFloater:(Floater *)floater;
- (void) checkInBoundary:(MotherHamster *)mom widthFactor:(int)wf;
- (bool) checkInsideBucket:(Bucket *)bucket;
- (Boolean) checkInBlowerRange:(Blower *) blower;
- (void) applyImpulseByBlower:(b2Vec2) direction;
- (void) deactivate;
- (void) activate;
- (void) checkCarrotCollected:(Carrot *)carrot;
- (void) checkFallInCradle:(Cradle *)cradle mother:(MotherHamster *)mom carrot:(Carrot *)carrot timeUsed:(float)timer;
- (void) checkFallInCradle:(Cradle *)cradle mother:(MotherHamster *)mom WithoutBucket:(Bucket *)bucket carrot:(Carrot *)carrot timeUsed:(float)timer;
- (bool) checkInOwlRange:(Owl *)owl mother:(MotherHamster *)mom LevelLayer:(CCLayer *)layer;
- (void) checkTeleport:(Hole *)hole;
- (void) checkTeleportImpulse:(Hole *)hole;
- (void) teleport;
- (void) stopMotion;
- (void) reduceHorizontalSpeed;
- (NSString *)startAnimWithTag:(int)tag;
- (void) checkContactWithGround:(MotherHamster *)mom;
- (void) checkVulnerableToOwl:(Cage *)cage;

@property bool succeed;
@property bool failure;
@property Boolean teleportingFlag;
@property Boolean vulnerableToOwl;
@property bool contactWithPipe;


@end

