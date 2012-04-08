//
//  Level7GameObjects.m
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Level7GameObjects.h"
#import "GameScene.h"
#import "PhysicsObject.h"


@interface Level7GameObjects (PrivateMethods)

- (void) updateObjectStatus;
- (CGPoint) locationFromTouch:(UITouch *)touch;
- (void) instantiateGameObjects;
- (void) updateCarrotBar;
- (void) updateMotherAnimation;
- (void) updateTimeUsed;

@end


@implementation Level7GameObjects

@synthesize world;
@synthesize cage;
@synthesize babyHamster;
@synthesize motherHamster;
@synthesize pipe;
@synthesize floater;
@synthesize bucket;
@synthesize pullRing;
@synthesize pulley;
@synthesize cradle;
@synthesize stone;
@synthesize carrot;
@synthesize blower;
@synthesize carrotBarSprite;
@synthesize levelSelected;

- (id) initWithLevelNumber:(int)levelSel
{
    if ((self=[super init])) {
        
        //unlock current level
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"level%i_unlockLevel", levelSel]];
        
        levelSelected = levelSel;
       
        screenSize = [[CCDirector sharedDirector] winSize];    

        //level background
        CCSprite *windowSprite = [CCSprite spriteWithFile:WINDOW_DAY_SPRITE];
        windowSprite.position = ccp(screenSize.width*0.8, screenSize.height*0.88);
        [self addChild:windowSprite z:LEVELBGTAG tag:LEVELBGTAG];
        CCSprite *levelBgSprite = [CCSprite spriteWithFile:LEVELBG_DAY_SPRITE];
        levelBgSprite.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:levelBgSprite z:LEVELBGTAG tag:LEVELBGTAG];
        
        //carrot bar
        self.carrotBarSprite = [CCSprite spriteWithSpriteFrameName:CARROT_BAR_0_FRM];
        self.carrotBarSprite.position = ccp(screenSize.width*0.15f, screenSize.height*0.97f);
        [self addChild:carrotBarSprite z:CARROTBAR tag:CARROTBAR];
        
        //create world
        b2Vec2 gravity = b2Vec2(0.0f,-10.0f);
        bool allowBodiesToSleep = YES;
        world = new b2World(gravity);
        world->SetAllowSleeping(allowBodiesToSleep);
                
        //create static screen container body
        b2BodyDef containerBodyDef;
        containerBodyDef.position = b2Vec2(screenSize.width/2/PTM_RATIO, -0.05f);
        containerBody = world->CreateBody(&containerBodyDef);
        
        //create screen box edge        
        b2Vec2 lowerLeftCorner = toMeters(CGPointMake(0, 0));
		b2Vec2 lowerRightCorner = toMeters(CGPointMake(screenSize.width, 0));

        b2PolygonShape screenBottomEdgeShape;
        int density = 0;
        screenBottomEdgeShape.SetAsBox(screenSize.width/2/PTM_RATIO, 0.1f);            
        containerBody->CreateFixture(&screenBottomEdgeShape, density); 
        
        //instantiate game obj
        [self instantiateGameObjects];  
        
        //contact listener
        contactListener = new ContactListener();
        world->SetContactListener(contactListener);
        
        startContactWithBucket = 0;
        
        timer = 0;
        
        //scheduler
        [self scheduleUpdate];
        [self updateMotherAnimation];
        [self schedule:@selector(updateMotherAnimation) interval:7];
        [self schedule:@selector(updateObjectStatus)];//interval:0.016f
        [self schedule:@selector(updateTimeUsed) interval:0.01f];
        
        self.isTouchEnabled = YES;        
    }
    
    return self;
}

