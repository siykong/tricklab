//
//  MainMenuLayer.m
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "LevelSelection.h"
#import "SettingsLayer.h"
#import "MainMenuScene.h"

#define MAINMENUBG_SPRITE @"mainmenu_bg.png"
#define GROUND_SPRITE @"ground.png"
#define LONG_BTN_FRM @"long_btn.png"
#define LONG_BTN_SEL_FRM @"long_btn_sel.png"
#define FNT_BTN @"Hobo Std"
#define FNT_SIZE_BTN 35
#define CARROT_GLOW_0_FRM @"carrot_glow_0.png"
#define CARROT_GLOW_ANIM @"carrot_glow"
#define CREDIT_0_FRM @"credit_0.png"
#define CREDIT_SHOW_ANIM @"credit_show"
#define CREDIT_HIDE_ANIM @"credit_hide"
#define ARROW_UP_FRM @"arrow_up.png"
#define ARROW_DOWN_FRM @"arrow_down.png"
#define CREDIT_SPRITE @"credit_info.png"


@interface MainMenuLayer (PrivateMethods)

- (CGPoint) locationFromTouch:(UITouch *)touch;
- (CGPoint) previousLocationFromTouch:(UITouch *)touch;
- (void) updateArrow;
- (void) updateCredit;
- (void) scroll1;
- (void) scroll2;

@end


@implementation MainMenuLayer

@synthesize arrowUp;
@synthesize arrowDown;
@synthesize parchmentSprite;
@synthesize carrotSprite;
@synthesize creditSprite1;
@synthesize creditSprite2;
@synthesize credit;

- (id) init
{
    if ((self=[super init])) {
        
        screenSize = [[CCDirector sharedDirector] winSize];
        
        //main menu background
        CCSprite *menuBg = [CCSprite spriteWithFile:MAINMENUBG_SPRITE];
        menuBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:menuBg z:MAINMENUBG];
        
        //play button
        CCMenuItemSprite *playBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            if (!creditOpen) {
                CCLOG(@"play button");
                CCScene *levelSelectionScene = [LevelSelection scene];
                CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:levelSelectionScene withColor:ccWHITE];
                [[CCDirector sharedDirector] replaceScene:transitionScene];
            }            
        }];
        playBtn.position = ccp(screenSize.width*0.25f, screenSize.height*0.45f);
        
        //settings button
        CCMenuItemSprite *settingsBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            if (!creditOpen) {
                CCLOG(@"settings button");
                //layer for detail settings
                SettingsLayer *settings = [SettingsLayer node];
                [self.parent addChild:settings z:SETTINGS tag:SETTINGS];
            }            
        }];
        settingsBtn.position = ccp(screenSize.width*0.25f, screenSize.height*0.32f);
        
        CCMenu *menu = [CCMenu menuWithItems:playBtn, settingsBtn, nil];
        menu.position = CGPointZero;    
        [self addChild:menu z:MAINMENUBTNMENU];
        
        //add font
        CCLabelTTF *playLabel = [CCLabelTTF labelWithString:@"Play" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        playLabel.color = ccBLACK;
        playLabel.position = ccp(playBtn.position.x, playBtn.position.y*0.99);
        [self addChild:playLabel z:MAINMENUFONT];
        
        CCLabelTTF *settingsLabel = [CCLabelTTF labelWithString:@"Settings" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        settingsLabel.color = ccBLACK;
        settingsLabel.position = ccp(settingsBtn.position.x, settingsBtn.position.y*0.99);
        [self addChild:settingsLabel z:MAINMENUFONT];
        
        //carrot glow animation
        self.carrotSprite = [CCSprite spriteWithSpriteFrameName:CARROT_GLOW_0_FRM];
        carrotSprite.position = ccp(screenSize.width*0.77f, screenSize.height*0.11f);
        carrotOriginPos = carrotSprite.position;
        [self addChild:carrotSprite z:CARROTGLOW];
        [carrotSprite setDisplayFrameWithAnimationName:CARROT_GLOW_ANIM index:0];
        CCAction *carrotGlowAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:CARROT_GLOW_ANIM];
        [carrotSprite runAction:carrotGlowAction];
        
        //parchment for credit
        self.parchmentSprite = [CCSprite spriteWithSpriteFrameName:CREDIT_0_FRM];
        parchmentSprite.position = ccp(screenSize.width/2, screenSize.height/2);
        
        //ground sprite
        CCSprite *groundSprite = [CCSprite spriteWithFile:GROUND_SPRITE];
        groundSprite.position = ccp(groundSprite.contentSize.width/2, groundSprite.contentSize.height/2);
        [self addChild:groundSprite z:GROUND];
        
        creditOpen = NO;
        
        //intact credit img
        self.credit = [CCSprite spriteWithFile:CREDIT_SPRITE];
        
        //set flags
        flagForCredit1 = NO;
        flagForCredit2 = NO;
        
        //arrow
        self.arrowUp = [CCSprite spriteWithSpriteFrameName:ARROW_UP_FRM];
        arrowUp.opacity = 0;
        [self addChild:arrowUp z:ARROW_UP];
        self.arrowDown = [CCSprite spriteWithSpriteFrameName:ARROW_DOWN_FRM];
        arrowDown.opacity = 0;
        [self addChild:arrowDown z:ARROW_DOWN];
        
        [self updateArrow];
        [self schedule:@selector(updateArrow) interval:5];  
        [self schedule:@selector(updateCredit) interval:0.1];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void) updateArrow
{
    id fadeIn = [CCFadeIn actionWithDuration:0.5f];
    id fadeOut = [CCFadeOut actionWithDuration:0.5f];    
    id delay = [CCDelayTime actionWithDuration:2.5];
    
    if (!creditOpen) {       
        arrowUp.position = ccp(screenSize.width*0.87, screenSize.height*0.01);    
        id moveUp = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width*0.87, screenSize.height*0.13)];
        id moveDown = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width*0.87, screenSize.height*0.07)];
        [arrowUp runAction:fadeIn];
        [arrowUp runAction:[CCSequence actions:moveUp,moveDown,moveUp,moveDown,moveUp,moveDown, nil]];
        [arrowUp runAction:[CCSequence actions:delay, fadeOut, nil]];
    }
    else {
        arrowDown.position = ccp(screenSize.width*0.87, screenSize.height*0.19);
        id moveUp = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width*0.87, screenSize.height*0.15)];
        id moveDown = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width*0.87, screenSize.height*0.1)];
        [arrowDown runAction:fadeIn];
        [arrowDown runAction:[CCSequence actions:moveDown,moveUp,moveDown,moveUp,moveDown,moveUp, nil]];
        [arrowDown runAction:[CCSequence actions:delay, fadeOut, nil]];
    }
    
}

