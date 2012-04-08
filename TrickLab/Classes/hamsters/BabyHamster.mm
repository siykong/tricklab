//
//  BabyHamster.m
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BabyHamster.h"
#import "LevelUI.h"
#import "GameOverScene.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

#define BABYHAMSTER_ANGULARDAMPING 0.05f
#define BABYHAMSTER_BLINK_0_FRM @"baby_blink_0.png"
#define BABYHAMSTER_BLINK_ANIM @"baby_blink"
#define BABYHAMSTER_DEAD_ANIM @"baby_dead"
#define BABYHAMSTER_EATEN_ANIM @"baby_eaten"
#define BABYHAMSTER_SHAPE @"baby_hamster_shape"
#define BABYHAMSTER_ID @"BABYHAMSTER"


@interface BabyHamster (PrivateMethods)

- (void) autoReplay;

@end


@implementation BabyHamster

@synthesize succeed;
@synthesize failure;
@synthesize teleportingFlag;
@synthesize vulnerableToOwl;
@synthesize contactWithPipe;

- (id) initWithPos: (CGPoint)pos level:(int)levelSel AndWorld: (b2World *)world
{
    if ((self=[super init])) {          
        
        //set obj id
        self.objId = BABYHAMSTER_ID;
        
        //set obj sprite
        [self addSpriteAt:pos WithFrameName:BABYHAMSTER_BLINK_0_FRM];
        
        //create body def for baby hamster
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position = toMeters(pos);
        bodyDef.userData = self;
        bodyDef.angularDamping = BABYHAMSTER_ANGULARDAMPING;
        
        //create body for baby hamster
        body = world->CreateBody(&bodyDef);        
        
        //create shape and fixture for body
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:BABYHAMSTER_SHAPE];
        [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:BABYHAMSTER_SHAPE]];
        
        //not active at start
        [self deactivate];
        
        succeed = NO;
        failure = NO;
        levelSelected = levelSel;
        
        teleportingFlag = NO;
        
        vulnerableToOwl = YES;
        
        contactWithPipe = NO;
    }
    return self;
}

- (NSString *)startAnimWithTag:(int)tag
{
    NSString *animName;
    
    switch (tag) {
        case BLINK:
            animName = BABYHAMSTER_BLINK_ANIM;
            break;
        case DEAD:
            animName = BABYHAMSTER_DEAD_ANIM;
            break;
        case EATEN:
            animName = BABYHAMSTER_EATEN_ANIM;
            break;   
            
        default:
            break;
    }

    [sprite setDisplayFrameWithAnimationName:animName index:0];
    return animName;
}

//check if baby hamster is within screen (at least part of it)
- (void) checkInBoundary:(MotherHamster *)mom widthFactor:(int)wf
{
    //CCLOG(@"BabyHamster::checkInBoundry");

    if (!checkObjectInBoundry(sprite, wf) && !failure) {

        failure = YES;
        
        //play mom sad animation
        CCCallBlock *momSadAction = [CCCallBlock actionWithBlock:^{
            CCAction *motherSadAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[mom startAnimWithTag:SAD] times:1];
            [mom.sprite runAction:motherSadAction];
        }];        
        
        //delay action
        id delayAction = [CCDelayTime actionWithDuration:1.5f];
        
        //auto replay
        CCCallBlock *autoReplayAction = [CCCallBlock actionWithBlock:^{
            [self autoReplay];
        }];
        
        [sprite runAction:[CCSequence actions:momSadAction, delayAction, autoReplayAction, nil]];     
    }
     
}

- (void) autoReplay
{
    //resume auto rotate
    [(AppController *)[[CCDirector sharedDirector] delegate] setIsAccelerometerEnabled:NO];

    //auto replay current level
    CCLOG(@"babyHamster::autoReplay:levelSel:%i",levelSelected);
    CCScene *gameScene = [[(GameScene *)[GameScene alloc] initWithLevelNumber:levelSelected] autorelease];
    CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:gameScene withColor:ccWHITE];
    [[CCDirector sharedDirector] replaceScene:transitionScene];     
}

