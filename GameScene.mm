//
//  GameScene.m
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

// Class Variables
static GameScene* instanceGameScene;
// MainGame parameters
static MainGameParameters *params;

// stats
int enemyWaveRound;

// Class Methods

+(CCScene*) sceneWithParams: (MainGameParameters*) parameters{
    CCScene* scene = [CCScene node];
    
    // add the main game scene layer
    GameScene* layer = [[GameScene alloc] initWithParams:parameters];
    [scene addChild:layer z:-1];
    
    // add the control panel layer
    ControlLayer* controlLayer = [ControlLayer createControlLayer:parameters];
    [scene addChild:controlLayer z:7];
    
    return scene;
}

+(GameScene*) sharedGameScene {
    return instanceGameScene;
}

// Instance Methods

-(id) initWithParams:(MainGameParameters*)parameters {
    self = [super init];
    if (self) {
        
        // init the shared GameScene instance
        instanceGameScene = self;
        params = parameters;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        // init sound effect
        [[CDAudioManager sharedManager] setMode:kAMM_MediaPlayback];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:[NSString stringWithFormat:@"backgroundMusic.mp3"]];
        
        // load the texture atlas frames
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@PLIST_NAME_PLANETS];
        [frameCache addSpriteFramesWithFile:@"objects-hd.plist"];
        [frameCache addSpriteFramesWithFile:@"objects2-hd.plist"];
        
        // add infinity scroll backgrounds and planets
        InfinityScrollBg *backgrounds = [InfinityScrollBg createInfinityScrollBg];
        backgrounds.moveSpeed = params.lowerBackgroundMoveSpeed;
        PlanetsLayer *planets = [PlanetsLayer createPlanets];
        planets.moveSpeed = params.middleBackGroundMoveSpeed;

        [self addChild:backgrounds z:-1 tag:tag_backgrounds];
        if(params.backgroundNo == 3) {
            [self addChild:planets z:0 tag:tag_planets];
        }
        
        // add spaceCraft
        SpaceCraft *spaceCraft = [SpaceCraft createSpaceCraft];
        [self addChild:spaceCraft z:9 tag:tag_spaceCraft];
        
        // add game stats layer
        GameStatsLayer *statsLayer = [GameStatsLayer createGameStatsLayerWithParameters:params];
        [self addChild:statsLayer z:10 tag:tag_stats];
        
        // add spaceCraft tail
        CCParticleSystem *spaceCraftTail = [CCParticleSystemQuad particleWithFile:@"tail.plist"];
        spaceCraftTail.position = ccp(screenSize.width/2,screenSize.height/2);
        [self addChild:spaceCraftTail z:2 tag:tag_spaceCraftTail];
        spaceCraftTail.visible = NO;
        
        // add weapon special effects
        CCParticleSystem *weapon = [CCParticleSystemQuad particleWithFile:@"weaponSE_0.plist"];
        weapon.position = ccp(screenSize.width/2,screenSize.height/2);
        weapon.visible = NO;
        [self addChild:weapon z:2 tag:tag_weaponSE];
        
        spaceCraftTail.visible = NO;
//        for(int i=0; i<4; i++) {
//            NSString *weaponSEName = [NSString stringWithFormat:@"weaponSE_%i.plist",i];
//            CCParticleSystem *weapon = [CCParticleSystemQuad particleWithFile:weaponSEName];
//            weapon.position = ccp(screenSize.width/2,screenSize.height/2);
//            spaceCraftTail.visible = NO;
//            [self addChild:spaceCraftTail z:2 tag:tag_weaponSE+i];
//        }

        //   add Asteroid(enemy) Layer 
        AsteroidsLayer *asteroids = [AsteroidsLayer createAsteroidLayer:params];
        [self addChild:asteroids z:2 tag:tag_asteroids];
//        [self schedule:@selector(nextWave:)];
        

        
        // add edge layer
        GameEdgeLayer *edgeLayer = [[GameEdgeLayer alloc] init];
        [self addChild:edgeLayer z:6 tag:tag_edges];
        
        // add background music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundMusic.mp3" loop:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.7f];
    }
    return self;
}

/*
-(void) nextWave: (ccTime)dt {
    static ccTime curTime=0;
    curTime += dt;
    if (curTime > 3.0f) {
        curTime = 0;
        CCNode *message = [self getChildByTag:tag_label];
        if (message != NULL) {
            [self removeChildByTag:tag_label cleanup:YES];
        }
    }
    
    AsteroidsLayer *enemyLayer = (AsteroidsLayer*)[self getChildByTag:tag_asteroids];
    int enemyCount = [enemyLayer getCurrentEnemyCount];
    if (enemyCount <= 0) {
        enemyWaveRound++;
        GameStatsLayer *statsLayer = (GameStatsLayer*)[self getChildByTag:tag_stats];
        [statsLayer setWaveRound:enemyWaveRound];
        
        // switch background
        InfinityScrollBg *bgs = (InfinityScrollBg*)[[GameScene sharedGameScene] getBackgrounds];
        PlanetsLayer *planets = (PlanetsLayer*)[[GameScene sharedGameScene] getPlanets];
        CGPoint direction = ccp(arc4random()%11*5, arc4random()%11*5);
        [bgs switchInfinityBackgrounds:direction];
        [planets switchPlanets:direction];

        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF * label = [CCLabelTTF labelWithString:@"Next Wave Comes!" fontName:@"Arial" fontSize:50];
        label.color = ccc3(255,0,0);
        label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:label z:10 tag:tag_label];
        
        // new wave difficulty control
        enemyLayer.enemy_count += 7;
        enemyLayer.max_enemy_speed += 1;
        enemyLayer.accelerate_rate += 1.5;
//        enemyLayer.attack_enemy_per_wave += 1;
        enemyLayer.attack_interval -= 0.02;
        enemyLayer.baseHP += 2;
        [statsLayer setEnemyLeft:enemyLayer.enemy_count];
        [enemyLayer deployAsteroids];
    }
}
*/

-(id) getWeaponSE:(int) kind {
    return [self getChildByTag:tag_weaponSE+kind];
}

-(id) getSpaceCraftTail {
    return [self getChildByTag:tag_spaceCraftTail];
}

-(id) getEdgeLayer {
    return [self getChildByTag:tag_edges];
}

-(id) getBackgrounds {
    return [self getChildByTag:tag_backgrounds];
}

-(id) getSpaceCraft {
    return [self getChildByTag:tag_spaceCraft];
}

-(id) getPlanets {
    return  [self getChildByTag:tag_planets];
}

-(id) getBullets {
    return [self getChildByTag:tag_bullets];
}
-(id) getAsteroids {
    return [self getChildByTag:tag_asteroids];
}
-(id) getStatsLayer {
    return [self getChildByTag:tag_stats];
}
-(MainGameParameters*) getSharedParameters {
    return params;
}



@end
