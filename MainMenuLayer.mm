//
//  MainMenuLayer.m
//  Galaxy_Escape
//
//  Created by Tony on 3/27/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "MainMenuLayer.h"
#import "CCControlButton.h"
#import "CCBReader.h"
#import "MainMenuScene.h"

@implementation MainMenuLayer

-(void)buttonPressed:(id)sender {
    CCControlButton *button = (CCControlButton*) sender;
    MainGameParameters *params = [MainGameParameters node];
    switch (button.tag) {
        case PLAY_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ThemeScene sceneWithParameters:params]]];
            break;
        case OPTIONS_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ThemeScene sceneWithParameters:params]]];
            break;
        case ABOUT_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuScene scene]]];
            break;
    }
}

@end