//check if baby hamster is close enough to floater
- (void) checkContactWithFloater:(Floater *)floater
{
    //CCLOG(@"BabyHamster::checkContactWithFloater");
    
    if (!floater.endContactWithBabyHamster) {
        if (!floater.startContactWithBabyHamster){            
            
            CGPoint floaterPos = floater.sprite.position;
            CGPoint babyHamsterPos = sprite.position;
            float half_floaterHeight = floater.sprite.contentSize.height/2;
            float half_babyHamsterHeight = sprite.contentSize.height/2;
            
            if (ccpDistance(babyHamsterPos, floaterPos) <= (half_babyHamsterHeight+half_floaterHeight) && babyHamsterPos.y < floaterPos.y){   
                
                //play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:SFX_FLOATER];
                
                //create joint between baby hamster and floater
                b2WeldJointDef jointDef;
                jointDef.Initialize(floater.body, body, floater.body->GetWorldCenter());
                jointDef.localAnchorB = b2Vec2(0,(floater.sprite.contentSize.height/2*0.86f+sprite.contentSize.height/2)/PTM_RATIO);                
                jointDef.referenceAngle = 0;
                floater.jointWithBabyHamster = (b2WeldJoint *)floater.body->GetWorld()->CreateJoint(&jointDef);
                
                /* test
                 CCLOG(@"floater world center:(%f,%f)",toPixels(floater.body->GetWorldCenter()).x,toPixels(floater.body->GetWorldCenter()).y);
                 CCLOG(@"floater pos:(%f,%f)",floaterPos.x,floaterPos.y);
                 CCLOG(@"localAnchorA:(%f,%f)",toPixels(jointDef.localAnchorA).x,toPixels(jointDef.localAnchorA).y);
                 CCLOG(@"baby world center:(%f,%f)",toPixels(body->GetWorldCenter()).x,toPixels(body->GetWorldCenter()).y);
                 CCLOG(@"baby pos:(%f,%f)",babyHamsterPos.x,babyHamsterPos.y);
                 CCLOG(@"localAnchorB:(%f,%f)",toPixels(jointDef.localAnchorB).x,toPixels(jointDef.localAnchorB).y);
                 */
                
                //set floater angle
                floater.body->SetTransform(toMeters(floaterPos), body->GetAngle());
                
                //play floater animation
                CCAction *action = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[floater startAnimWithTag:ROTATE]];
                [floater.sprite runAction:action];
                
                //update contact flag
                floater.startContactWithBabyHamster = YES;                
            } 
        }
    }
    else{
        floater.startContactWithBabyHamster = NO;
    }       
}


//check if baby hamster is inside the bucket
- (bool) checkInsideBucket:(Bucket *)bucket
{
    //CCLOG(@"BabyHamster::checkInsideBucket");
    
    CGPoint babyHamsterPos = sprite.position;    
    
    if (CGRectContainsPoint(bucket.sprite.boundingBox, babyHamsterPos))
    {
        b2Vec2 pos = body->GetPosition();
        float angle = [bucket getBodyRotation];
        body->SetTransform(pos, angle);
        
        return true;
    }
    
    return false;
}

