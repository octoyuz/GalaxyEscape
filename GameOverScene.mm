//
//  GameOverScene.m
//  Galaxy_Escape
//
//  Created by Tony on 3/2/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "MainMenuScene.h"


@implementation GameOverScene

static MainGameParameters *params;

// game over statistics
static CCLabelTTF *accuracyLable;
// static CCLabelTTF *livesLeftLable;
static CCLabelTTF *bombHitLable;
static CCLabelTTF *enemyEliminateLable;
static CCLabelTTF *totalScoreLable;

static int surviveTimeCount;
static int livesLeftCount;
static int bombHitCount;
static int enemyEliminateCount;
static int totalScoreCount;

+(CCScene *) sceneWithWon:(BOOL)won
          withDeathReason: (NSString*)reason
           withParameters:(MainGameParameters *)parameters{
    CCScene *scene = [CCScene node];
    GameOverScene *layer = [[GameOverScene alloc] initWithWon:won withDeathReason:reason withParameters:parameters];
    [scene addChild: layer];
    return scene;
}

- (id)initWithWon:(BOOL)won
  withDeathReason:(NSString*)reason
   withParameters:(MainGameParameters*)parameters
{
    self = [super init];
    if (self) {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        params = parameters;
        NSString * message;
        if (won) {
            message = @"You Won! Congradulations!";
        } else {
            message = reason;
        }
        
        surviveTimeCount = 0;
        livesLeftCount = 0;
        bombHitCount = 0;
        enemyEliminateCount = 0;
        
        // win or lose message
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF * label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:50];
        label.color = ccc3(255,0,0);
        label.position = ccp(screenSize.width/2, screenSize.height/2+260);
        [self addChild:label z:1];
        
        // background image
        CCSprite *bg = [CCSprite spriteWithFile:@"background_2.png"];
        bg.position = ccp(screenSize.width/2,screenSize.height/2);
        [self addChild:bg z:0];
        
        // continue play menu button
        CCMenuItem *starMenuItem_1 = [CCMenuItemImage
                                      itemWithNormalImage:@"menuButton_continue.png" selectedImage:@"menuButton_continue_light.png" target:self selector:@selector(backToGameScene)];
        starMenuItem_1.position = CGPointZero;
        CCMenu *starMenu_1 = [CCMenu menuWithItems:starMenuItem_1, nil];
        starMenu_1.position = ccp(100,100);
        [self addChild:starMenu_1 z:1];
        
        // return to home menu button
        CCMenuItem *starMenuItem_2 = [CCMenuItemImage
                                      itemWithNormalImage:@"menuButton_back.png" selectedImage:@"menuButton_back_light.png" target:self selector:@selector(backToMainMenu)];
        starMenuItem_2.position = CGPointZero;
        CCMenu *starMenu_2 = [CCMenu menuWithItems:starMenuItem_2, nil];
        starMenu_2.position = ccp(200,100);
        [self addChild:starMenu_2 z:1];
        
        /* game over statistics  */
        // accuracy
        accuracyLable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SURVIVE TIME: --"] fontName:@"Marker Felt" fontSize:30];
        accuracyLable.position = ccp(200,screenSize.height/2+25);
        accuracyLable.color = ccc3(192,192,192);
        [self addChild:accuracyLable z:1 tag:1];
        /*
         livesLeftLable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"LIVES LEFT: --"] fontName:@"Arial" fontSize:20];
         livesLeftLable.position = ccp(200,screenSize.height-550);
         [self addChild:livesLeftLable z:1 tag:1];
         */
        // bomb hit
        bombHitLable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"BOMB HIT: --"] fontName:@"Marker Felt" fontSize:30];
        bombHitLable.position = ccp(200,screenSize.height/2-25);
        bombHitLable.color = ccc3(192,192,192);
        [self addChild:bombHitLable z:1 tag:1];
        // enemy eliminate
        enemyEliminateLable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"ENEMY ELIMINATE: --"] fontName:@"Marker Felt" fontSize:30];
        enemyEliminateLable.position = ccp(200,screenSize.height/2-75);
        enemyEliminateLable.color = ccc3(192,192,192);
        [self addChild:enemyEliminateLable z:1 tag:1];
        // total score
        totalScoreLable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"TOTAL SCORE: --"] fontName:@"Marker Felt" fontSize:40];
        totalScoreLable.position = ccp(screenSize.width/2, screenSize.height/2+190);
        totalScoreLable.color = ccc3(192,192,192);
        [self addChild:totalScoreLable z:1 tag:1];
        
        
        
        params.totalScore = params.tick_survived*190 + params.bombHit*470 + params.enemyEliminate*240;
        
        
        
        [self scheduleOnce:@selector(beginShowStats) delay:1.0f];
    }
    return self;
}

