//
//  global.mm
//  TrickLab
//
//  Created by Siyao Kong on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "global.h"

//convert from pixels to meters
b2Vec2 toMeters(CGPoint point)
{
    return b2Vec2(point.x/PTM_RATIO, point.y/PTM_RATIO);
}

//convert from meters to pixels
CGPoint toPixels(b2Vec2 vec)
{
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

//check if object is within screen (at least part of the object)
bool checkObjectInBoundry(CCSprite *obj, int widthFactor)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGRect screenRect = CGRectMake(0, 0, winSize.width*widthFactor, winSize.height);
    return CGRectIntersectsRect(screenRect, [obj boundingBox]); 
}

