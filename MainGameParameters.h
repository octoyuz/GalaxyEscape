//
//  MainGameParameters.h
//  Galaxy_Escape
//
//  Created by Tony on 4/18/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainGameParameters : CCNode {
    
}

// background control
@property CGFloat lowerBackgroundMoveSpeed;
@property CGFloat middleBackGroundMoveSpeed;
@property CGFloat asteroidLayerMoveSpeed;
@property int backgroundNo;

// spaceCraft capability
@property BOOL canShootBullet;
@property BOOL canSetBomb;
@property BOOL canMove;
@property int spaceCraftLives;

// rotate laser settings
@property BOOL haveRotateLasers;
@property CGFloat rotateLaserInterval;

// power up settings
@property CGFloat powerUpReleaseInterval;
@property BOOL havePowerUp;
@property CGFloat powerUpChangeInterval;

@property CGFloat disableShootTime;
@property CGFloat disableMoveTime;


// power full super skill
@property BOOL superSkillReady;
@property int superSkills;      // 0 null
@property BOOL timeStop;        // 1
@property BOOL superKill;       // 2
@property BOOL energyShield;    // 3
@property BOOL killEachOther;   // 4

@property CGFloat timeStopInterval;
@property CGFloat shieldInterval;

// element trap
@property CGFloat elementTrapLastTime;
@property ccTime elementTrapInterval;

@property CGFloat poisonTrapEffectInterval;

@property BOOL freezeTrapEnabled;
@property CGFloat freezeTrapEffectInterval;

@property BOOL haveElementTrap;


// AI control
@property ccTime attack_interval;
@property int attack_enemy_per_wave;
@property CGFloat accelerate_rate;
@property CGFloat max_enemy_speed;
@property int base_hp;
@property int enemy_count;
@property int tick_survived;
@property int time_left;

// game over statistics
@property float accuracy;
@property int livesLeft;
@property int bombHit;
@property int enemyEliminate;
@property int totalScore;

// other settings
@property ccTime garbageCleanInterval;
@property BOOL isHardCore;

@end
