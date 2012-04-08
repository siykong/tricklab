//
//  GameOverScene.m
//  TrickLab
//
//  Created by Siyao Kong on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "CCAnimationCache+FileLoad.h"
#import "AppDelegate.h"

#define GAMEOVER_BG_SPRITE @"game_over_bg.png"
#define SCORE_SEPARATOR @"leaves.png"
#define LONG_BTN_FRM @"long_btn.png"
#define LONG_BTN_SEL_FRM @"long_btn_sel.png"
#define CARROT_COLLECTED_0 @"gameover_carrot_0.png"
#define CARROT_COLLECTED_1 @"gameover_carrot_1.png"
#define CARROT_COLLECTED_2 @"gameover_carrot_2.png"
#define CARROT_COLLECTED_3 @"gameover_carrot_3.png"
#define FNT_BTN @"Hobo Std"
#define FNT_SIZE_BTN 35
#define CARROT_DROP_ONE_0_FRM @"drop_carrot_one_0.png"
#define CARROT_DROP_TWO_0_FRM @"drop_carrot_two_0.png"
#define CARROT_DROP_THREE_0_FRM @"drop_carrot_three_0.png"
#define CARROT_DROP_ONE_ANIM @"drop_carrot_one"
#define CARROT_DROP_TWO_ANIM @"drop_carrot_two"
#define CARROT_DROP_THREE_ANIM @"drop_carrot_three"
#define IMPROVED_SCORE_SPRITE @"improved_score.png"
#define LABEL_SCORE_1 @"Cradle bonus"
#define LABEL_SCORE_2 @"Carrot bonus"
#define LABEL_SCORE_3 @"Time bonus"
#define LABEL_SCORE_4 @"Your final score"
#define BASESCORE 2000
#define TIMEBONUS_FIRSTCLASS_3 1000
#define TIMEBONUS_SECONDCLASS_3 800
#define TIMEBONUS_THIRDCLASS_3 500
#define TIMEBONUS_FIRSTCLASS_2 800
#define TIMEBONUS_SECONDCLASS_2 500
#define TIMEBONUS_THIRDCLASS_2 200
#define TIMEBONUS_FIRSTCLASS_1 500
#define TIMEBONUS_SECONDCLASS_1 200
#define TIMEBONUS_THIRDCLASS_1 50
#define TIMEBONUS_FIRSTCLASS_0 200
#define TIMEBONUS_SECONDCLASS_0 50
#define TIMEBONUS_THIRDCLASS_0 10
#define TIME_THRESHHOLD_1 10
#define TIME_THRESHHOLD_2 15
#define TIME_THRESHHOLD_3 35
#define CARROTBONUS_1 1000
#define CARROTBONUS_2 1500
#define CARROTBONUS_3 2500
#define FNT_HANDWRITE @"DK Porcupine Pickle"
#define FNT_SIZE_HANDWRITE 40

/* score instruction
 1) final score = baseScore + carrotBonus + timeBonus
 2) baseScore condition: fall in cradle
 3) carrotBonus: more carrots collected, more points earned
 4) time threshhold: there are 3 time threshholds
 5) timeBonus: in each time threshhold, there's a timeBonusBase according to the number of carrots you collected
 6) timeBonus = (1-timeUsed/threshhold)*timeBonusBase*(1+diffCoefficient)
 */

@interface GameOverScene (PrivateMethods)

- (void) displayOriginScore;
- (void) switchScore:(int)dif;
- (void) updateCradleBonus;
- (void) updateCarrotBonus;
- (void) updateTimeBonus;

@end


@implementation GameOverScene

@synthesize scoreItemLabel;
@synthesize scoreLabel;

+(CCScene *) scene:(int)levelSel carrot:(int)num timeUsed:(float)timer
{
	CCScene *scene = [CCScene node];
    GameOverScene *gameOver = [[(GameOverScene *)[GameOverScene alloc] initWithLevel:levelSel carrot:num timeUsed:timer] autorelease];
    [scene addChild: gameOver];
	
	return scene;
}

