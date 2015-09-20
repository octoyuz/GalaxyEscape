//
//  SpaceCraft.h
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AsteroidsLayer.h"
#import "GameScene.h"
#import "MainGameParameters.h"

@interface SpaceCraft : CCSprite {
    
}

@property BOOL isDie;
@property BOOL invincible;
@property int weaponSE;
@property BOOL superKill;
@property int spaceCraftLives;
@property int currentColor;

// debuff
@property BOOL isPoisoned;
@property BOOL isFreezed;

@property NSString* deathReason;

typedef struct {
    int typeLR=0;  // 0 means no alert, 1 means left, 2 means right
    int typeUB=0;  // 0 means no alert, 1 means up, 2 means bottom
    int degreeLR=0;   // 0 menas no degree, 1~4 means Left or Right according degree, 1 is most red
    int degreeUB=0;  // 0 menas no degree, 1~4 means Up or Bottom according degree, 1 is most red  
}edgeAlert;

+(id)createSpaceCraft;

-(void)adjustAngle:(CGPoint)angle;
-(void) explode: (CGPoint) pos :(NSString*) deathReason :(BOOL) rightnow;
-(BOOL) isOutOfArea;
-(edgeAlert) checkEdgeAlertStatus;
-(void) becomeInvincible;
-(void) revokeInvincible;
-(void) showTail:(CGPoint)angle;
-(void) showWeaponSE:(int) kind toDirection:(CGPoint) angle;
-(void) showBigExplode;
-(void) disableShootBullet;
-(void) disableMove;
-(void) revokeDisableMove;

-(void) getPoisoned;
-(void) revokePoisoned;
-(void) getFreezed;

@end
