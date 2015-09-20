//
//  ControlLayer.h
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

#import "SpaceCraft.h"
#import "GameScene.h"
#import "AsteroidsLayer.h"
#import "MainGameParameters.h"

@interface ControlLayer : CCLayer {
    
}

+(ControlLayer*) createControlLayer:(MainGameParameters*)parameters;


// direction joystick parameters
#define DIRJOY_DEAD_RADIUS 0
#define DIRJOY_POSITION ccp(50 * 1.5f, 50 * 1.5f)
#define DIRJOY_BG_PNG "button_bg.png"
#define DIRJOY_THUMB_PNG "button_direction_thumb.png"
#define DIRJOY_THUMB_SCALE 1.5f

// fire joystick parameters
#define FIRJOY_DEAD_RADIUS 15
#define FIRJOY_POSITION 0   // need to use screeSize, see actual code for detail
#define FIRJOY_BG_PNG "button_bg.png"
#define FIRJOY_THUMB_PNG "button_fire_thumb.png"
#define FIRJOY_THUMB_SCALE 1.5f

// control parameters
#define SPEED_BG_MOVE 50

@end