//check if in the range of blower
- (Boolean) checkInBlowerRange:(Blower *) blower
{
    CGPoint hamsterPos = toPixels(body->GetPosition());
    CGPoint blowerPos = blower.sprite.position;
    float hamsterAngle = atanf((hamsterPos.y-blowerPos.y)/(hamsterPos.x-blowerPos.x));
    float blowerAngle = CC_DEGREES_TO_RADIANS(blower.angular);
    
    //    if (hamsterAngle - blowerAngle < -3.14159/2 || hamsterAngle - blowerAngle > 3.14159/2)  //out of range
//        return NO;
    
    CCLOG(@"blower: %f", ((hamsterPos.x-blowerPos.x)*cosf(blowerAngle) + (hamsterPos.y-blowerPos.y)*sinf(blowerAngle)));
    if ((hamsterPos.x-blowerPos.x)*cosf(blowerAngle) + (hamsterPos.y-blowerPos.y)*sinf(blowerAngle) <= 0)   //wrong direction
        return NO;
    
    //calc distance to blower direction line
    float distanceToBlowerOrigin = sqrtf(powf(blowerPos.y-hamsterPos.y, 2) + powf(blowerPos.x-hamsterPos.x, 2));
    
    float blowerRange = blower.range;
    if (distanceToBlowerOrigin > blowerRange)
        return NO;
    
    float distanceToLine = distanceToBlowerOrigin*sinf(hamsterAngle - blowerAngle);
    
    float blowWidth = blower.blowWidth;
    if (distanceToLine <= blowWidth && distanceToLine >= -blowWidth)
    {
        b2Vec2 impulse = toMeters(CGPointMake(cosf(blowerAngle), sinf(blowerAngle)));
        //normalization
        float module = sqrtf(impulse.x*impulse.x+impulse.y*impulse.y);
        impulse.x = impulse.x/module * 4;
        impulse.y = impulse.y/module * 4;
                                  
        [self applyImpulseByBlower:impulse];
        return YES;
    }
    else
        return NO;
    
}

//blower apply impulse
-(void) applyImpulseByBlower:(b2Vec2) impulse
{
    body->ApplyLinearImpulse(impulse, body->GetPosition());
}

//check if carrot is collected
- (void) checkCarrotCollected:(Carrot *)carrot
{
    id action = [CCFadeOut actionWithDuration:0.3];
    
    float detRadiusX = carrot.sprite1.contentSize.width*0.6;
    float detRadiusY = carrot.sprite1.contentSize.height*0.6;
    
    CGRect carrot1DetRect = CGRectMake(carrot.sprite1.position.x-detRadiusX/2, carrot.sprite1.position.y-detRadiusY/2, detRadiusX, detRadiusY);
    CGRect carrot2DetRect = CGRectMake(carrot.sprite2.position.x-detRadiusX/2, carrot.sprite2.position.y-detRadiusY/2, detRadiusX, detRadiusY);
    CGRect carrot3DetRect = CGRectMake(carrot.sprite3.position.x-detRadiusX/2, carrot.sprite3.position.y-detRadiusY/2, detRadiusX, detRadiusY);
    
    if (!carrot.sprite1Collected && CGRectContainsPoint(carrot1DetRect, sprite.position)) {
        carrot.sprite1Collected = YES;
        carrot.numOfCarrotCollected++;
        //sfx
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_CARROT_0];
        //particle effects
        CCParticleSystem *particleCarrot = [CCParticleSystemQuad particleWithFile:@"particle_carrot.plist"];
        particleCarrot.position = carrot.sprite1.position;
        [sprite.parent addChild:particleCarrot z:PARTICLECARROTTAG tag:PARTICLECARROTTAG];
        //carrot1 fade out        
        [carrot.sprite1 runAction:action];
    }
    if (!carrot.sprite2Collected && CGRectContainsPoint(carrot2DetRect, sprite.position)) {
        carrot.sprite2Collected = YES;
        carrot.numOfCarrotCollected++;
        //sfx
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_CARROT_1];
        //particle effects
        CCParticleSystem *particleCarrot = [CCParticleSystemQuad particleWithFile:@"particle_carrot.plist"];
        particleCarrot.position = carrot.sprite2.position;
        [sprite.parent addChild:particleCarrot z:PARTICLECARROTTAG tag:PARTICLECARROTTAG];
        //carrot2 fade out        
        [carrot.sprite2 runAction:action];
    }
    if (!carrot.sprite3Collected && CGRectContainsPoint(carrot3DetRect, sprite.position)) {
        carrot.sprite3Collected = YES;
        carrot.numOfCarrotCollected++;
        //sfx
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_CARROT_2];
        //particle effects
        CCParticleSystem *particleCarrot = [CCParticleSystemQuad particleWithFile:@"particle_carrot.plist"];
        particleCarrot.position = carrot.sprite3.position;
        [sprite.parent addChild:particleCarrot z:PARTICLECARROTTAG tag:PARTICLECARROTTAG];
        //carrot3 fade out        
        [carrot.sprite3 runAction:action];
    }
}

