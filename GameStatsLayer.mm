//
//  GameStatsLayer.m
//  Galaxy_Escape
//
//  Created by Tony on 3/3/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "GameStatsLayer.h"

static CCProgressTimer *powerBar;
static float powerBarPercentage;

static CCArray *lifeBar;
static int currentLives;

static CCLabelTTF *timeLeftLable;
// static int timeLeft;

static MainGameParameters* params;

static CCSprite *powerBarFullSprite;
static CCSprite *powerBarDisableSign;

static SpaceCraft *spaceCraftInGameScene;

static CCSprite *freezeTrapSign;
static CCSprite *poisonTrapSign;

@implementation GameStatsLayer

+(GameStatsLayer*) createGameStatsLayerWithParameters:(MainGameParameters *)parameters {
    return [[self alloc] initWithParameters:parameters];
}


- (id)initWithParameters:(MainGameParameters*)parameters 
{
    self = [super init];
    if (self) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        params = parameters;
        
        currentLives = params.spaceCraftLives;
        self.superKillReady = NO;
        self.enablePowerBar = YES;
        powerBarPercentage = 0.0f;
        self.isPoisonLifeBar = NO;
        
        spaceCraftInGameScene = [[GameScene sharedGameScene] getSpaceCraft];
        // time left stats
        NSString *timeLeftString = [NSString stringWithFormat:@"Time Survived: %is",params.time_left];
        timeLeftLable = [CCLabelTTF labelWithString:timeLeftString fontName:@"Marker Felt" fontSize:20];
        timeLeftLable.position = ccp(winSize.width/2, winSize.height-(timeLeftLable.contentSize.height/2));
        [self addChild:timeLeftLable z:1 tag:1];
        
        [self schedule:@selector(tickDown) interval:1.0f];
        /*
        CCLabelTTF *waveRound = [CCLabelTTF labelWithString:@"Wave Round: 1" fontName:@"Arial" fontSize:20];
        waveRound.position = ccp(winSize.width/2 + (waveRound.contentSize.width), winSize.height-(waveRound.contentSize.height/2));
        [self addChild:waveRound z:1 tag:2];
        */
        
        // spaceCraft lives stats
        lifeBar = [CCArray arrayWithCapacity:params.spaceCraftLives];
        for (int i=0; i<params.spaceCraftLives; i++) {
            NSString *frameName = [NSString stringWithFormat:@"spaceCraftBlue%i.png",i];
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:frameName];
            [lifeBar addObject:sprite];
            [self addChild:sprite];
            sprite.position = ccp(winSize.width-50.0f*(i+1), winSize.height-25.0f);
        }
        // settings menu button stats
        CCMenuItem *starMenuItem = [CCMenuItemImage
                                    itemWithNormalImage:@"menuButton_continue.png" selectedImage:@"menuButton_continue_light.png" target:self selector:@selector(pauseScene)];
        starMenuItem.position = ccp(0, 0);
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = ccp(50, winSize.height-50);
        [self addChild:starMenu];
        
        // power bar
        /*
        CCSprite *powerBarFrame = [CCSprite spriteWithFile:@"powerbar_frame.png"];
        powerBarFrame.position = ccp(300.0f, 50.0f);
        [self addChild:powerBarFrame z:8];
        */
        
//        CCSprite *powerBarSprite = [CCSprite spriteWithSpriteFrameName:@"power_save.png"];
        CCSprite *powerBarSprite = [CCSprite spriteWithFile:@"powerbar_save.png"];
//        powerBarFullSprite = [CCSprite spriteWithSpriteFrameName:@"power_full.png"];
        powerBarFullSprite = [CCSprite spriteWithFile:@"powerbar_full.png"];
        powerBar = [CCProgressTimer progressWithSprite:powerBarSprite];
        powerBar.type = kCCProgressTimerTypeBar;
        powerBar.midpoint = ccp(0,0); 
        powerBar.barChangeRate = ccp(1,0);
        powerBar.position = ccp(350.0f, 50.0f);
        powerBarFullSprite.position = ccp(350.0f, 50.0f);
        powerBarFullSprite.visible = NO;
        [powerBar setPercentage:powerBarPercentage];
        [self addChild:powerBar z:5];
        [self addChild:powerBarFullSprite z:6];
        powerBarDisableSign = [CCSprite spriteWithSpriteFrameName:@"disableSign.png"];
        powerBarDisableSign.position = ccp(350.0f, 50.0f);
        powerBarDisableSign.visible = NO;
        [self addChild:powerBarDisableSign z:7];
        
        // element trap sign
        freezeTrapSign = [CCSprite spriteWithSpriteFrameName:@"elementTrapFreezeSign.png"];
        freezeTrapSign.position = ccp(625.0,70.0f);
        freezeTrapSign.opacity = 50;
        [self addChild:freezeTrapSign];
        poisonTrapSign = [CCSprite spriteWithSpriteFrameName:@"elementTrapPoisonSign.png"];
        poisonTrapSign.position = ccp(750.0f,70.0f);
        poisonTrapSign.opacity = 50;
        [self addChild:poisonTrapSign];
    }
    return self;
}