- (void) instantiateGameObjects
{
    //baby hamster
    self.babyHamster = [[(BabyHamster *)[BabyHamster alloc] initWithPos:ccp(screenSize.width*0.13, screenSize.height*0.76) level:levelSelected AndWorld:world] autorelease];
    [self addChild:babyHamster.sprite z:BABYHAMSTERTAG tag:BABYHAMSTERTAG];
    CCAction *babyBlinkAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[babyHamster startAnimWithTag:BLINK]];
    [babyHamster.sprite runAction:babyBlinkAction];
    
    //mother hamster
    self.motherHamster = [[(MotherHamster *)[MotherHamster alloc] initWithPos:ccp(screenSize.width*0.85, screenSize.height*0.13)] autorelease];
    [self addChild:motherHamster.sprite z:MOTHERHAMSTERTAG tag:MOTHERHAMSTERTAG];
    
    //cage
    self.cage = [[(Cage *)[Cage alloc] initWithPos:ccp(screenSize.width*0.13, screenSize.height*0.78) AndWorld:world] autorelease];
    [self addChild:cage.sprite z:CAGEFRONTTAG tag:CAGEFRONTTAG];
    [self addChild:cage.spriteBack z:CAGEBACKTAG tag:CAGEBACKTAG];    
    
    //floater
    self.floater = [[(Floater *)[Floater alloc] initWithPos:ccp(screenSize.width*0.53, screenSize.height*0.15) move:STATIC AndWorld:world] autorelease];
    [self addChild:floater.sprite z:FLOATERTAG tag:FLOATERTAG];
    
    //blower
    self.blower = [[(Blower *)[Blower alloc] initWithPos:ccp(screenSize.width*0.4, screenSize.height*0.7) Angular:-45 Range:screenSize.width*0.52] autorelease];
    [self addChild:blower.sprite z:BLOWERTAG tag:BLOWERTAG];
    
    //pipe
    self.pipe = [[(Pipe *)[Pipe alloc] initWithPos:ccp(screenSize.width*0.13, screenSize.height*0.683) shape:PIPE1 AndWorld:world] autorelease];    
    [self addChild:pipe.sprite z:PIPETAG tag:PIPETAG];        
    
    //cradle
    self.cradle = [[(Cradle *)[Cradle alloc] initWithPos:ccp(screenSize.width*0.71, screenSize.height*0.08) AndWorld:world] autorelease];
    [self addChild:cradle.sprite z:CRADLETAG tag:CRADLETAG];
    CCAction *cradleSwingAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[cradle startAnimWithTag:SWING]];
    [cradle.sprite runAction:cradleSwingAction];

    //bucket
    self.bucket= [[(Bucket *)[Bucket alloc] initWithPos:ccp(screenSize.width*0.5351552,screenSize.height*0.390625) AndWorld:world] autorelease];
    [self addChild:bucket.sprite z:BUCKETFRONTTAG tag:BUCKETFRONTTAG];
    [self addChild:bucket.spriteBack z:BUCKETBACKTAG tag:BUCKETBACKTAG];
    
    //pullRing
    self.pullRing = [[(PullRing *)[PullRing alloc] initWithPos:ccp(screenSize.width*0.636715,screenSize.height*0.390625) AndWorld:world] autorelease];
    [self addChild:pullRing.sprite z:PULLRINGTAG tag:PULLRINGTAG];
    
    //pulley
    self.pulley = [[(Pulley *)[Pulley alloc] initWithPos:ccp(screenSize.width*0.586,screenSize.height*0.7422) AndWorld:world] autorelease];
    [self addChild:pulley.sprite z:PULLEYTAG tag:PULLEYTAG];    
    
    //add pulleyJoint
    [pulley attachPulleyJointToPulleyBodyA:bucket.body PosA: 1 SpriteA: bucket.sprite BodyB:pullRing.body PosB: 2 SpriteB: pullRing.sprite World:world];
    [self addChild:pulley.leftRopeSirpte z:ROPETAG tag:ROPETAG];
    [self addChild:pulley.rightRopeSirpte z:ROPETAG tag:ROPETAG];
    
    //stone
    //self.stone = [[(Stone *)[Stone alloc] initWithPos:ccp(screenSize.width*0.47, screenSize.height*0.09) AndWorld:world] autorelease];
    //[self addChild:stone.sprite z:STONETAG tag:STONETAG];
    
    //carrot
    self.carrot = [[(Carrot *)[Carrot alloc] initWithPos1:ccp(screenSize.width*0.2083, screenSize.height*0.5371) Pos2:ccp(screenSize.width*0.49, screenSize.height*0.586) Pos3:ccp(screenSize.width*0.5319, screenSize.height*0.24414)] autorelease];
    [self addChild:carrot.sprite1 z:CARROT1TAG tag:CARROT1TAG];
    [self addChild:carrot.sprite2 z:CARROT2TAG tag:CARROT2TAG];
    [self addChild:carrot.sprite3 z:CARROT3TAG tag:CARROT3TAG];
    
    //play carrot1 animation
    CCAction *carrotAction1 = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[carrot startAnimWithTag:CARROT1]];
    [carrot.sprite1 runAction:carrotAction1];
    //play carrot2 animation
    CCAction *carrotAction2 = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[carrot startAnimWithTag:CARROT2]];
    [carrot.sprite2 runAction:carrotAction2];
    //play carrot3 animation
    CCAction *carrotAction3 = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[carrot startAnimWithTag:CARROT3]];
    [carrot.sprite3 runAction:carrotAction3];
    
}

