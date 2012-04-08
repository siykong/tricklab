//
//  Level9GameObjects.m
//  TrickLab
//
//  Created by Siyao Kong on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Level9GameObjects.h"
#import "GameScene.h"
#import "PhysicsObject.h"


@interface Level9GameObjects (PrivateMethods)

- (void) updateObjectStatus;
- (CGPoint) locationFromTouch:(UITouch *)touch;
- (void) instantiateGameObjects;
- (void) updateCarrotBar;
- (void) updateMotherAnimation;
- (void) detachFloater;
- (void) updateTimeUsed;
- (void) scrollBg: (ccTime)delta;
- (void) scroll:(int)scrollDir;
- (void) updatePullRingMouseJoint;

@end


@implementation Level9GameObjects

@synthesize world;
@synthesize cage;
@synthesize cage2;
@synthesize babyHamster;
@synthesize motherHamster;
@synthesize pipe2;
@synthesize pipe1;
@synthesize floater;
@synthesize floater2;
@synthesize cradle;
@synthesize carrot;
@synthesize carrotBarSprite;
@synthesize levelSelected;
@synthesize bucket;
@synthesize pullRing;
@synthesize pulley;
@synthesize blower;
@synthesize blower2;
@synthesize hole;
@synthesize owl;



- (id) initWithLevelNumber:(int)levelSel
{
    if ((self=[super init])) {
        
        //unlock current level
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"level%i_unlockLevel", levelSel]];
        
        levelSelected = levelSel;
        
        screenSize = [[CCDirector sharedDirector] winSize];    
        
        //level background
        CCSprite *levelBgSprite = [CCSprite spriteWithFile:LEVELBG_NIGHT_SPRITE_WIDE];
        levelBgSprite.position = ccp(screenSize.width, screenSize.height/2);
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
		b2Vec2 lowerRightCorner = toMeters(CGPointMake(screenSize.width*2, 0));
        
        b2PolygonShape screenBottomEdgeShape;
        int density = 0;
        screenBottomEdgeShape.SetAsBox(screenSize.width/2/PTM_RATIO, 0.1f);            
        containerBody->CreateFixture(&screenBottomEdgeShape, density); 
        
        //instantiate game obj
        [self instantiateGameObjects]; 
        
        //contact listener
        contactListener = new ContactListener();
        world->SetContactListener(contactListener);
        
        timer = 0;
        
        //scheduler
        [self scheduleUpdate];
        [self updateMotherAnimation];
        [self schedule:@selector(updateMotherAnimation) interval:7];
        [self schedule:@selector(updateObjectStatus)];//interval:0.016f
        [self schedule:@selector(updateOwlAnimation) interval:owl.animationInterval];
        [self schedule:@selector(updateTimeUsed) interval:0.01f];
        
        [self schedule:@selector(updatePullRingMouseJoint)];
        
        //init screen position
        initFlag = true;
        self.position = ccp(-screenSize.width*1.0, 0);
        [self initScrollBg];
        
        self.isTouchEnabled = NO;        
    }
    
    return self;
}

- (void) initScrollBg
{
    CCMoveTo *moveTo = [CCMoveTo actionWithDuration:2.0f position:ccp(0, 0)];
    CCEaseSineInOut* easeInOut = [CCEaseSineInOut actionWithAction:moveTo];
    CCCallFunc *enableT = [CCCallFunc actionWithTarget:self selector:@selector(enableTouch)]; 
    
    [self runAction:[CCSequence actions:easeInOut, enableT, nil]];
}

- (void) enableTouch
{
    self.isTouchEnabled = YES;
}

