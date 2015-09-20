//
//  SpaceCraft.m
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "SpaceCraft.h"
#import "GameOverScene.h"


@implementation SpaceCraft

int alertDegree1 = 100;
int alertDegree2 = 200;
int alertDegree3 = 300;
int alertDegree4 = 400;

static CCParticleSystem *tail;
static CCParticleSystem *weaponSE0;
static CCParticleSystem *weaponSE1;
static CCParticleSystem *weaponSE2;
static CCParticleSystem *weaponSE3;

static GameStatsLayer *statsLayer;
static MainGameParameters *params;

static CCSprite *shieldDestroyImage;

@synthesize isDie;
@synthesize weaponSE;
@synthesize superKill;
@synthesize currentColor;

+(id)createSpaceCraft {
    return [[self alloc] initWithCraftImage];
}

-(id)initWithCraftImage {
    if (self = [super initWithSpriteFrameName:@"spaceCraft1.png"]) {
        CGSize screeSize = [[CCDirector sharedDirector] winSize];
        [self setPosition:ccp(screeSize.width/2, screeSize.height/2)];
        self.isDie = NO;
        self.invincible = NO;
        self.weaponSE = 0;
        self.superKill = NO;
        self.currentColor = 0;
        self.isPoisoned = NO;
        self.isFreezed = NO;
        
        shieldDestroyImage = [CCSprite spriteWithSpriteFrameName:@"shield.png"];
        shieldDestroyImage.position = ccp(screeSize.width/2, screeSize.height/2-25);
        shieldDestroyImage.visible = NO;
        [[GameScene sharedGameScene] addChild:shieldDestroyImage z:8];
        
        params = [[GameScene sharedGameScene] getSharedParameters];
        self.spaceCraftLives = params.spaceCraftLives;
        
        statsLayer = [[GameScene sharedGameScene] getStatsLayer];
        tail = (CCParticleSystem*)[[GameScene sharedGameScene] getSpaceCraftTail];
        weaponSE0 = (CCParticleSystem*)[[GameScene sharedGameScene] getWeaponSE:0];
//        weaponSE1 = (CCParticleSystem*)[[GameScene sharedGameScene] getWeaponSE:1];
//        weaponSE2 = (CCParticleSystem*)[[GameScene sharedGameScene] getWeaponSE:2];
//        weaponSE3 = (CCParticleSystem*)[[GameScene sharedGameScene] getWeaponSE:3];
        [self schedule:@selector(statusCheck) interval:0.3f];
    }
    return self;
}

-(void) becomeInvincible {
    [[SimpleAudioEngine sharedEngine] playEffect:@"shield.mp3"];
    self.invincible = YES;
    /*
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    GameScene *gameScene = [GameScene sharedGameScene];
    */
    shieldDestroyImage.visible = YES;
    /*
    CCLabelTTF * label = [CCLabelTTF labelWithString:@"Invincible" fontName:@"Arial" fontSize:32];
    label.color = ccc3(0,0,255);
    label.position = ccp(screenSize.width/2, screenSize.height/2);
    [gameScene addChild:label z:4 tag:tag_shield_destroy_message];
    [self schedule:@selector(revokeInvincibleMessage) interval:1.5f];
    */
    [self schedule:@selector(revokeInvincible) interval:params.shieldInterval];
    
}

-(void) revokeInvincibleMessage {
    GameScene *gameScene = [GameScene sharedGameScene];
    [gameScene removeChildByTag:tag_shield_destroy_message cleanup:YES];
    [self unschedule:@selector(revokeInvincibleMessage)];
}

-(void) revokeInvincible {
    shieldDestroyImage.visible = NO;
    self.invincible = NO;
    [self unschedule:@selector(revokeInvincible)];
}

-(void) showBigExplode {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCParticleSystem *bigExplode = [CCParticleSystemQuad particleWithFile:@"bigExplode.plist"];
    bigExplode.position = ccp(screenSize.width/2,screenSize.height/2);
    GameScene *gameScene = [GameScene sharedGameScene];
    CCLabelTTF * label = [CCLabelTTF labelWithString:@"SuperKill" fontName:@"Arial" fontSize:32];
    label.color = ccc3(255,0,0);
    label.position = ccp(screenSize.width/2, screenSize.height/2);
    [gameScene addChild:label z:4 tag:tag_big_explode_message];
    [gameScene addChild:bigExplode z:2 tag:tag_big_explode];
    [self schedule:@selector(revokeBigExplode) interval:1.5f];
}