- (void) updateObjectStatus
{    
    //activate/deactivate floater, apply force to floater
    [floater updateStatusWithVel:babyHamster.body->GetLinearVelocity().y mass:babyHamster.body->GetMass()];
    
    if (floater.startContactWithBabyHamster){
        [babyHamster reduceHorizontalSpeed];
    }
    
    [babyHamster checkContactWithFloater:floater];
    
    [babyHamster checkInBoundary:motherHamster widthFactor:1];
    
    if ([babyHamster checkInsideBucket:bucket]) {
        startContactWithBucket++;
    }
    else {
        startContactWithBucket = 0;
    }

    if (startContactWithBucket == 1) {
        //play sfx
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_BUCKET];
    }
    
    [babyHamster checkCarrotCollected:carrot];
    
    [self updateCarrotBar];
    
    [babyHamster checkFallInCradle:cradle mother:motherHamster WithoutBucket:bucket carrot:carrot timeUsed:timer];
    
    [pulley drawRope];
    
    [babyHamster checkContactWithGround:motherHamster];
    
    if (babyHamster.succeed || babyHamster.failure) {
        [self unschedule:@selector(updateMotherAnimation)];
    }
    //update XX status
}

- (void) updateTimeUsed
{
    timer += 0.01;
}

- (void) updateMotherAnimation
{
    int animTag = (int) (CCRANDOM_0_1()*(NUM_OF_ALTERNATIVE_ANIM+1));//0/1/2/3
    CCLOG(@"===========animtag:%i",animTag);
    
    CCFiniteTimeAction *momAlternativeAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[motherHamster startAnimWithTag:animTag] times:1];
    
    CCCallBlock *momRegularAction = [CCCallBlock actionWithBlock:^{
        if (!babyHamster.succeed && !babyHamster.failure) {
            CCAction *momRegularAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[motherHamster startAnimWithTag:REGULAR]];
            [motherHamster.sprite runAction:momRegularAction];
        }        
    }];
    
    [motherHamster.sprite runAction:[CCSequence actions:momAlternativeAction, momRegularAction, nil]];          
}

- (void) updateCarrotBar
{
    if (carrot.numOfCarrotCollected) {
        CCSpriteFrame *carrotBarSpriteFrm;
        if (carrot.numOfCarrotCollected == 1) {
            carrotBarSpriteFrm = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:CARROT_BAR_1_FRM];
        }
        else if (carrot.numOfCarrotCollected == 2) {
            carrotBarSpriteFrm = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:CARROT_BAR_2_FRM];
        }
        else {
            carrotBarSpriteFrm = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:CARROT_BAR_3_FRM];
        }
        [carrot changeCarrotBar:carrotBarSprite byFrame:carrotBarSpriteFrm];
    }
}

- (void) update: (ccTime)delta
{    
    float timeStep = 0.03f;
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    world->Step(timeStep, velocityIterations, positionIterations);   

    //update sprite position
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext()) {
        PhysicsObject *obj = (PhysicsObject *)body->GetUserData();
        if (obj != NULL) {
            CCSprite *sprite = obj.sprite;
            sprite.position = toPixels(body->GetPosition());
            float angle = body->GetAngle();
            sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * (-1);
            
            if (sprite == bucket.sprite) {
                bucket.spriteBack.position = sprite.position;
                bucket.spriteBack.rotation = sprite.rotation;
            }
        }
    }    
}

