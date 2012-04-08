//
//  CCAnimationCache+FileLoad.m
//  TrickLab
//
//  Created by Siyao Kong on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAnimationCache+FileLoad.h"


@implementation CCAnimationCache (FileLoad)

- (void)addAnimationWithFile:(NSString *)filename
{
    //full path of the file
    NSString *fullpath = [CCFileUtils fullPathFromRelativePath:filename];
    //a set of name-value pairs; name=animation name; value=frames+delaytime
    NSDictionary *dictionary = [[[NSDictionary alloc] initWithContentsOfFile:fullpath] autorelease];
    //each animation includes two items: frames(array) and delaytime(nsnumber)
    for (NSString *animName in dictionary) {
        NSDictionary *anim = [dictionary objectForKey:animName];
        //for a certain animation name, store its value(a set of frame names) in an array
        NSArray *frameNames = [anim objectForKey:@"frames"];
        //how many frames in a certain animation
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[frameNames count]];
        //for each frame in a certain animation
        for (NSString *frameName in frameNames) {
            //create spriteframe for each frame(sprite)
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
            //add the spriteframe to an array
            [frames addObject:frame];
        }
        NSNumber *delayTime = [anim objectForKey:@"delay"];
        //create an animation using frames
        CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:[delayTime floatValue]];
        //store this animation to animation cache
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animName];
    }
}

- (CCAnimate *)actionWithAnimate:(NSString *)animationName
{
    CCAnimation *animation = [self animationByName:animationName];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    return animate;
}

- (CCRepeatForever *)actionWithForeverRepeatAnimate:(NSString *)animationName
{
    CCAnimate *animate = [self actionWithAnimate:animationName];
    CCRepeatForever *foreverRepeat = [CCRepeatForever actionWithAction:animate];
    return foreverRepeat;
}

- (CCRepeat *)actionWithLimitedRepeatAnimate:(NSString *)animationName times:(NSUInteger)times
{
    CCAnimate *animate = [self actionWithAnimate:animationName];
    CCRepeat *repeat = [CCRepeat actionWithAction:animate times:times];
    return repeat;
}

@end