- (id) initWithLevel:(int)levelSel carrot:(int)num timeUsed:(float)timer
{
    if( (self=[super init])) {
        CCLOG(@"game over scene");
        
        //resume auto rotate
        [(AppController *)[[CCDirector sharedDirector] delegate] setIsAccelerometerEnabled:NO];
        
        screenSize = [[CCDirector sharedDirector] winSize];
        
        //game over scene bg
        CCSprite *gameOverBg = [CCSprite spriteWithFile:GAMEOVER_BG_SPRITE];
        gameOverBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:gameOverBg z:GAMEOVERBG];
        
        //init scores
        displayScore = 0;
        finalScore = 0;
        cradleBonus = BASESCORE;
        carrotBonus = 0;
        timeBonus = 0;
        
        //level defficulty coefficient
        float difficulty[] = {0,0.2,0.3,0.5,0.2,0.5,0.7,1.5,1.8,1,0.5,0.5};
        
        //record number of collected carrots & best score
        NSString *keyCarrotNum = [NSString stringWithFormat:@"level%i_numOfCarrotCollected", levelSel];
        NSString *keyBestScore = [NSString stringWithFormat:@"level%i_bestScore", levelSel];

        int numOfCarrotCollected = [[NSUserDefaults standardUserDefaults] integerForKey:keyCarrotNum];
        if (numOfCarrotCollected < num) {
            [[NSUserDefaults standardUserDefaults] setInteger:num forKey:keyCarrotNum];
        }
        
        //unlock next level
        if (levelSel < LEVEL_MAX-1) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"level%i_unlockLevel", levelSel+1]];
        }        
                
        //show num of collected carrot/ calculate carrot bonus
        NSString *resultCarrot;
        CCSprite *carrotDrop;
        NSString *animName;
        switch (num) {
            case 0:
                resultCarrot = CARROT_COLLECTED_0;
                break;
            case 1:
                resultCarrot = CARROT_COLLECTED_1;
                carrotDrop = [CCSprite spriteWithSpriteFrameName:CARROT_DROP_ONE_0_FRM];
                animName = CARROT_DROP_ONE_ANIM;
                carrotBonus = CARROTBONUS_1;
                break;
            case 2:
                resultCarrot = CARROT_COLLECTED_2;
                carrotDrop = [CCSprite spriteWithSpriteFrameName:CARROT_DROP_TWO_0_FRM];
                animName = CARROT_DROP_TWO_ANIM;
                carrotBonus = CARROTBONUS_2;
                break;
            case 3:
            {
                resultCarrot = CARROT_COLLECTED_3;
                carrotDrop = [CCSprite spriteWithSpriteFrameName:CARROT_DROP_THREE_0_FRM];
                animName = CARROT_DROP_THREE_ANIM;
                carrotBonus = CARROTBONUS_3;
                //particle effects
                CCParticleSystem *particleWinCondition = [CCParticleSystemQuad particleWithFile:@"particle_win_condition.plist"];
                particleWinCondition.position = CGPointMake(screenSize.width*0.02, screenSize.height*0.02);
                [self addChild:particleWinCondition z:PARTICLE tag:PARTICLE];
            }
                break;
                
            default:
                break;
        }
        CCSprite *carrotCollected = [CCSprite spriteWithSpriteFrameName:resultCarrot];
        carrotCollected.position = ccp(screenSize.width*0.7, screenSize.height*0.5);
        [self addChild:carrotCollected z:GAMEOVERCARROTBAR];
        
        //carrot drop animation
        if (num != 0) {            
            carrotDrop.position = ccp(screenSize.width*0.3f, screenSize.height-carrotDrop.contentSize.height/2);
            [self addChild:carrotDrop z:CARROTDROP];
            [carrotDrop setDisplayFrameWithAnimationName:animName index:0];
            CCAction *carrotDropAction = [[CCAnimationCache sharedAnimationCache] actionWithForeverRepeatAnimate:animName];
            [carrotDrop runAction:carrotDropAction];
        }               
        
        //time bonus
        float timeBonus1, timeBonus2, timeBonus3;
        switch (num) {
            case 0:
                timeBonus1 = TIMEBONUS_FIRSTCLASS_0;
                timeBonus2 = TIMEBONUS_SECONDCLASS_0;
                timeBonus3 = TIMEBONUS_THIRDCLASS_0;
                break;
            case 1:
                timeBonus1 = TIMEBONUS_FIRSTCLASS_1;
                timeBonus2 = TIMEBONUS_SECONDCLASS_1;
                timeBonus3 = TIMEBONUS_THIRDCLASS_1;
                break;
            case 2:
                timeBonus1 = TIMEBONUS_FIRSTCLASS_2;
                timeBonus2 = TIMEBONUS_SECONDCLASS_2;
                timeBonus3 = TIMEBONUS_THIRDCLASS_2;
                break;
            case 3:
                timeBonus1 = TIMEBONUS_FIRSTCLASS_3;
                timeBonus2 = TIMEBONUS_SECONDCLASS_3;
                timeBonus3 = TIMEBONUS_THIRDCLASS_3;
                break;
                
            default:
                break;
        }
        if (timer <= TIME_THRESHHOLD_1) {
            timeBonus = (1-timer/TIME_THRESHHOLD_1) * timeBonus1 * (1+difficulty[levelSel-1]);
        }
        else if (timer <= TIME_THRESHHOLD_2) {
            timeBonus = (1-timer/TIME_THRESHHOLD_2) * timeBonus2 * (1+difficulty[levelSel-1]);
        }
        else if (timer <= TIME_THRESHHOLD_3) {
            timeBonus = (1-timer/TIME_THRESHHOLD_3) * timeBonus3 * (1+difficulty[levelSel-1]);
        }
        
        //calc final score
        finalScore = cradleBonus + carrotBonus + (int)timeBonus;
        
        //compliment
        CCLabelTTF *compliment = [CCLabelTTF labelWithString:@"" fontName:FNT_HANDWRITE fontSize:FNT_SIZE_HANDWRITE];   
        compliment.color = ccBLACK;
        compliment.position = ccp(screenSize.width*0.85, screenSize.height*0.93);
        [self addChild:compliment z:SCORE];
        switch (num) {
            case 0:
                [compliment setString:@"Accomplished!"];
                break;
            case 1:
                [compliment setString:@"Amazing!"];
                break;
            case 2:
                [compliment setString:@"Super!"];
                break;
            case 3:
                if (finalScore > BASESCORE+CARROTBONUS_3+TIMEBONUS_FIRSTCLASS_3*0.85) {
                    [compliment setString:@"Incredible!"];
                }
                else {
                    [compliment setString:@"Excellent!"];
                }
                
                break;
                
            default:
                break;
        }
        
        //set best score
        preScore = [[NSUserDefaults standardUserDefaults] integerForKey:keyBestScore];
        if (preScore < finalScore) {
            [[NSUserDefaults standardUserDefaults] setInteger:finalScore forKey:keyBestScore];            
        }        
        
        [self displayOriginScore];
        
        //replay button
        CCMenuItemSprite *replayBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            CCLOG(@"GameOverScene::replayBtn::levelSel:%i",levelSel);
            CCScene *gameScene = [(GameScene *)[GameScene alloc] initWithLevelNumber:levelSel];
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:gameScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }];
        replayBtn.position = ccp(screenSize.width*0.7, screenSize.height*0.4); 
        
        //next level button
        CCMenuItemSprite *nextLevelBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            CCLOG(@"GameOverScene::nextBtn::levelSel:%i",levelSel+1);
            CCScene *nextScene;
            if (levelSel == LEVEL_MAX - 1) {
                //stop music
                [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];                
                nextScene = [LevelSelection scene];
            }
            else {
                //replace scene with next level            
                nextScene = [[(GameScene *)[GameScene alloc] initWithLevelNumber:levelSel+1] autorelease];
            }            
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:nextScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }]; 
        nextLevelBtn.position = ccp(screenSize.width*0.7, screenSize.height*0.31); 
        
        //select level button
        CCMenuItemSprite *selLevelBtn = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_FRM] selectedSprite:[CCSprite spriteWithSpriteFrameName:LONG_BTN_SEL_FRM] block:^(id sender){
            //stop music
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            
            CCScene *levelSelectionScene = [LevelSelection scene];
            CCTransitionFade *transitionScene = [CCTransitionFade transitionWithDuration:0.3f scene:levelSelectionScene withColor:ccWHITE];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }]; 
        selLevelBtn.position = ccp(screenSize.width*0.7, screenSize.height*0.22); 
        
        CCMenu *menu = [CCMenu menuWithItems:replayBtn, nextLevelBtn, selLevelBtn, nil];
        menu.position = CGPointZero;
        
        [self addChild:menu z:GAMEOVERBTNMENU]; 
        
        //add font
        CCLabelTTF *replayLabel = [CCLabelTTF labelWithString:@"Replay" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        replayLabel.color = ccBLACK;
        replayLabel.position = ccp(replayBtn.position.x, replayBtn.position.y*0.99);
        [self addChild:replayLabel z:GAMEOVERFONT];
        
        CCLabelTTF *nextLevelLabel = [CCLabelTTF labelWithString:@"Next Level" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        nextLevelLabel.color = ccBLACK;
        nextLevelLabel.position = ccp(nextLevelBtn.position.x, nextLevelBtn.position.y*0.99);
        [self addChild:nextLevelLabel z:GAMEOVERFONT];
        
        CCLabelTTF *levelSelLabel = [CCLabelTTF labelWithString:@"Select Level" fontName:FNT_BTN fontSize:FNT_SIZE_BTN];   
        levelSelLabel.color = ccBLACK;
        levelSelLabel.position = ccp(selLevelBtn.position.x, selLevelBtn.position.y*0.99);
        [self addChild:levelSelLabel z:GAMEOVERFONT];
        
        //scheduler
        id delay = [CCDelayTime actionWithDuration:0.5];
        CCCallBlock *action = [CCCallBlock actionWithBlock:^{
            [scoreItemLabel setString:LABEL_SCORE_1];
            [scoreItemLabel runAction:[CCFadeIn actionWithDuration:0.5]];
            [self schedule:@selector(updateCradleBonus) interval:0.01f];
        }];
        [self runAction:[CCSequence actions:delay, action, nil]];
        
        
        self.isTouchEnabled = YES;
        
    }
    return self;
}
         