- (void) scrollBg: (ccTime)delta
{
    float layerDestinationX;
    float movingSpeed;
    
    if (!initFlag) 
    {
    layerDestinationX = self.position.x;
    float babyHamsterOffset_Layer = babyHamster.sprite.position.x - screenSize.width*0.5;
    
    float babyHamsterOffset_Screen = babyHamsterOffset_Layer + self.position.x;
    
    if (babyHamsterOffset_Screen > screenSize.width*0.15)
        layerDestinationX = -babyHamsterOffset_Layer+screenSize.width*0.15;
        
    else if (babyHamsterOffset_Screen < -screenSize.width*0.15)
        layerDestinationX = -babyHamsterOffset_Layer-screenSize.width*0.15;
    
    if (layerDestinationX > 0)
        layerDestinationX = 0;
    else if (layerDestinationX < -screenSize.width) 
        layerDestinationX = -screenSize.width;
    
        movingSpeed = 450;

    float movingDuration = (layerDestinationX - self.position.x) / movingSpeed;
    movingDuration = movingDuration >= 0 ? movingDuration : -movingDuration;
//    CCLOG(@"distance: %f", movingDuration);
    
    if ((layerDestinationX - self.position.x) < movingSpeed * delta && (layerDestinationX - self.position.x) > -movingSpeed*delta)
        self.position = ccp(layerDestinationX, 0);
    else {
        if (layerDestinationX - self.position.x < 0)
            self.position = ccp(self.position.x-movingSpeed*delta, 0);
        else
            self.position = ccp(self.position.x+movingSpeed*delta, 0);
      
    }
    }
    
    //not move self.carrotBarSprite
    self.carrotBarSprite.position = ccp(screenSize.width*0.15f-self.position.x, screenSize.height*0.97f);
    
    
}