-(void)showFreezeTrapSign {
    freezeTrapSign.opacity = 255;
}

-(void)hideFreezeTrapSign {
    freezeTrapSign.opacity = 50;
}

-(void)showPoisonTrapSign {
    poisonTrapSign.opacity = 255;
}

-(void)hidePoisonTrapSign {
    poisonTrapSign.opacity = 50;
}

-(void)tickDown {
    params.tick_survived++;
    /*
    if (params.time_left <= 0) {
        [self unschedule:@selector(tickDown)];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0f scene:[GameOverScene sceneWithWon:YES withDeathReason:@"Warrior!" withParameters:params]]];
    }
    */
    timeLeftLable.string = [NSString stringWithFormat:@"Time Survived: %is",params.tick_survived];
}

-(void) poisonLifeBar {
    self.isPoisonLifeBar = YES;
    [self schedule:@selector(decreaseLifeTo) interval:params.poisonTrapEffectInterval];
}

-(void) revokePoisonLifeBar {
    self.isPoisonLifeBar = NO;
    [self unschedule:@selector(decreaseLifeTo)];
}

-(void)increaseLife {
    if(params.livesLeft < params.spaceCraftLives) {
        ((CCSprite*)[lifeBar objectAtIndex:params.livesLeft]).visible = YES;
        params.livesLeft++;
    }
}

-(void)decreaseLifeTo {
    if(params.livesLeft<=1 && self.isPoisonLifeBar==YES) {
        [spaceCraftInGameScene revokePoisoned];
        return;
    }
    params.livesLeft--;
    ((CCSprite*)[lifeBar objectAtIndex:params.livesLeft]).visible = NO;
}

-(void)pauseScene {
    [[CCDirector sharedDirector] pushScene:[PauseScene scene]];
    return;
}


/*
-(void)setEnemyLeft:(int) left {
    CCLabelTTF *enemyLeft = (CCLabelTTF*)[self getChildByTag:1];
    enemyLeft.string = [NSString stringWithFormat:@"Enemy Left: %i",left];
}

-(void)setWaveRound:(int)round {
    CCLabelTTF *waveRound = (CCLabelTTF*)[self getChildByTag:2];
    waveRound.string = [NSString stringWithFormat:@"Wave Round: %i",round];
}
*/

-(void)disablePowerBar {
    self.enablePowerBar = NO;
    powerBarDisableSign.visible = YES;
    [self scheduleOnce:@selector(revokeDisablePowerBar) delay:10.0f];
}

-(void)revokeDisablePowerBar {
    self.enablePowerBar = YES;
    powerBarDisableSign.visible = NO;
}

-(void)fullPowerBar {
    params.superSkillReady = YES;
    powerBarPercentage = 100.0f;
    [self schedule:@selector(shinePowerBar) interval:0.3f];
}

-(void)shinePowerBar {
    static BOOL shine = YES;
    if (shine == YES) {
        powerBarFullSprite.visible = YES;
        shine = NO;
    }
    else {
        powerBarFullSprite.visible = NO;
        shine = YES;
    }
}

-(void)resetPowerBar {
    [self unschedule:@selector(shinePowerBar)];
    powerBarFullSprite.visible = NO;
    CCProgressFromTo *powerBarChange = [CCProgressFromTo actionWithDuration:1.0f from:100.0f to:0.0f];
    [powerBar runAction:powerBarChange];
    powerBarPercentage = 0.0f;
    params.superSkillReady = NO;
}

-(void)increasePowerBar {
    if(self.enablePowerBar == YES) {
        if (powerBarPercentage >= 100.0f) {
            [self fullPowerBar];
        }
        CCProgressFromTo *powerBarChange = [CCProgressFromTo actionWithDuration:0.5f from:powerBarPercentage to:(powerBarPercentage+=10.0f)];
        [powerBar runAction:powerBarChange];
    }
}

@end