- (void) displayOriginScore
{
    //score description
    self.scoreItemLabel = [CCLabelTTF labelWithString:@"Score" fontName:FNT_HANDWRITE fontSize:FNT_SIZE_HANDWRITE];   
    scoreItemLabel.color = ccBLACK;
    scoreItemLabel.position = ccp(screenSize.width*0.7, screenSize.height*0.64);
    [self addChild:scoreItemLabel z:SCORE];
    
    //separator
    CCSprite *leavesSprite = [CCSprite spriteWithFile:SCORE_SEPARATOR];
    leavesSprite.position = ccp(screenSize.width*0.7, screenSize.height*0.605);
    [self addChild:leavesSprite z:SCORE];
    
    //score
    self.scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",0] fontName:FNT_HANDWRITE fontSize:FNT_SIZE_HANDWRITE];   
    scoreLabel.color = ccBLACK;
    scoreLabel.position = ccp(screenSize.width*0.7, screenSize.height*0.565);
    [self addChild:scoreLabel z:SCORE];         
}

- (void) updateCradleBonus
{
    int dif;
    if (displayScore < cradleBonus) {
        dif = cradleBonus - displayScore;
        [self switchScore:dif];
    } 
    else {
        [self unschedule:@selector(updateCradleBonus)];
        id fadein = [CCFadeIn actionWithDuration:0.4];
        id delay = [CCDelayTime actionWithDuration:0.4];
        CCCallBlock *action = [CCCallBlock actionWithBlock:^{
            [scoreItemLabel setString:LABEL_SCORE_2];
        }];
        CCCallBlock *schedule = [CCCallBlock actionWithBlock:^{            
            [self schedule:@selector(updateCarrotBonus) interval:0.02f];
        }];
        [scoreItemLabel runAction:[CCSequence actions:delay, action, fadein, schedule, nil]];       
    }
}

