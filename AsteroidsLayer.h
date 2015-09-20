//
//  AsteroidsLayer.h
//  Galaxy_Escape
//
//  Created by Tony on 2/25/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GameScene.h"
#import "GLES-Render.h"
#import "CollisionDetector.h"
#import "Asteroid.h"
#import "Bullet.h"
#import "GameOverScene.h"
#import "PowerUp.h"
#import "MainGameParameters.h"
#import "ElementTrap.h"

@interface AsteroidsLayer : CCLayer {
    
}

#define PTM_RATIO 32.0
#define BULLET_COUNT 40
#define ASTEROID_KIND_COUNT 10
#define PARTICLE_EFFECT_KIND_COUNT 10

#define DEBUG_MODE 0

// parameters between scene
@property NSString *deathReason;

typedef enum {
    tag_spaceCraftBox2d = 1,
    tag_asteroidsBox2d,
    tag_bulletBox2d,
    tag_bulletInactiveBox2d,
    tag_edgeBox2d,
    tag_particleSysBox2d,
    tag_invincibleBox2d,
    tag_bombBox2d,
    tag_bombParticleBox2d,
    tag_rotateLaserBox2d,
    tag_rotateLaserParticleBox2d,
    tag_killFullScreenBox2d,
    tag_killFullScreenParticleBox2d,
    tag_elementTrapBox2d,
    tag_elementTrapAppearParticle,
    tag_elementTrapParticleBox2d,
}tagOfBox2dWorld;

@property CGFloat moveSpeed;

+(id) createAsteroidLayer:(MainGameParameters*) parameters;
+(id) sharedAsteroidLayer;
-(void) moveAsteroidLayer:(CGPoint) velocity;
-(void) shootBulletTo: (CGPoint) velocity;
-(int) getCurrentEnemyCount;
-(void) deployAsteroidsInitial:(BOOL) initial;
-(void) runParticleEffect: (int) type :(CGPoint) pos;
-(id) getSpaceCraftInBox2d;
-(void) deployBomb;

@end