-(void) revokeBigExplode {
    GameScene *gameScene = [GameScene sharedGameScene];
    [gameScene removeChildByTag:tag_big_explode cleanup:YES];
    [gameScene removeChildByTag:tag_big_explode_message cleanup:YES];
    [self unschedule:@selector(revokeBigExplode)];
}

-(void)adjustAngle:(CGPoint)angle {
    float radiant = atan2f(angle.y, angle.x);
    float degree = radiant * 180 / M_PI;
    [self setRotation:degree*(-1)];
}

-(void) statusCheck {
    if (tail.visible == YES) {
        tail.visible = NO;
    }
    
    if (self.currentColor == 1) {
        [self setColor:ccc3(255, 255, 255)];
        self.currentColor = 0;
    }
    
    if (weaponSE0.visible == YES) {
        weaponSE0.visible = NO;
    }
    if (weaponSE1.visible == YES) {
        weaponSE1.visible = NO;
    }
    if (weaponSE2.visible == YES) {
        weaponSE2.visible = NO;
    }
    if (weaponSE3.visible == YES) {
        weaponSE3.visible = NO;
    }
    
    if (self.isDie == YES) {
        [self unschedule:@selector(statusCheck)];
        CCScene* scene = [GameOverScene sceneWithWon:NO withDeathReason:self.deathReason withParameters:params];
        CCTransitionFade *tran = [CCTransitionProgressOutIn transitionWithDuration:0.5f scene:scene];
        [[CCDirector sharedDirector] replaceScene:tran];
    }
}

-(BOOL) isOutOfArea {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if ( (self.position.x<(-winSize.width + 25.0f)) || (self.position.x>(winSize.width*2-25.0f)) ) {
        return YES;
    }
    if ( (self.position.y<(-winSize.height + 25.0f)) || (self.position.y>(winSize.height*2-25.0f)) ) {
        return YES;
    }
    return NO;
}

-(void) showTail:(CGPoint)angle {
    if(angle.x != 0 || angle.y != 0) {
        float radiant = atan2f(angle.y, angle.x);
        float degree = radiant * 180 / M_PI;
        tail.visible = YES;
        [tail setRotation:(90-degree)];
    }
}

-(void) showWeaponSE:(int) kind toDirection:(CGPoint) angle {
    if(angle.x != 0 || angle.y != 0) {
        float radiant = atan2f(angle.y, angle.x);
        float degree = radiant * 180 / M_PI;
        switch (kind) {
            case 0:
                weaponSE0.visible = YES;
                [weaponSE0 setRotation:(-1*degree-90)];
                break;
            case 1:
                weaponSE1.visible = YES;
                [weaponSE1 setRotation:(degree-90)];
                break;
            case 2:
                weaponSE2.visible = YES;
                [weaponSE2 setRotation:(degree-90)];
                break;
            case 3:
                weaponSE3.visible = YES;
                [weaponSE3 setRotation:(degree-90)];
                break;
            default:
                break;
        }
    }
}

