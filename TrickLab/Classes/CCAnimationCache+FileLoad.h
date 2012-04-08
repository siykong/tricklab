//
//  CCAnimationCache+FileLoad.h
//  TrickLab
//
//  Created by Siyao Kong on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCAnimationCache.h"

@interface CCAnimationCache (FileLoad) {
    
}

/*
 load animation from a plist file
 the plist file contains a set of animations, with a name and a list of sprite frame names
 */
- (void)addAnimationWithFile:(NSString *)filename;
- (CCAnimate *)actionWithAnimate:(NSString *)animationName;
- (CCRepeatForever *)actionWithForeverRepeatAnimate:(NSString *)animationName;
- (CCRepeat *)actionWithLimitedRepeatAnimate:(NSString *)animationName times:(NSUInteger)times;

@end