- (void) checkFallInCradle:(Cradle *)cradle mother:(MotherHamster *)mom WithoutBucket:(Bucket *)bucket carrot:(Carrot *)carrot timeUsed:(float)timer
{    
    if (!CGRectIntersectsRect(cradle.sprite.boundingBox, bucket.sprite.boundingBox)) {
        [self checkFallInCradle:cradle mother:mom carrot:carrot timeUsed:timer];
    }
}

- (void) checkFallInCradle:(Cradle *)cradle mother:(MotherHamster *)mom carrot:(Carrot *)carrot timeUsed:(float)timer
{
    if (!succeed && CGRectContainsRect(cradle.sprite.boundingBox, sprite.boundingBox)) {
        
        CCLOG(@"========fall in cradle");
        
        succeed = YES; 
        
        //baby hamster fade out
        id fadeOutAction = [CCFadeOut actionWithDuration:0.15f];
        //delay action for baby fadeout
        id delayAction1 = [CCDelayTime actionWithDuration:0.15f];
        //play cradle_succeed animation
        CCCallBlock *cradleAction = [CCCallBlock actionWithBlock:^{
            CCAction *action = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[cradle startAnimWithTag:SUCCEED] times:1];
            [cradle.sprite runAction:action];
        }];
        //delay action for cradle_succeed animation
        id delayAction2 = [CCDelayTime actionWithDuration:2.7f];
        //action: go to game over scene
        CCCallBlock *gameOverAction = [CCCallBlock actionWithBlock:^{            
            CCLOG(@"babyHamster::gameover::levelSel:%i;carrot:%i",levelSelected,carrot.numOfCarrotCollected);
            CCScene *gameOverScene = [GameOverScene scene:levelSelected carrot:carrot.numOfCarrotCollected timeUsed:timer];
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:gameOverScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }];
        //play mother happy animation
        CCAction *momHappyAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[mom startAnimWithTag:HAPPY] times:2];
        [mom.sprite runAction:momHappyAction];
        //run actions in sequence
        [sprite runAction:[CCSequence actions:fadeOutAction, delayAction1, cradleAction, delayAction2, gameOverAction, nil]];            
    }
}

//check if babyhamster is in teleport spot
- (void) checkTeleport:(Hole *)hole
{
    if (teleportingFlag) {
        return;
    }
    
    CGPoint bodyPos = toPixels(body->GetWorldCenter());
    CGPoint hole1Pos = hole.sprite1.position;
    CGPoint hole2Pos = hole.sprite2.position;
    Boolean hole1 =  CGRectContainsPoint(hole.sprite1.boundingBox, bodyPos);
    Boolean hole2 =  CGRectContainsPoint(hole.sprite2.boundingBox, bodyPos);
    
    if (hole.teleportFlag && (hole1 || hole2)) // allow teleport
    {
        float cur_velocity = sqrtf(powf(body->GetLinearVelocity().x, 2) + powf(body->GetLinearVelocity().y, 2));
        if (hole1) {        //1 -> 2
            if (body->GetLinearVelocity().x*cosf(hole.angle1) + body->GetLinearVelocity().y*sinf(hole.angle1) >= 0) //wrong direction
                return;
            //set position
            teleportPos = toMeters(hole2Pos);
            //set velocity
            teleportVel = b2Vec2(cur_velocity*cosf(hole.angle2), cur_velocity*sinf(hole.angle2));
        }
        else if(hole2){     //2 -> 1
            if (body->GetLinearVelocity().x*cosf(hole.angle2) + body->GetLinearVelocity().y*sinf(hole.angle2) >= 0) //wrong direction
                return;
            //set position
            teleportPos = toMeters(hole1Pos);
            //set velocity
            teleportVel = b2Vec2(cur_velocity*cosf(hole.angle1), cur_velocity*sinf(hole.angle1));
        }
        
        hole.teleportFlag = NO;
        hole.impulseFlag = NO;
        teleportingFlag = YES;
        
        //baby hamster fade out
        float fadeoutTime = sprite.contentSize.height/2/cur_velocity/PTM_RATIO;
        id fadeOutAction = [CCFadeOut actionWithDuration:fadeoutTime];
        id stopMotionAction = [CCCallFunc actionWithTarget:self selector:@selector(stopMotion)];
        id startMotionAction = [CCCallFunc actionWithTarget:self selector:@selector(startMotion)];
        id delayAction = [CCDelayTime actionWithDuration:0.5f];
        id teleportAction = [CCCallFunc actionWithTarget:self selector:@selector(teleport) ];
        [sprite runAction:[CCSequence actions:fadeOutAction,stopMotionAction,delayAction,startMotionAction,teleportAction, nil]];
        
    }
    else    //not allow teleport, wait until hamster leave teleport region
    {
        if (!hole1 && !hole2)
            hole.teleportFlag = YES;
    }
    
}

