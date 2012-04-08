//
//  GameScene1.h
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#define LEVELBG_DAY_SPRITE @"level_bg_0.png"
#define LEVELBG_NIGHT_SPRITE @"level_bg_1.png"
#define LEVELBG_NIGHT_SPRITE_WIDE @"level_bg_1_wide.png"
#define WINDOW_DAY_SPRITE @"window_0.png"
#define WINDOW_NIGHT_SPRITE @"window_1.png"
#define CARROT_BAR_0_FRM @"carrot_collected_0.png"
#define CARROT_BAR_1_FRM @"carrot_collected_1.png"
#define CARROT_BAR_2_FRM @"carrot_collected_2.png"
#define CARROT_BAR_3_FRM @"carrot_collected_3.png"
#define SFX_CAGE_OPEN @"cage_open.wav"
#define SFX_CAGE_CLOSE @"cage_close.wav"
#define SFX_BUCKET @"bucket.wav"
#define SFX_FLOATER @"floater.wav"
#define SFX_CARROT_0 @"carrot_0.mp3"
#define SFX_CARROT_1 @"carrot_1.wav"
#define SFX_CARROT_2 @"carrot_2.wav"

typedef enum {      
    OBJ,
    TIP,
    UI,    
    PAUSE,
}layerTag;

typedef enum {
    LEVELBGTAG,
    OWLTAG,
    MOTHERHAMSTERTAG, 
    ROPETAG,      
    PULLEYTAG, 
    PARTICLECARROTTAG,
    CAGEBACKTAG,
    CARROT1TAG,
    CARROT2TAG,
    CARROT3TAG,        
    BUCKETBACKTAG, 
    HOLETAG,
    BABYHAMSTERTAG,
    PIPETAG,
    BUCKETFRONTTAG,
    FLOATERTAG,
    CRADLETAG,
    PULLRINGTAG,
    CAGEFRONTTAG,         
    STONETAG,
    BLOWERTAG,
    CARROTBAR,
    OWLATTACKTAG,
}GameObjTag;

@interface GameScene : CCScene {
    
}

- (id) initWithLevelNumber:(int)levelSel;

@end
