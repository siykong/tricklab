//
//  Level5GameObjects.m
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Level5GameObjects.h"
#import "GameScene.h"
#import "PhysicsObject.h"


@interface Level5GameObjects (PrivateMethods)

- (void) updateObjectStatus;
- (CGPoint) locationFromTouch:(UITouch *)touch;
- (void) instantiateGameObjects;
- (void) updateCarrotBar;
- (void) updateMotherAnimation;
- (void) updateTimeUsed;
- (void) detachFloater;

@end


@implementation Level5GameObjects

@synthesize world;
@synthesize cage;
@synthesize babyHamster;
@synthesize motherHamster;
@synthesize pipe1;
@synthesize floater;
@synthesize hole;
@synthesize blower;
@synthesize cradle;
@synthesize carrot;
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
    self.babyHamster = [[(BabyHamster *)[BabyHamster alloc] initWithPos:ccp(screenSize.width*0.8, screenSize.height*0.68) level:levelSelected AndWorld:world] autorelease];
    [self addChild:babyHamster.sprite z:BABYHAMSTERTAG tag:BABYHAMSTERTAG];
    CCAction *babyBlinkAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[babyHamster startAnimWithTag:BLINK]];
    [babyHamster.sprite runAction:babyBlinkAction];
    
    //mother hamster
    self.motherHamster = [[(MotherHamster *)[MotherHamster alloc] initWithPos:ccp(screenSize.width*0.8, screenSize.height*0.13)] autorelease];
    [self addChild:motherHamster.sprite z:MOTHERHAMSTERTAG tag:MOTHERHAMSTERTAG];
    
    //cage
    self.cage = [[(Cage *)[Cage alloc] initWithPos:ccp(screenSize.width*0.8, screenSize.height*0.7) AndWorld:world] autorelease];
    [self addChild:cage.sprite z:CAGEFRONTTAG tag:CAGEFRONTTAG];
    [self addChild:cage.spriteBack z:CAGEBACKTAG tag:CAGEBACKTAG];  
    
    //floater
    self.floater = [[(Floater *)[Floater alloc] initWithPos:ccp(screenSize.width*0.12, screenSize.height*0.65) move:RIGHT AndWorld:world] autorelease];
    [self addChild:floater.sprite z:FLOATERTAG tag:FLOATERTAG];  
    
    //hole
    self.hole = [[(Hole *)[Hole alloc] initWithPos1:ccp(screenSize.width*0.16,screenSize.height*0.75) Angle1:-3.14159f/2 Pos2:ccp(screenSize.width*0.8,screenSize.height*0.45) Angle2:3.14159f/2] autorelease];
    [self addChild:hole.sprite1 z:HOLETAG tag:HOLETAG];
    [self addChild:hole.sprite2 z:HOLETAG tag:HOLETAG];
    
    //blower
    self.blower = [[(Blower *)[Blower alloc] initWithPos:ccp(screenSize.width*0.8, screenSize.height*0.3) Angular:180 Range:screenSize.width] autorelease];
    blower.sprite.scaleY = -1;
    [self addChild:blower.sprite z:BLOWERTAG tag:BLOWERTAG];
    
    //pipe
    self.pipe1 = [[(Pipe *)[Pipe alloc] initWithPos:ccp(screenSize.width*0.16, screenSize.height*0.55) shape:PIPE1 AndWorld:world] autorelease];    
    [self addChild:pipe1.sprite z:PIPETAG tag:PIPETAG];        
    
    //cradle
    self.cradle = [[(Cradle *)[Cradle alloc] initWithPos:ccp(screenSize.width*0.65, screenSize.height*0.08) AndWorld:world] autorelease];
    [self addChild:cradle.sprite z:CRADLETAG tag:CRADLETAG];
    CCAction *cradleSwingAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[cradle startAnimWithTag:SWING]];
    [cradle.sprite runAction:cradleSwingAction];
    
    //carrot
    self.carrot = [[(Carrot *)[Carrot alloc] initWithPos1:ccp(screenSize.width*0.2383, screenSize.height*0.4) Pos2:ccp(screenSize.width*0.8, screenSize.height*0.55) Pos3:ccp(screenSize.width*0.6, screenSize.height*0.2)] autorelease];
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
    else {
        [floater autoMoveWithDistance:screenSize.width*0.2];
    }
    
    [babyHamster checkContactWithFloater:floater];
    
    [babyHamster checkInBoundary:motherHamster widthFactor:1];
    
    [babyHamster checkCarrotCollected:carrot];
    
    [self updateCarrotBar];
    
    [babyHamster checkFallInCradle:cradle mother:motherHamster carrot:carrot timeUsed:timer];
    
    [babyHamster checkContactWithGround:motherHamster];
    
    [babyHamster checkTeleport:hole];
    
    [babyHamster checkTeleportImpulse:hole];
    
    if (babyHamster.teleportingFlag)
        [self detachFloater];
    
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
            /*
             if (sprite == bucket.sprite) {
             bucket.spriteBack.position = sprite.position;
             bucket.spriteBack.rotation = sprite.rotation;
             }
             */
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
                //destroy joint between baby hamster and floater
                if (!floater.endContactWithBabyHamster && floater.body->IsAwake()) {
                    world->DestroyJoint(floater.jointWithBabyHamster);
                    floater.endContactWithBabyHamster = YES;
                }
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

- (void) dealloc
{    
    [babyHamster release];
    [motherHamster release];
    [cage release];
    [pipe1 release];
    [cradle release];
    [carrot release];
    [floater release];
    [hole release];
    [blower release];
    [carrotBarSprite release];
    delete world;
    
    [super dealloc];
}


@end
