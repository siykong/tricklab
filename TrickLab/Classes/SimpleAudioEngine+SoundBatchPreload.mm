//
//  SimpleAudioEngine+SoundBatchPreload.m
//  TrickLab
//
//  Created by Siyao Kong on 2/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SimpleAudioEngine+SoundBatchPreload.h"


@implementation SimpleAudioEngine (SoundBatchPreload)

- (void) preloadFromFile:(NSString *)filename
{
    //full path of the file
    NSString *fullpath = [CCFileUtils fullPathFromRelativePath:filename];
    //a set of name-value pairs; name=music/sfx; value=a set of audio names
    NSDictionary *dic = [[[NSDictionary alloc] initWithContentsOfFile:fullpath] autorelease];
    
    //for a certain audio type(music/sfx), store its value(a set of audio names) in an array
    NSArray *backgroundMusics = [dic objectForKey:@"BackgroundMusics"];
    //for each name in a certain audio type
    for (NSString *backgroundMusicName in backgroundMusics) {
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:backgroundMusicName];
    }
    NSArray *sounds = [dic objectForKey:@"SoundEffects"];
    for (NSString *soundName in sounds) {
        [[SimpleAudioEngine sharedEngine] preloadEffect:soundName];
    }
}

@end
