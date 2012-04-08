//
//  SimpleAudioEngine+SoundBatchPreload.h
//  TrickLab
//
//  Created by Siyao Kong on 2/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface SimpleAudioEngine (SoundBatchPreload)

- (void) preloadFromFile:(NSString *)filename;

@end
