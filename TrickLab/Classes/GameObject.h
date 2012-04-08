//
//  GameObject.h
//  TrickLab
//
//  Created by Siyao Kong on 3/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "global.h"

typedef enum {
    L,
    R,
}scrollDirTag;

@interface GameObject : NSObject {
    int step;
}



@property int step;

@end