- (void) instantiateGameObjects
{
    //baby hamster
    self.babyHamster = [[(BabyHamster *)[BabyHamster alloc] initWithPos:ccp(screenSize.width*0.78, screenSize.height*0.65) level:levelSelected AndWorld:world] autorelease];
    [self addChild:babyHamster.sprite z:BABYHAMSTERTAG tag:BABYHAMSTERTAG];
    CCAction *babyBlinkAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[babyHamster startAnimWithTag:BLINK]];
    [babyHamster.sprite runAction:babyBlinkAction];
    
    //mother hamster
    self.motherHamster = [[(MotherHamster *)[MotherHamster alloc] initWithPos:ccp(screenSize.width*1.85, screenSize.height*0.13)] autorelease];
    [self addChild:motherHamster.sprite z:MOTHERHAMSTERTAG tag:MOTHERHAMSTERTAG];
    [motherHamster.sprite convertToWorldSpace:motherHamster.sprite.position];
    
    //cage
    self.cage = [[(Cage *)[Cage alloc] initWithPos:ccp(screenSize.width*0.78, screenSize.height*0.67) AndWorld:world] autorelease];
    [self addChild:cage.sprite z:CAGEFRONTTAG tag:CAGEFRONTTAG];
    [self addChild:cage.spriteBack z:CAGEBACKTAG tag:CAGEBACKTAG];  
    
    self.cage2 = [[(Cage *)[Cage alloc] initWithPos:ccp(screenSize.width*1.35, screenSize.height*0.65) AndWorld:world] autorelease];
    [self addChild:cage2.sprite z:CAGEFRONTTAG tag:CAGEFRONTTAG];
    [self addChild:cage2.spriteBack z:CAGEBACKTAG tag:CAGEBACKTAG]; 
    
    //floater
    self.floater = [[(Floater *)[Floater alloc] initWithPos:ccp(screenSize.width*0.35, screenSize.height*0.5) move:STATIC AndWorld:world] autorelease];
    [self addChild:floater.sprite z:FLOATERTAG tag:FLOATERTAG];  
    
    self.floater2 = [[(Floater *)[Floater alloc] initWithPos:ccp(screenSize.width*1.18, screenSize.height*0.5) move:STATIC AndWorld:world] autorelease];
    [self addChild:floater2.sprite z:FLOATERTAG tag:FLOATERTAG]; 
    
    //bucket
    self.bucket= [[(Bucket *)[Bucket alloc] initWithPos:ccp(screenSize.width*0.286715,screenSize.height*0.250625) AndWorld:world] autorelease];
    [self addChild:bucket.sprite z:BUCKETFRONTTAG tag:BUCKETFRONTTAG];
    [self addChild:bucket.spriteBack z:BUCKETBACKTAG tag:BUCKETBACKTAG];
    
    //pullRing
    self.pullRing = [[(PullRing *)[PullRing alloc] initWithPos:ccp(screenSize.width*0.1851552,screenSize.height*0.250625) AndWorld:world] autorelease];
    [self addChild:pullRing.sprite z:PULLRINGTAG tag:PULLRINGTAG];
    
    //pulley
    self.pulley = [[(Pulley *)[Pulley alloc] initWithPos:ccp(screenSize.width*0.236,screenSize.height*0.58) AndWorld:world] autorelease];
    [self addChild:pulley.sprite z:PULLEYTAG tag:PULLEYTAG];    
    
    //add pulleyJoint
    [pulley attachPulleyJointToPulleyBodyA:bucket.body PosA: 2 SpriteA: bucket.sprite BodyB:pullRing.body PosB: 1 SpriteB: pullRing.sprite World:world];
    [self addChild:pulley.leftRopeSirpte z:ROPETAG tag:ROPETAG];
    [self addChild:pulley.rightRopeSirpte z:ROPETAG tag:ROPETAG];
    
    //blower
    self.blower = [[(Blower *)[Blower alloc] initWithPos:ccp(screenSize.width*0.236,screenSize.height*0.72) Angular:0.0f Range:300] autorelease];
    [self addChild:blower.sprite z:BLOWERTAG tag:BLOWERTAG];
    
    self.blower2 = [[(Blower *)[Blower alloc] initWithPos:ccp(screenSize.width*1.00,screenSize.height*0.7) Angular:0.0f Range:300] autorelease];
    [self addChild:blower2.sprite z:BLOWERTAG tag:BLOWERTAG];
    
    //hole
    self.hole = [[(Hole *)[Hole alloc] initWithPos1:ccp(screenSize.width*0.56,screenSize.height*0.63) Angle1:3.14159f*3/4 Pos2:ccp(screenSize.width*1.18,screenSize.height*0.9) Angle2:3.14159f*3/2] autorelease];
    [self addChild:hole.sprite1 z:HOLETAG tag:HOLETAG];
    [self addChild:hole.sprite2 z:HOLETAG tag:HOLETAG];
    
    //pipe2        
    self.pipe2 = [[(Pipe *)[Pipe alloc] initWithPos:ccp(screenSize.width*0.78, screenSize.height*0.5) shape:PIPE2 AndWorld:world] autorelease];    
    [self addChild:pipe2.sprite z:PIPETAG tag:PIPETAG];
    
    //pipe1
    self.pipe1 = [[(Pipe *)[Pipe alloc] initWithPos:ccp(screenSize.width*1.35, screenSize.height*0.35) shape:PIPE1 AndWorld:world] autorelease];    
    [self addChild:pipe1.sprite z:PIPETAG tag:PIPETAG];
    
    //cradle
    self.cradle = [[(Cradle *)[Cradle alloc] initWithPos:ccp(screenSize.width*1.7, screenSize.height*0.08) AndWorld:world] autorelease];
    [self addChild:cradle.sprite z:CRADLETAG tag:CRADLETAG];
    CCAction *cradleSwingAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[cradle startAnimWithTag:SWING]];
    [cradle.sprite runAction:cradleSwingAction];
    
    //carrot
    self.carrot = [[(Carrot *)[Carrot alloc] initWithPos1:ccp(screenSize.width*0.286715, screenSize.height*0.1) Pos2:ccp(screenSize.width*0.45, screenSize.height*0.85) Pos3:ccp(screenSize.width*1.35, screenSize.height*0.75)] autorelease];
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
    
    //instantiate owl
    int posArrayLength = 2;
    CGPoint* posArray = new CGPoint[posArrayLength];
    posArray[0] = ccp(screenSize.width*0.43,screenSize.height*0.13);
    //posArray[0] = ccp(screenSize.width*0.236,screenSize.height*0.85);
    posArray[1] = ccp(screenSize.width*1.35,screenSize.height*0.5);
    self.owl = [[(Owl *)[Owl alloc] initWithPosArray:posArray PosLen:posArrayLength Range:screenSize.width*0.15 IsActive:YES] autorelease];
    [self addChild:owl.sprite z:OWLTAG tag:OWLTAG];
    
}

