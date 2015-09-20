//
//  GameStatsLayer.h
//  Galaxy_Escape
//
//  Created by Tony on 3/3/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PauseScene.h"
#import "MainGameParameters.h"
@interface GameStatsLayer : CCLayer {
    
}

@property BOOL superKillReady;
@property BOOL enablePowerBar;

@property BOOL isPoisonLifeBar;

/*
-(void)setEnemyLeft:(int) left;
-(void)setWaveRound:(int) round;
*/

+(GameStatsLayer*) createGameStatsLayerWithParameters:(MainGameParameters*)parameters;

-(void)increasePowerBar;
-(void)resetPowerBar;
-(void)decreaseLifeTo;
-(void)increaseLife;
-(void)fullPowerBar;
-(void)disablePowerBar;
-(void)poisonLifeBar;
-(void)revokePoisonLifeBar;

-(void)showFreezeTrapSign;
-(void)hideFreezeTrapSign;
-(void)showPoisonTrapSign;
-(void)hidePoisonTrapSign;
@end
