//
//  LoadingScene.h
//  TrickLab
//
//  Created by Siyao Kong on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	TargetSceneINVALID = 0,
	TargetSceneGameScene1,
	TargetSceneGameScene2,
	TargetSceneMAX,
} TargetScenes;

@interface LoadingScene : CCScene {
    TargetScenes targetScene_;
}

+(id) sceneWithTargetScene:(TargetScenes)targetScene;
-(id) initWithTargetScene:(TargetScenes)targetScene;

@end