- (void) updateObjectStatus
{    
    //activate/deactivate floater, apply force to floater
    [floater updateStatusWithVel:babyHamster.body->GetLinearVelocity().y mass:babyHamster.body->GetMass()];
    
    [floater2 updateStatusWithVel:babyHamster.body->GetLinearVelocity().y mass:babyHamster.body->GetMass()];
    
    if (floater.startContactWithBabyHamster){
        [babyHamster reduceHorizontalSpeed];
    } 
    
    if (floater2.startContactWithBabyHamster){
        [babyHamster reduceHorizontalSpeed];
    } 
    
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

    [babyHamster checkContactWithFloater:floater];
    
    [babyHamster checkContactWithFloater:floater2];
    
    [babyHamster checkInBoundary:motherHamster widthFactor:2];
    
    [babyHamster checkCarrotCollected:carrot];
    
    [self updateCarrotBar];
    
    [babyHamster checkFallInCradle:cradle mother:motherHamster carrot:carrot timeUsed:timer];
    
    [babyHamster checkContactWithGround:motherHamster];
    
    [babyHamster checkTeleport:hole];
    
    [babyHamster checkTeleportImpulse:hole];
    
    
    if ([babyHamster checkInOwlRange:owl mother:motherHamster LevelLayer:self])
    {
        if (!floater.endContactWithBabyHamster && floater.body->IsAwake())
        {
            CCDelayTime *delayAction = [CCDelayTime actionWithDuration:1.5f];
            CCCallFunc *detach = [CCCallFunc actionWithTarget:self selector:@selector(detachFloater)]; 
            [floater.sprite runAction:[CCSequence actions:delayAction, detach, nil]];
        }
        
        if (!floater2.endContactWithBabyHamster && floater.body->IsAwake())
        {
            CCDelayTime *delayAction = [CCDelayTime actionWithDuration:1.5f];
            CCCallFunc *detach = [CCCallFunc actionWithTarget:self selector:@selector(detachFloater)]; 
            [floater2.sprite runAction:[CCSequence actions:delayAction, detach, nil]];
        }
        
    }
    
    if (babyHamster.teleportingFlag)
        [self detachFloater];
    
    if (babyHamster.succeed || babyHamster.failure) {
        [self unschedule:@selector(updateMotherAnimation)];
    }
    
    [pulley drawRope];
    
    [babyHamster checkVulnerableToOwl:cage];
    
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

- (void) updateOwlAnimation
{
    [owl updateOwlAnimation];
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
    
    [self scrollBg:delta];
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
        //add offset to touches
        touchPoint.x -= self.position.x;
        
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
        else if (!floater2.endContactWithBabyHamster && floater2.body->IsAwake() && CGRectContainsPoint(floater2.sprite.boundingBox, touchPoint)){
            
            if (!CGRectIntersectsRect(cage.sprite.boundingBox, floater2.sprite.boundingBox)) {
                //floater fade out
                id action = [CCFadeOut actionWithDuration:0.5];
                [floater2.sprite runAction:action]; 
                
                //destroy joint between baby hamster and floater
                world->DestroyJoint(floater2.jointWithBabyHamster);
                floater2.endContactWithBabyHamster = YES;
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
            
            //scroll begin
            initFlag = false;
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
        else if (!cage2.open && CGRectContainsPoint(cage2.sprite.boundingBox, touchPoint)){
            //deactivate/open cage2
            [cage2 deactivate];
            //play sfx
            [[SimpleAudioEngine sharedEngine] playEffect:SFX_CAGE_OPEN];
            if (!babyHamster.body->IsActive()) {
                //activate baby hamster
                [babyHamster activate];
            }            
        }
        else if (cage2.open && CGRectContainsPoint(cage2.sprite.boundingBox, touchPoint)){
            if (babyHamster.body->IsActive() && CGRectContainsRect(cage2.sprite.boundingBox, babyHamster.sprite.boundingBox)) {
                //deactivate baby hamster
                [babyHamster deactivate];
                //activate/close cage2
                [cage2 activate];
                //play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:SFX_CAGE_CLOSE];
            }
            else if (!CGRectIntersectsRect(cage2.sprite.boundingBox, babyHamster.sprite.boundingBox)) {
                //activate/close cage
                [cage activate];
                //play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:SFX_CAGE_CLOSE];
            }
        }
        else if (CGRectContainsPoint(pullRing.sprite.boundingBox, touchPoint)){
            //pullRing
            pullRingTouch = touch;
            [pullRing createMouseJoint:touchPoint GroundBody:containerBody World:world];
        }
        else if (CGRectContainsPoint(blower.sprite.boundingBox, touchPoint)){
            //blower
            [babyHamster checkInBlowerRange:blower];
            CCAction *blowerAction = [[CCAnimationCache sharedAnimationCache] actionWithAnimate:[blower startAnimWithTag:BLOW]];
            [blower.sprite runAction:blowerAction];
            [blower playParticleEffect];
        }
        else if (CGRectContainsPoint(blower2.sprite.boundingBox, touchPoint)){
            //blower
            [babyHamster checkInBlowerRange:blower2];
            CCAction *blowerAction = [[CCAnimationCache sharedAnimationCache] actionWithAnimate:[blower2 startAnimWithTag:BLOW]];
            [blower2.sprite runAction:blowerAction];
            [blower2 playParticleEffect];
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
/*
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    //    CCLOG(@"PhysicsWorldTouchMove");
    CGPoint touchPoint = [self locationFromTouch:pullRingTouch];
    //add offset to touches
    touchPoint.x -= self.position.x;
    [pullRing modifyMouseJoint:touchPoint];
    
}
*/
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

- (void) updatePullRingMouseJoint
{
    CGPoint touchPoint = [self locationFromTouch:pullRingTouch];
    //add offset to touches
    touchPoint.x -= self.position.x;
    [pullRing modifyMouseJoint:touchPoint];
}

- (void) detachFloater
{
    if (!floater.endContactWithBabyHamster && floater.body->IsAwake()) {
        //floater fade out
        id action = [CCFadeOut actionWithDuration:0.5];
        [floater.sprite runAction:action]; 
        
        //destroy joint between baby hamster and floater
        world->DestroyJoint(floater.jointWithBabyHamster);
        floater.endContactWithBabyHamster = YES;
    }
    if (!floater2.endContactWithBabyHamster && floater2.body->IsAwake()) {
        //floater fade out
        id action = [CCFadeOut actionWithDuration:0.5];
        [floater2.sprite runAction:action]; 
        
        //destroy joint between baby hamster and floater
        world->DestroyJoint(floater2.jointWithBabyHamster);
        floater2.endContactWithBabyHamster = YES;
    }
}

- (void) scroll:(int)scrollDir
{
//    CCLOG(@"position: %f, %f", self.position.x, self.position.y);
    float step = 1.0f;
    switch (scrollDir) {
        case L:      
            self.position = ccpAdd(self.position, CGPointMake(-step, 0));
            break;
        case R:            
            self.position = ccpAdd(self.position, CGPointMake(step, 0));
            break;
            
        default:
            break;
    }
}

- (void) dealloc
{   
    [babyHamster release];
    [motherHamster release];
    [cage release];
    [pipe2 release];
    [pipe1 release];
    [cradle release];
    [carrot release];
    [carrotBarSprite release];
    [bucket release];
    [pullRing release];
    [pulley release];
    [blower release];
    [blower2 release];
    [floater release];
    [floater2 release];
    [hole release];
    [owl release];
    delete world;
    
    [super dealloc];
}


@end

