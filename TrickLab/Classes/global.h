//
//  global.h
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "GLES-Render.h"
#import "CCAnimationCache+FileLoad.h"

#define PTM_RATIO 32

b2Vec2 toMeters(CGPoint point);
CGPoint toPixels(b2Vec2 vec);
bool checkObjectInBoundry(CCSprite *obj, int widthFactor);
