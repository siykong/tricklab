//
//  GameObject.m
//  TrickLab
//
//  Created by Siyao Kong on 3/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

@synthesize step;

- (id)init
{
    if ((self = [super init])) {
        step = 1;
    }
    return self;
}



@end