-(edgeAlert) checkEdgeAlertStatus {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat width = winSize.width;
    CGFloat height = winSize.height;
    edgeAlert alert;
    alert.typeLR=0;
    alert.typeUB=0;
    alert.degreeLR=0;
    alert.degreeUB=0;
    
    // left edge alert test
    if (self.position.x<(-width+alertDegree1)) {
        alert.typeLR = 1;
        alert.degreeLR = 1;
    }
    else if (self.position.x<(-width+alertDegree2)) {
        alert.typeLR = 1;
        alert.degreeLR = 2;
    }
    else if (self.position.x<(-width+alertDegree3)) {
        alert.typeLR = 1;
        alert.degreeLR = 3;
    }
    else if (self.position.x<(-width+alertDegree4)) {
        alert.typeLR = 1;
        alert.degreeLR = 4;
    }
    
    // right edge alert test
    if (self.position.x>(width*2-alertDegree1)) {
        alert.typeLR = 2;
        alert.degreeLR = 1;
    }
    else if (self.position.x>(width*2-alertDegree2)) {
        alert.typeLR = 2;
        alert.degreeLR = 2;
    }
    else if (self.position.x>(width*2-alertDegree3)) {
        alert.typeLR = 2;
        alert.degreeLR = 3;
    }
    else if (self.position.x>(width*2-alertDegree4)) {
        alert.typeLR = 2;
        alert.degreeLR = 4;
    }
    
    // up edge alert test
    if (self.position.y>(height*2-alertDegree1)) {
        alert.typeUB = 1;
        alert.degreeUB = 1;
    }
    else if (self.position.y>(height*2-alertDegree2)) {
        alert.typeUB = 1;
        alert.degreeUB = 2;
    }
    else if (self.position.y>(height*2-alertDegree3)) {
        alert.typeUB = 1;
        alert.degreeUB = 3;
    }
    else if (self.position.y>(height*2-alertDegree4)) {
        alert.typeUB = 1;
        alert.degreeUB = 4;
    }
    
    // bottom edge alert test
    if (self.position.y<(-height+alertDegree1)) {
        alert.typeUB = 2;
        alert.degreeUB = 1;
    }
    else if (self.position.y<(-height+alertDegree2)) {
        alert.typeUB = 2;
        alert.degreeUB = 2;
    }
    else if (self.position.y<(-height+alertDegree3)) {
        alert.typeUB = 2;
        alert.degreeUB = 3;
    }
    else if (self.position.y<(-height+alertDegree4)) {
        alert.typeUB = 2;
        alert.degreeUB = 4;
    }
    
    return alert;
}

-(void) explode: (CGPoint) pos :(NSString*) deathReason :(BOOL) rightnow {
    if(params.livesLeft > 0) {
        [self setColor:ccc3(255, 0, 0)];
        self.currentColor = 1;
        [statsLayer decreaseLifeTo];
    }
    else {
        self.deathReason = deathReason;
        AsteroidsLayer *asteroidsLayer = (AsteroidsLayer*)[[GameScene sharedGameScene] getAsteroids];
        [asteroidsLayer runParticleEffect:0 :pos];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spaceCraft_ruin.png"];
        [self setDisplayFrame:frame];
        self.isDie = YES;
        [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
        [asteroidsLayer unschedule:@selector(tick:)];
    }
}

-(void) getFreezed {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spaceCraft_freezed.png"];
    [self setDisplayFrame:frame];
    params.freezeTrapEnabled = YES;
    self.isFreezed = YES;
    [self scheduleOnce:@selector(revokeFreezed) delay:params.freezeTrapEffectInterval];
    [statsLayer showFreezeTrapSign];
}

-(void) revokeFreezed {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spaceCraft1.png"];
    [self setDisplayFrame:frame];
    params.freezeTrapEnabled = NO;
    self.isFreezed = NO;
    [statsLayer hideFreezeTrapSign];
}

-(void) getPoisoned {
    self.isPoisoned = YES;
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spaceCraft_poisoned.png"];
    [self setDisplayFrame:frame];
    [statsLayer poisonLifeBar];
    [statsLayer showPoisonTrapSign];
}

-(void) revokePoisoned {
    self.isPoisoned = NO;
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spaceCraft1.png"];
    [self setDisplayFrame:frame];
    [statsLayer revokePoisonLifeBar];
    [statsLayer hidePoisonTrapSign];
}

-(void) disableShootBullet {
    params.canShootBullet = NO;
    [self scheduleOnce:@selector(revokeDisableShootBullet) delay:params.disableShootTime];
}

-(void) revokeDisableShootBullet {
    params.canShootBullet = YES;
    [self unschedule:@selector(revokeDisableShootBullet)];
}

-(void) disableMove {
    params.canMove = NO;
    [self scheduleOnce:@selector(revokeDisableMove) delay:params.disableMoveTime];
}

-(void) revokeDisableMove {
    params.canMove = YES;
    [self unschedule:@selector(revokeDisableMove)];
}

@end
