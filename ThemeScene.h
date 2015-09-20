//
//  ThemeScene.h
//  Galaxy_Escape
//
//  Created by Richard Yu on 4/2/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "cocos2d.h"
#import "GameScene.h"
#import "LoadingScene.h"
#import "MainGameParameters.h"


@interface ThemeScene : CCLayer <UIScrollViewDelegate> 
{
	UIPageControl *pagecontrol;
    UIScrollView *scrollview;
}

// returns a Scene that contains the ThemeScene as the only child
+(id) sceneWithParameters:(MainGameParameters*)parameters;

@end