- (void) stopMotion
{
    body->SetType(b2_staticBody);
}

- (void) startMotion
{
    body->SetType(b2_dynamicBody);
}

- (void) teleport
{
    body->SetTransform(teleportPos, 0);
    body->SetLinearVelocity(teleportVel);
    
    id fadeInAction = [CCFadeIn actionWithDuration:0.15f];
    [sprite runAction:fadeInAction];
    
    teleportingFlag = NO;
}

//check if babyhamster is in teleport impulse region
- (void) checkTeleportImpulse:(Hole *)hole
{
    if (teleportingFlag) {
        return;
    }
    
    CGPoint bodyPos = toPixels(body->GetWorldCenter());
    CGPoint hole1Pos = hole.sprite1.position;
    CGPoint hole2Pos = hole.sprite2.position;
    float distance1 = sqrtf(powf(bodyPos.x-hole1Pos.x, 2) + powf(bodyPos.y-hole1Pos.y, 2));
    float distance2 = sqrtf(powf(bodyPos.x-hole2Pos.x, 2) + powf(bodyPos.y-hole2Pos.y, 2));
    
    if (hole.impulseFlag) // allow impulse
    {
        if (distance1 < hole.ImpulseRegionRadius) {
            if (body->GetLinearVelocity().x*cosf(hole.angle1) + body->GetLinearVelocity().y*sinf(hole.angle1) >= 0) //wrong direction
                return;
            float factor = 20/distance1;
            CGPoint impulse = CGPointMake(hole1Pos.x-bodyPos.x, hole1Pos.y-bodyPos.y);
            impulse.x *= factor;
            impulse.y *= factor;
            body->ApplyLinearImpulse(toMeters(impulse), body->GetPosition());
        }
        else if(distance2 < hole.ImpulseRegionRadius){   
            if (body->GetLinearVelocity().x*cosf(hole.angle2) + body->GetLinearVelocity().y*sinf(hole.angle2) >= 0) //wrong direction
                return;
            float factor = 20/distance2;  
            CGPoint impulse = CGPointMake(hole2Pos.x-bodyPos.x, hole2Pos.y-bodyPos.y);
            impulse.x *= factor;
            impulse.y *= factor;
            body->ApplyLinearImpulse(toMeters(impulse), body->GetPosition());
        }
    }
    else    //not allow teleport, wait until hamster leave teleport region
    {
        if (distance1 > hole.ImpulseRegionRadius && distance2 > hole.ImpulseRegionRadius)
            hole.impulseFlag = YES;
    }
    
}

//reduce horizontal speed -- call every frame when stick to floater
- (void) reduceHorizontalSpeed
{
    b2Vec2 impulse(-body->GetLinearVelocity().x/10, 0);
    body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
}