- (void) updateCarrotBonus
{
    int dif;
    if (displayScore < (cradleBonus + carrotBonus)) {
        dif = cradleBonus + carrotBonus - displayScore;        
        [self switchScore:dif];
    }
    else {
        [self unschedule:@selector(updateCarrotBonus)];
        id fadein = [CCFadeIn actionWithDuration:0.4];
        id delay = [CCDelayTime actionWithDuration:0.4];
        CCCallBlock *action = [CCCallBlock actionWithBlock:^{
            [scoreItemLabel setString:LABEL_SCORE_3];
        }];
        CCCallBlock *schedule = [CCCallBlock actionWithBlock:^{            
            [self schedule:@selector(updateTimeBonus) interval:0.02f];
        }];
        [scoreItemLabel runAction:[CCSequence actions:delay, action, fadein, schedule, nil]];        
    }
}

- (void) updateTimeBonus
{
    int dif;
    if (displayScore < finalScore) {
        dif = finalScore - displayScore;
        [self switchScore:dif];
    }
    else {
        [self unschedule:@selector(updateTimeBonus)];
        id fadein = [CCFadeIn actionWithDuration:0.4];
        id delay = [CCDelayTime actionWithDuration:0.4];
        CCCallBlock *action = [CCCallBlock actionWithBlock:^{
            [scoreItemLabel setString:LABEL_SCORE_4];
        }];
        [scoreItemLabel runAction:[CCSequence actions:delay, action, fadein, nil]];       
        //display improved score sprite
        if (preScore != 0 && preScore < finalScore) {
            CCSprite *improvedScoreSprite = [CCSprite spriteWithFile:IMPROVED_SCORE_SPRITE];
            improvedScoreSprite.position = ccp(screenSize.width*0.7, screenSize.height*0.85);
            improvedScoreSprite.scale = 0;
            [self addChild:improvedScoreSprite];
            id scale = [CCScaleTo actionWithDuration:1 scale:1];
            id ease = [CCEaseBackOut actionWithAction:scale];
            [improvedScoreSprite runAction:ease];
        }
    }
}

- (void) switchScore:(int)dif
{
    if (dif >= 1000) {
        displayScore += 193;
    }
    else if (dif >= 100 && dif < 1000) {
        displayScore += 93;
    }
    else if (dif >= 30 && dif < 100) {
        displayScore += 18;
    }
    else if (dif > 0 && dif < 30) {
        displayScore += 1;
    }
    [scoreLabel setString:[NSString stringWithFormat:@"%i",displayScore]];
}
         
- (void)dealloc
{
    [scoreItemLabel release];
    [scoreLabel release];
    [super dealloc];
}

@end
