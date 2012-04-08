//
//  GameScene1.m
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "LevelSelection.h"
#import "LevelUI.h"
#import "TipLayer.h"
#import "Level1GameObjects.h"
#import "Level2GameObjects.h"
#import "Level3GameObjects.h"
#import "Level4GameObjects.h"
#import "Level5GameObjects.h"
#import "Level6GameObjects.h"
#import "Level7GameObjects.h"
#import "Level8GameObjects.h"
#import "Level9GameObjects.h"
#import "Level10GameObjects.h"
#import "Level11GameObjects.h"
#import "Level12GameObjects.h"

@implementation GameScene

- (id) initWithLevelNumber:(int)levelSel
{
    if ((self=[super init])) {        
        
        //layer for physics world
        switch (levelSel) {
            case LEVEL_1:
            {
                //level1
                Level1GameObjects *objLayer = [[(Level1GameObjects *)[Level1GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break; 
            }
            case LEVEL_2:
            {
                //level2
                Level2GameObjects *objLayer = [[(Level2GameObjects *)[Level2GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_3:
            {
                //level3
                Level3GameObjects *objLayer = [[(Level3GameObjects *)[Level3GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_4:
            {
                //level4
                Level4GameObjects *objLayer = [[(Level4GameObjects *)[Level4GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_5:
            {
                //level5
                Level5GameObjects *objLayer = [[(Level5GameObjects *)[Level5GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break; 
            }
            case LEVEL_6:
            {
                //level6
                Level6GameObjects *objLayer = [[(Level6GameObjects *)[Level6GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_7:
            {
                //level7
                Level7GameObjects *objLayer = [[(Level7GameObjects *)[Level7GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_8:
            {
                //level8
                Level8GameObjects *objLayer = [[(Level8GameObjects *)[Level8GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_9:
            {
                //level9
                Level9GameObjects *objLayer = [[(Level9GameObjects *)[Level9GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_10:
            {
                //level10
                Level10GameObjects *objLayer = [[(Level10GameObjects *)[Level10GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_11:
            {
                //level11
                Level11GameObjects *objLayer = [[(Level11GameObjects *)[Level11GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            case LEVEL_12:
            {
                //level12
                Level12GameObjects *objLayer = [[(Level12GameObjects *)[Level12GameObjects alloc] initWithLevelNumber:levelSel] autorelease];
                [self addChild:objLayer z:OBJ tag:OBJ];
                break;
            }
            default:
                break;
        }        
        
        //layer for replay/menu button
        LevelUI *uiLayer = [[(LevelUI *)[LevelUI alloc] initWithLevelNumber:levelSel] autorelease];
        [self addChild:uiLayer z:UI tag:UI];   
        
        //tip layer
        TipLayer *tipLayer = [[(TipLayer *)[TipLayer alloc] initWithLevelNumber:levelSel] autorelease];
        [self addChild:tipLayer z:TIP tag:TIP];
    }
    return self;
}


@end
