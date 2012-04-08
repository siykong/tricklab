//
//  Level11GameObjects.m
//  TrickLab
//
//  Created by Siyao Kong on 2/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Level12GameObjects.h"
#import "GameScene.h"
#import "PhysicsObject.h"
#import "AppDelegate.h"

@interface Level12GameObjects (PrivateMethods)

- (void) updateObjectStatus;
- (CGPoint) locationFromTouch:(UITouch *)touch;
- (void) instantiateGameObjects;
- (void) updateCarrotBar;
- (void) updateMotherAnimation;
- (void) updateTimeUsed;

@end


@implementation Level12GameObjects

@synthesize world;
@synthesize cage;
@synthesize babyHamster;
@synthesize motherHamster;
@synthesize pipe1;
@synthesize pipe3;
@synthesize blower1;
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
        windowSprite = [CCSprite spriteWithFile:WINDOW_NIGHT_SPRITE];
        windowSprite.position = ccp(screenSize.width*0.8, screenSize.height*0.88);
        [self addChild:windowSprite z:LEVELBGTAG tag:LEVELBGTAG];
        CCSprite *levelBgSprite = [CCSprite spriteWithFile:LEVELBG_NIGHT_SPRITE];
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
        self.isAccelerometerEnabled = YES;
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationPortrait)
            upsideDown = NO;
        else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
            upsideDown = YES;
        else {
            CCLOG(@"orientation: %d", orientation);
        }
        //CCLOG(@"upsideDown %d", [UIApplication sharedApplication].statusBarOrientation);
        
        //lock screen        
        [(AppController *)[[CCDirector sharedDirector] delegate] setIsAccelerometerEnabled:YES];
    }
    
    return self;
}

- (void) instantiateGameObjects
{
    //baby hamster
    self.babyHamster = [[(BabyHamster *)[BabyHamster alloc] initWithPos:ccp(screenSize.width*0.80, screenSize.height*0.15) level:levelSelected AndWorld:world] autorelease];
    [self addChild:babyHamster.sprite z:BABYHAMSTERTAG tag:BABYHAMSTERTAG];
    CCAction *babyBlinkAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[babyHamster startAnimWithTag:BLINK]];
    [babyHamster.sprite runAction:babyBlinkAction];
    
    //mother hamster
    self.motherHamster = [[(MotherHamster *)[MotherHamster alloc] initWithPos:ccp(screenSize.width*0.15, screenSize.height*0.8)] autorelease];
    motherHamster.sprite.scaleX = -1;
    [self addChild:motherHamster.sprite z:MOTHERHAMSTERTAG tag:MOTHERHAMSTERTAG];
    
    //cage
    self.cage = [[(Cage *)[Cage alloc] initWithPos:ccp(screenSize.width*0.80, screenSize.height*0.17) AndWorld:world] autorelease];
    [self addChild:cage.sprite z:CAGEFRONTTAG tag:CAGEFRONTTAG];
    [self addChild:cage.spriteBack z:CAGEBACKTAG tag:CAGEBACKTAG];  
    
    //blower1
    self.blower1 = [[(Blower *)[Blower alloc] initWithPos:ccp(screenSize.width*0.5, screenSize.height*0.35) Angular:45 Range:screenSize.width*0.5] autorelease];
    [self addChild:blower1.sprite z:BLOWERTAG tag:BLOWERTAG];
    
    //pipe1
    self.pipe1 = [[(Pipe *)[Pipe alloc] initWithPos:ccp(screenSize.width*0.30, screenSize.height*0.4) shape:PIPE1 AndWorld:world] autorelease];    
    [self addChild:pipe1.sprite z:PIPETAG tag:PIPETAG];
    
    //pipe3
    self.pipe3 = [[(Pipe *)[Pipe alloc] initWithPos:ccp(screenSize.width*0.45, screenSize.height*0.85) shape:PIPE3 AndWorld:world] autorelease];    
    [self addChild:pipe3.sprite z:PIPETAG tag:PIPETAG];        
    
    //cradle
    self.cradle = [[(Cradle *)[Cradle alloc] initWithPos:ccp(screenSize.width*0.25, screenSize.height*0.75) AndWorld:world] autorelease];
    [self addChild:cradle.sprite z:CRADLETAG tag:CRADLETAG];
    CCAction *cradleSwingAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[cradle startAnimWithTag:SWING]];
    [cradle.sprite runAction:cradleSwingAction];
    
    //carrot
    self.carrot = [[(Carrot *)[Carrot alloc] initWithPos1:ccp(screenSize.width*0.37, screenSize.height*0.25) Pos2:ccp(screenSize.width*0.58, screenSize.height*0.5) Pos3:ccp(screenSize.width*0.62, screenSize.height*0.8)] autorelease];
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
    [babyHamster checkInBoundary:motherHamster widthFactor:1];
    
    [babyHamster checkCarrotCollected:carrot];
    
    [self updateCarrotBar];
    
    [babyHamster checkFallInCradle:cradle mother:motherHamster carrot:carrot timeUsed:timer];
    
    //[babyHamster checkContactWithGround:motherHamster];
    
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
        
        if (!cage.open && CGRectContainsPoint(cage.sprite.boundingBox, touchPoint)){
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
        else if (CGRectContainsPoint(blower1.sprite.boundingBox, touchPoint)){
            //blower1
            [babyHamster checkInBlowerRange:blower1];
            CCAction *blowerAction = [[CCAnimationCache sharedAnimationCache] actionWithAnimate:[blower1 startAnimWithTag:BLOW]];
            [blower1.sprite runAction:blowerAction];
            [blower1 playParticleEffect];
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

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    CCRotateTo *rotate;
    if (upsideDown == NO) {
        //gravity
        float m = sqrtf(powf(acceleration.x, 2)+powf(acceleration.y, 2));
        world->SetGravity(b2Vec2(acceleration.x/m*4, acceleration.y/m*4));
        //windowSprite
        if (acceleration.y < 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:CC_RADIANS_TO_DEGREES(atanf(acceleration.x/acceleration.y))];
        else if (acceleration.y > 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:180+CC_RADIANS_TO_DEGREES(atanf(acceleration.x/acceleration.y))];
        else if (acceleration.x > 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:-90];
        else if (acceleration.x < 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:90];
    }
    else {
        //gravity
        float m = sqrtf(powf(acceleration.x, 2)+powf(acceleration.y, 2));
        world->SetGravity(b2Vec2(-acceleration.x/m*4, -acceleration.y/m*4));
        //windowSprite
        if (acceleration.y < 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:180+CC_RADIANS_TO_DEGREES(atanf(acceleration.x/acceleration.y))];
        else if (acceleration.y > 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:CC_RADIANS_TO_DEGREES(atanf(acceleration.x/acceleration.y))];
        else if (acceleration.x > 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:90];
        else if (acceleration.x < 0)
            rotate = [CCRotateTo actionWithDuration:0.1 angle:-90];
    }    
    [windowSprite runAction:rotate];
}

- (void) dealloc
{    
    [babyHamster release];
    [motherHamster release];
    [cage release];
    [pipe1 release];
    [pipe3 release];
    [blower1 release];
    [cradle release];
    [carrot release];
    [carrotBarSprite release];
    delete world;
    
    [super dealloc];
}


@end