- (void) scroll1
{
    //scroll credit    
    CGRect rect = creditSprite1.textureRect;
    rect.origin.y +=1;
    [creditSprite1 setTextureRect:rect];
    
    if (rect.origin.y == credit.contentSize.height*0.7) {
        CCLOG(@"unschedule");
        [self unschedule:@selector(scroll1)];
    }
}

- (void) scroll2
{
    //scroll credit    
    CGRect rect = creditSprite2.textureRect;
    rect.origin.y +=1;
    [creditSprite2 setTextureRect:rect];
    
    if (rect.origin.y == credit.contentSize.height*0.7) {
        CCLOG(@"unschedule");
        [self unschedule:@selector(scroll2)];
    }
}

- (void) updateCredit
{
    if (creditOpen) {

        if (!flagForCredit1 && (creditSprite1.textureRect.origin.y >= credit.contentSize.height*0.5185)) {
            CCLOG(@"=====creditsprite1");
            //reset flags
            flagForCredit1 = YES;
            flagForCredit2 = NO;
            //remove credit2 img
            if (creditSprite2 != nil) {
                [self removeChild:creditSprite2 cleanup:YES];
            }                
            //set credit2 img display area
            creditSprite2.textureRect = CGRectMake(0, 0, credit.contentSize.width, credit.contentSize.height*0.3);
            [self addChild:creditSprite2 z:CREDIT];   
            
            [self schedule:@selector(scroll2) interval:0.1];
        }
        
        if (!flagForCredit2 && creditSprite2.textureRect.origin.y >= credit.contentSize.height*0.5185) {
            CCLOG(@"=====creditsprite2");
            //reset flags
            flagForCredit2 = YES;
            flagForCredit1 = NO;
            //remove credit1 img
            if (creditSprite1 != nil) {
                [self removeChild:creditSprite1 cleanup:YES];
            } 
            //set credit1 img display area
            creditSprite1.textureRect = CGRectMake(0, 0, credit.contentSize.width, credit.contentSize.height*0.3);
            [self addChild:creditSprite1 z:CREDIT];
            
            [self schedule:@selector(scroll1) interval:0.1];
        }
        
    }     
}


