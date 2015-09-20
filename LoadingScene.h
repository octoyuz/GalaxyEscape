//
//  LoadingScene.h
//  Galaxy_Escape
//
//  Created by Tony on 4/10/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"
#import "MainGameParameters.h"

@interface LoadingScene : CCLayer {
    
}
+(CCScene*) sceneWithParameters:(MainGameParameters*) parameters;

@end