- (CGPoint) locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    CCLOG(@"PhysicsWorldTouchBegan");
    
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [self locationFromTouch:touch];
        
        if (!floater.endContactWithBabyHamster && floater.body->IsAwake() && CGRectContainsPoint(floater.sprite.boundingBox, touchPoint)){
            
            if (!CGRectIntersectsRect(cage.sprite.boundingBox, floater.sprite.boundingBox)) {
                //floater fade out
                id action = [CCFadeOut actionWithDuration:0.5];
                [floater.sprite runAction:action]; 
                
                //destroy joint between baby hamster and floater
                world->DestroyJoint(floater.jointWithBabyHamster);
                floater.endContactWithBabyHamster = YES;
            }            
        }
        else if (!cage.open && CGRectContainsPoint(cage.sprite.boundingBox, touchPoint)){
            //deactivate/open cage
            [cage deactivate];
            //play sfx
            [[SimpleAudioEngine sharedEngine] playEffect:SFX_CAGE_OPEN];
            if (!babyHamster.body->IsActive()) {
                //activate baby hamster
                [babyHamster activate];
            }            
        }
        else if (cage.open && CGRectContainsPoint(cage.sprite.boundingBox, touchPoint)){
            if (babyHamster.body->IsActive() && CGRectContainsRect(cage.sprite.boundingBox, babyHamster.sprite.boundingBox)) {
                //deactivate baby hamster
                [babyHamster deactivate];
                //activate/close cage
                [cage activate];
                //play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:SFX_CAGE_CLOSE];
            }
            else if (!CGRectIntersectsRect(cage.sprite.boundingBox, babyHamster.sprite.boundingBox)) {
                //activate/close cage
                [cage activate];
                //play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:SFX_CAGE_CLOSE];
            }
        }   
        else if (CGRectContainsPoint(blower.sprite.boundingBox, touchPoint)){
            //blower
            [babyHamster checkInBlowerRange:blower];
            CCAction *blowerAction = [[CCAnimationCache sharedAnimationCache] actionWithAnimate:[blower startAnimWithTag:BLOW]];
            [blower.sprite runAction:blowerAction];
            [blower playParticleEffect];
        }
        else if (CGRectContainsPoint(pullRing.sprite.boundingBox, touchPoint)){
            //pullRing
            pullRingTouch = touch;
            [pullRing createMouseJoint:touchPoint GroundBody:containerBody World:world];
        }
        else if (CGRectContainsPoint(motherHamster.sprite.boundingBox, touchPoint)) {
            CCCallBlock *playAlternativeAnim = [CCCallBlock actionWithBlock:^{
                [self unschedule:@selector(updateMotherAnimation)];
                [self updateMotherAnimation];       
            }];
            CCCallBlock *schedule = [CCCallBlock actionWithBlock:^{
                [self schedule:@selector(updateMotherAnimation) interval:7];       
            }];
            [self runAction:[CCSequence actions:playAlternativeAnim, schedule, nil]];
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
//    CCLOG(@"PhysicsWorldTouchMove");
    CGPoint touchPoint = [self locationFromTouch:pullRingTouch];
    [pullRing modifyMouseJoint:touchPoint];
    
}
    
- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"PhysicsWorldTouchEnd");
    
    for (UITouch *touch in touches) {
        if (touch == pullRingTouch)
        {
            [pullRing destroyMouseJointWorld:world];
            pullRingTouch = NULL;
        }
        
    }
    
}

- (void) dealloc
{    
    [babyHamster release];
    [motherHamster release];
    [cage release];
    [pipe release];
    [floater release];
    [bucket release];
    [pullRing release];
    [pulley release];
    [cradle release];
    [stone release];
    [carrot release];
    [blower release];
    [carrotBarSprite release];
    delete world;
    
    [super dealloc];
}


@end
