//
//  CCButton.h
//  TrickLab
//
//  Created by Siyao Kong on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCButton : CCMenuItem {
    CCSprite *normalSprite;
    CCSprite *selectedSprite;
    CCMenuItem *button;
}

//button for replace scene
+ (id) buttonWithPos:(CGPoint)pos normalSpriteFrm:(NSString *)normalSpriteFrm selSpriteFrm:(NSString *)selSpriteFrm replaceScene:(CCScene *)scene; 
- (id) initWithPos:(CGPoint)pos normalSpriteFrm:(NSString *)normalSpriteFrm selSpriteFrm:(NSString *)selSpriteFrm replaceScene:(CCScene *)scene; 

@property (retain) CCSprite *normalSprite;
@property (retain) CCSprite *selectedSprite;
@property (retain) CCMenuItem *button;


@end