//check if baby hamster is killed by owl
- (bool) checkInOwlRange:(Owl *)owl mother:(MotherHamster *)mom LevelLayer:(CCLayer *)layer
{
    if (vulnerableToOwl && owl.active && !failure)
    {
        CGPoint bodyPos = toPixels(body->GetWorldCenter());
        CGPoint owlPos = owl.sprite.position;
        float distanceToOwl = sqrtf(powf(bodyPos.x-owlPos.x, 2) + powf(bodyPos.y-owlPos.y, 2));
        if (distanceToOwl < owl.range)
        {
            //baby hamster is dead
            CGSize winSize = [[CCDirector sharedDirector] winSize];
            
            failure = YES;
            body->SetType(b2_staticBody);
            [owl.sprite stopAllActions];
            [layer unschedule:@selector(updateOwlAnimation)];
            [layer reorderChild:owl.sprite z:OWLATTACKTAG];
            
            CCMoveTo *move1 = [CCMoveTo actionWithDuration:1.5f position:bodyPos];
            CCEaseInOut *easeMove1 = [CCEaseInOut actionWithAction:move1 rate:2];
            CCMoveBy *move2 = [CCMoveBy actionWithDuration:3.0f position:ccp(0, winSize.height*2)];
            CCEaseInOut *easeMove2 = [CCEaseInOut actionWithAction:move2 rate:2];
            
            //play mom sad animation
            CCCallBlock *momSadAction = [CCCallBlock actionWithBlock:^{
                CCAction *momSadAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[mom startAnimWithTag:SAD] times:3];
                [mom.sprite runAction:momSadAction];
            }];        
            
            //play baby dead animation
            CCAction *action = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[self startAnimWithTag:EATEN]];
            [sprite runAction:action];
            
            //delay action
            id delayAction = [CCDelayTime actionWithDuration:1.5f];
            
            //auto replay
            CCCallBlock *autoReplayAction = [CCCallBlock actionWithBlock:^{
                [self autoReplay];
            }];
            
            //babyhamster fade out
            CCFadeOut *fadeout = [CCFadeOut actionWithDuration:0.2f];
            
            [sprite runAction:[CCSequence actions:momSadAction, delayAction, fadeout, nil]]; 
            [owl.sprite runAction:[CCSequence actions:easeMove1, easeMove2, autoReplayAction, nil]];
            [owl owlAttackAnimation];
            return YES;
        }
    }
    return NO;
}

//set vulnerableToOwl to false if in the cage
- (void) checkVulnerableToOwl:(Cage *)cage
{
    if (CGRectIntersectsRect(cage.sprite.boundingBox, sprite.boundingBox))
        vulnerableToOwl = NO;
    else
        vulnerableToOwl = YES;
}


- (void) checkContactWithGround:(MotherHamster *)mom
{
    //CCLOG(@"BabyHamster::checkContactWithGround");
    
    if (!failure && sprite.position.y <= sprite.contentSize.height/2+10) {
        
        CCLOG(@"====babyTouchGroundVel:%f",body->GetLinearVelocity().y);
        
        failure = YES;
        
        //play baby dead animation
        CCAction *action = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:[self startAnimWithTag:DEAD]];
        [sprite runAction:action];
        
        //play mom sad animation
        CCAction *momSadAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:[mom startAnimWithTag:SAD] times:1];
        [mom.sprite runAction:momSadAction];
        
        //delay action
        id delayAction = [CCDelayTime actionWithDuration:1.5f];
        
        //auto replay
        CCCallBlock *autoReplayAction = [CCCallBlock actionWithBlock:^{
            [self autoReplay];
        }];
        
        [sprite runAction:[CCSequence actions:delayAction, autoReplayAction, nil]];
    }
}

- (void) deactivate
{
    //set to false to put body to sleep, true to wake it.
    body->SetAwake(NO);
    body->SetActive(NO);
}

- (void) activate
{
    body->SetAwake(YES);
    body->SetActive(YES);
}

@end