-(void) beginShowStats {
    [self schedule:@selector(surviveTimeAnimation) interval:0.02f];
    [self unschedule:@selector(beginShowStats)];
}

-(void) surviveTimeAnimation {
    if (surviveTimeCount == 0) {
        accuracyLable.string = [NSString stringWithFormat:@"SURVIVE TIME: 0"];
    }
    surviveTimeCount += 1;
    if(surviveTimeCount <= params.tick_survived) {
        accuracyLable.string = [NSString stringWithFormat:@"SURVIVE TIME: %i",surviveTimeCount];
    }
    else {
        surviveTimeCount = 0;
        [self unschedule:@selector(surviveTimeAnimation)];
        [self schedule:@selector(bombHitAnimation) interval:0.02f];
    }
}
/*
 -(void) livesLeftPointAnimation {
 if (livesLeftCount == 0) {
 livesLeftLable.string = [NSString stringWithFormat:@"LIVES LEFT: 0"];
 }
 livesLeftCount += 1;
 if (livesLeftCount <= params.livesLeft) {
 livesLeftLable.string = [NSString stringWithFormat:@"LIVES LEFT: %i",livesLeftCount];
 }
 else {
 livesLeftCount=0;
 [self unschedule:@selector(livesLeftPointAnimation)];
 [self schedule:@selector(bombHitAnimation) interval:0.02f];
 }
 }
 */
-(void) bombHitAnimation {
    if (bombHitCount == 0) {
        bombHitLable.string = [NSString stringWithFormat:@"BOMB HIT: 0"];
    }
    bombHitCount += 1;
    if (bombHitCount <= params.bombHit) {
        bombHitLable.string = [NSString stringWithFormat:@"BOMB HIT: %i",bombHitCount];
    }
    else {
        bombHitCount=0;
        [self unschedule:@selector(bombHitAnimation)];
        [self schedule:@selector(enemyEliminateAnimation) interval:0.02f];
    }
}

-(void) enemyEliminateAnimation {
    if (enemyEliminateCount == 0) {
        enemyEliminateLable.string = [NSString stringWithFormat:@"ENEMY ELIMINATE: 0"];
    }
    enemyEliminateCount += 1;
    if (enemyEliminateCount <= params.enemyEliminate) {
        enemyEliminateLable.string = [NSString stringWithFormat:@"ENEMY ELIMINATE: %i",enemyEliminateCount];
    }
    else {
        enemyEliminateCount=0;
        [self unschedule:@selector(enemyEliminateAnimation)];
        [self schedule:@selector(totalScoreAnimation) interval:0.01f];
    }
}

-(void) totalScoreAnimation {
    if (totalScoreCount == 0) {
        totalScoreLable.string = [NSString stringWithFormat:@"TOTAL SCORE: 0"];
    }
    totalScoreCount += 90;
    if (totalScoreCount <= params.totalScore) {
        totalScoreLable.string = [NSString stringWithFormat:@"TOTAL SCORE: %i",totalScoreCount];
    }
    else {
        totalScoreCount=0;
        [self unschedule:@selector(totalScoreAnimation)];
    }
}

-(void)backToGameScene {
    MainGameParameters *newParams = [MainGameParameters node];
    newParams.isHardCore = params.isHardCore;
    if (newParams.isHardCore == YES) {
        newParams.canShootBullet = NO;
        newParams.canSetBomb = NO;
        newParams.havePowerUp = NO;
        newParams.enemy_count = 15;
    }
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0f scene:[GameScene sceneWithParams:newParams]]];
}

-(void)backToMainMenu {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
}

@end