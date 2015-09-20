//
//  GameOverScene.h
//  Galaxy_Escape
//
//  Created by Tony on 3/2/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainGameParameters.h"

@interface GameOverScene : CCLayerColor

+(CCScene *) sceneWithWon:(BOOL)won withDeathReason: (NSString*)reason withParameters:(MainGameParameters*)parameters;

@end
