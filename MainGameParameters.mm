//
//  MainGameParameters.m
//  Galaxy_Escape
//
//  Created by Tony on 4/18/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "MainGameParameters.h"


@implementation MainGameParameters

- (id)init
{
    self = [super init];
    if (self) {
        
        // background control
        self.lowerBackgroundMoveSpeed = 2.5f;
        self.middleBackGroundMoveSpeed = 8.0f;
        self.asteroidLayerMoveSpeed = 12.0f;
        self.backgroundNo = 3;
        
        // spaceCraft capability
        self.canShootBullet = YES;
        self.canSetBomb = YES;
        self.canMove = YES;
        self.spaceCraftLives = 5;
        
        // rotate laser settings
        self.haveRotateLasers = YES;
        self.rotateLaserInterval = 5.0f;
        
        // power up settings
        self.powerUpReleaseInterval = 6.0f;
        self.havePowerUp = YES;
        self.powerUpChangeInterval = 4.0f;
        
        self.disableShootTime = 10.0f;
        self.disableMoveTime = 2.0f;
        
        // power full super skill
        self.superSkillReady = NO;
        self.superSkills = 3;
        self.timeStop = NO;
        self.superKill = NO;
        self.energyShield = NO;
        self.killEachOther = NO;
        
        self.timeStopInterval = 2.0f;
        self.shieldInterval = 5.0f;
        
        // element trap
        self.elementTrapLastTime = 2.5f;
        self.elementTrapInterval = 6.0f;
        
        self.poisonTrapEffectInterval = 6.0f;
        
        self.freezeTrapEnabled = NO;
        self.freezeTrapEffectInterval = 8.0f;
        
        // AI control
        self.attack_interval = 2.0f;
        self.accelerate_rate = 20;
        self.max_enemy_speed = 15;
        self.base_hp = 10;
        self.enemy_count = 10;
        self.tick_survived = 0;
        self.time_left = 0;
        
        // game over statistics
        self.accuracy = 0;
        self.livesLeft = self.spaceCraftLives;
        self.bombHit = 0;
        self.enemyEliminate = 0;
        self.totalScore = 0;
        
        // other settings
        self.garbageCleanInterval = 30.0f;
        self.isHardCore = NO;
    }
    return self;
}

@end
