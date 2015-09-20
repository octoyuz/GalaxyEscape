//
//  GameScene.h
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ControlLayer.h"
#import "SpaceCraft.h"
#import "InfinityScrollBg.h"
#import "PlanetsLayer.h"
#import "AsteroidsLayer.h"
#import "GameStatsLayer.h"
#import "GameEdgeLayer.h"
#import "SimpleAudioEngine.h"
#import "MainGameParameters.h"

@interface GameScene : CCLayer {
    
}

#define PLIST_NAME_PLANETS "planets-hd.plist"
#define PLIST_NAME_OBJECTS "objects-hd.plist"

typedef enum {
    tag_backgrounds = 1,
    tag_weaponSE,
    tag_spaceCraft,
    tag_spaceCraftTail,
    tag_planets,
    tag_bullets,
    tag_asteroids,
    tag_label,
    tag_stats,
    tag_edges,
    tag_shield_destroy,
    tag_shield_destroy_message,
    tag_big_explode,
    tag_big_explode_message,
    tag_kill_screen_particle,
} tagOfGameScene;


+(CCScene*) sceneWithParams: (MainGameParameters*) parameters;
+(GameScene*) sharedGameScene;

-(id) getBackgrounds;
-(id) getSpaceCraft;
-(id) getPlanets;
-(id) getBullets;
-(id) getStatsLayer;
-(id) getAsteroids;
-(id) getEdgeLayer;
-(id) getSpaceCraftTail;
-(id) getWeaponSE:(int) kind;
-(MainGameParameters*) getSharedParameters;

@end