- (CGPoint) locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (CGPoint) previousLocationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch previousLocationInView:[touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (void) registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:-128 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{   
    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [self locationFromTouch:touch];
    CGPoint previousTouchPoint = [self previousLocationFromTouch:touch];
    
    if (!creditOpen && CGRectContainsPoint(carrotSprite.boundingBox, touchPoint) && touchPoint.y>previousTouchPoint.y) {      
        creditOpen = YES;
        
        //stop arrowUp action
        [arrowUp stopAllActions];
        [arrowUp runAction:[CCFadeOut actionWithDuration:0.5]];
        
        //move carrot up
        id move1 = [CCMoveTo actionWithDuration:0.2f position:ccp(carrotOriginPos.x, carrotOriginPos.y*2.1f)]; 
        id move2 = [CCMoveTo actionWithDuration:0.1f position:ccp(carrotOriginPos.x, carrotOriginPos.y*2.0f)]; 
        [carrotSprite runAction:[CCSequence actions:move1, move2, nil]];
        
        //show credit        
        [self addChild:parchmentSprite z:CREDITPARCHMENT];
        [parchmentSprite setDisplayFrameWithAnimationName:CREDIT_SHOW_ANIM index:0];
        id creditAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:CREDIT_SHOW_ANIM times:1];       
        id delay = [CCDelayTime actionWithDuration:0.35];        
        CCCallBlock *creditInfoAction = [CCCallBlock actionWithBlock:^{            
            
            //credit img1:only for the first loop
            self.creditSprite1 = [CCSprite spriteWithFile:CREDIT_SPRITE rect:CGRectMake(0, credit.contentSize.height*0.284, credit.contentSize.width, credit.contentSize.height*0.3)];
            creditSprite1.position = ccp( screenSize.width*0.51 , screenSize.height*0.48 );
            [self addChild: creditSprite1 z:CREDIT];
            
            //credit img2
            self.creditSprite2 = [CCSprite spriteWithFile:CREDIT_SPRITE];
            creditSprite2.position = ccp( screenSize.width*0.51 , screenSize.height*0.48 );  
            
            [self schedule:@selector(scroll1) interval:0.1];            
            
        }];       
        [parchmentSprite runAction:creditAction];
        [parchmentSprite runAction:[CCSequence actions:delay,creditInfoAction, nil]];        
    }
    else if (creditOpen && CGRectContainsPoint(carrotSprite.boundingBox, touchPoint) && touchPoint.y<previousTouchPoint.y) {
        creditOpen = NO;
        
        //stop arrowDown action
        [arrowDown stopAllActions];
        [arrowDown runAction:[CCFadeOut actionWithDuration:0.5]];
        
        //move carrot down
        id move1 = [CCMoveTo actionWithDuration:0.2f position:ccp(carrotOriginPos.x, carrotOriginPos.y*0.9f)]; 
        id move2 = [CCMoveTo actionWithDuration:0.1f position:carrotOriginPos];
        [carrotSprite runAction:[CCSequence actions:move1, move2, nil]];        
        
        //hide credit info
        [self unschedule:@selector(scroll1)];
        [self unschedule:@selector(scroll2)];
        if (creditSprite1 != nil) {
            [self removeChild:creditSprite1 cleanup:YES];
        }
        if (creditSprite2 != nil) {
            [self removeChild:creditSprite2 cleanup:YES];
        }       
        
        //hide credit parchment
        [parchmentSprite setDisplayFrameWithAnimationName:CREDIT_HIDE_ANIM index:0];
        CCAction *creditAction = [[CCAnimationCache sharedAnimationCache] actionWithLimitedRepeatAnimate:CREDIT_HIDE_ANIM times:1];
        id delayAction = [CCDelayTime actionWithDuration:0.3f];
        CCCallBlock *removeCreditAction = [CCCallBlock actionWithBlock:^{
            [self removeChild:parchmentSprite cleanup:YES];
        }];
        [parchmentSprite runAction:creditAction];
        [parchmentSprite runAction:[CCSequence actions:delayAction, removeCreditAction, nil]];       
    }
}

- (void)dealloc {
    [arrowUp release];
    [arrowDown release];
    [parchmentSprite release];
    [carrotSprite release];
    [creditSprite1 release];
    [creditSprite2 release];
    [credit release];
    [super dealloc];
}

@end
