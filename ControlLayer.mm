//
//  ControlLayer.m
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "ControlLayer.h"


@implementation ControlLayer

static SneakyJoystick *directionJoy;
static SneakyJoystick *fireJoy;
static SneakyButton *bombButton;
static SneakyButton *superSkillButton;

static SneakyButton *skill_1_button;
static CCSprite     *skill_1_button_click;
static SneakyButton *skill_2_button;
static CCSprite     *skill_2_button_click;
static SneakyButton *skill_3_button;
static CCSprite     *skill_3_button_click;

static CCSprite     *disableShootSign;
static CCSprite     *disableMoveSign;

static MainGameParameters *params;

+(ControlLayer*) createControlLayer:(MainGameParameters*)parameters {
    return [[self alloc] initWithParams:parameters];
}

- (id)initWithParams:(MainGameParameters*) parameters
{
    self = [super init];
    if (self) {
        params = parameters;
        directionJoy = [[SneakyJoystick alloc] init];
        fireJoy = [[SneakyJoystick alloc] init];
        bombButton = [[SneakyButton alloc] init];
        superSkillButton = [[SneakyButton alloc] init];
        
        skill_1_button = [[SneakyButton alloc] init];
        skill_2_button = [[SneakyButton alloc] init];
        skill_3_button = [[SneakyButton alloc] init];
        
        [self addDirectionJoystick];
        [self addFireJoystick];
        [self addBombButton];
        [self scheduleUpdate];
        [self addSuperKillButton];
        [self addSkillButtons];
    }
    return self;
}

-(void) addSkillButtons {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    skill_1_button.isHoldable = NO;
    skill_1_button.radius = 8.0f;
    SneakyButtonSkinnedBase *skinButton1 = [[SneakyButtonSkinnedBase alloc] init];
    skinButton1.position = CGPointMake(screenSize.width - 50 * 3.5f, 50 * 2.5f);
    skinButton1.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"skill1.png"];
    skinButton1.pressSprite = [CCSprite spriteWithSpriteFrameName:@"skill1.png"];
    skinButton1.button = skill_1_button;
    [self addChild:skinButton1 z:4];
    skill_1_button_click = [CCSprite spriteWithSpriteFrameName:@"skill1_click.png"];
    skill_1_button_click.position = CGPointMake(screenSize.width - 50 * 3.5f, 50 * 2.5f);
    skill_1_button_click.visible = NO;
    [self addChild:skill_1_button_click z:5];
    
    skill_2_button.isHoldable = NO;
    skill_2_button.radius = 8.0f;
    SneakyButtonSkinnedBase *skinButton2 = [[SneakyButtonSkinnedBase alloc] init];
    skinButton2.position = CGPointMake(screenSize.width - 50 * 3.5f, 50 * 1.5f);
    skinButton2.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"skill2.png"];
    skinButton2.pressSprite = [CCSprite spriteWithSpriteFrameName:@"skill2.png"];
    skinButton2.button = skill_2_button;
    [self addChild:skinButton2 z:4];
    skill_2_button_click = [CCSprite spriteWithSpriteFrameName:@"skill2_click.png"];
    skill_2_button_click.position = CGPointMake(screenSize.width - 50 * 3.5f, 50 * 1.5f);
    skill_2_button_click.visible = NO;
    [self addChild:skill_2_button_click z:5];
    
    skill_3_button.isHoldable = NO;
    skill_3_button.radius = 8.0f;
    SneakyButtonSkinnedBase *skinButton3 = [[SneakyButtonSkinnedBase alloc] init];
    skinButton3.position = CGPointMake(screenSize.width - 50 * 3.5f, 50 * 0.5f);
    skinButton3.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"skill3.png"];
    skinButton3.pressSprite = [CCSprite spriteWithSpriteFrameName:@"skill3.png"];
    skinButton3.button = skill_3_button;
    [self addChild:skinButton3 z:4];
    skill_3_button_click = [CCSprite spriteWithSpriteFrameName:@"skill3_click.png"];
    skill_3_button_click.position = CGPointMake(screenSize.width - 50 * 3.5f, 50 * 0.5f);
    skill_3_button_click.visible = NO;
    [self addChild:skill_3_button_click z:5];
}

-(void) addBombButton {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    bombButton.isHoldable = NO;
    bombButton.radius = 10.0f;
    SneakyButtonSkinnedBase *skinButton = [[SneakyButtonSkinnedBase alloc] init];
    skinButton.position = CGPointMake(screenSize.width - 50 * 3.0f, 50 * 4.0f);
    skinButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"placeBombButton.png"];
    skinButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"placeBombButton.png"];
    skinButton.button = bombButton;
    [self addChild:skinButton];
}

-(void) addSuperKillButton {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    superSkillButton.isHoldable = NO;
    superSkillButton.radius = 10.0f;
    SneakyButtonSkinnedBase *skinButton = [[SneakyButtonSkinnedBase alloc] init];
    skinButton.position = CGPointMake(screenSize.width - 50 * 1.5f, 50 * 4.0f);
    skinButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"placeSuperSkill.png"];
    skinButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"placeSuperSkill.png"];
    skinButton.button = superSkillButton;
    [self addChild:skinButton];
}

-(void) addDirectionJoystick {
    directionJoy.autoCenter = YES;
    directionJoy.hasDeadzone = YES;
    directionJoy.deadRadius = DIRJOY_DEAD_RADIUS;
    directionJoy.thumbRadius = 40.0f;
	SneakyJoystickSkinnedBase* skinStick = [[SneakyJoystickSkinnedBase alloc] init];
	skinStick.position = DIRJOY_POSITION;
	skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@DIRJOY_BG_PNG];
	//skinStick.backgroundSprite.color = ccMAGENTA;
	skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@DIRJOY_THUMB_PNG];
	skinStick.thumbSprite.scale = DIRJOY_THUMB_SCALE;
	skinStick.joystick = directionJoy;
    [self addChild:skinStick];
    
    disableMoveSign = [CCSprite spriteWithSpriteFrameName:@"disableSign.png"];
    disableMoveSign.position = ccp(512, 384);
    disableMoveSign.opacity = 150;
    disableMoveSign.visible = NO;
    [self addChild:disableMoveSign z:5];
}

-(void) addFireJoystick {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    fireJoy.autoCenter = YES;
    fireJoy.hasDeadzone = YES;
    fireJoy.deadRadius = FIRJOY_DEAD_RADIUS;
    fireJoy.thumbRadius = 40.0f;
	SneakyJoystickSkinnedBase* skinStick = [[SneakyJoystickSkinnedBase alloc] init];
	skinStick.position = CGPointMake(screenSize.width - 50 * 1.5f, 50 * 1.5f);
	skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@FIRJOY_BG_PNG];
	//skinStick.backgroundSprite.color = ccMAGENTA;
	skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@FIRJOY_THUMB_PNG];
	skinStick.thumbSprite.scale = FIRJOY_THUMB_SCALE;
	skinStick.joystick = fireJoy;
    [self addChild:skinStick];
    
    disableShootSign = [CCSprite spriteWithSpriteFrameName:@"disableSign.png"];
    disableShootSign.position = CGPointMake(screenSize.width - 50 * 1.5f-25.0f, 50 * 1.5f);
    disableShootSign.opacity = 150;
    disableShootSign.visible = NO;
    [self addChild:disableShootSign z:5];
}

-(void)update:(ccTime)delta {
    static ccTime bulletTime = 0;
    static ccTime bombSetTime = 0;
    bombSetTime += delta;
    bulletTime += delta;
    // get nodes that should be controlled
    SpaceCraft* spaceCraft = (SpaceCraft*)[[GameScene sharedGameScene] getSpaceCraft];
    InfinityScrollBg *bgs = (InfinityScrollBg*)[[GameScene sharedGameScene] getBackgrounds];
    PlanetsLayer *planets = (PlanetsLayer*)[[GameScene sharedGameScene] getPlanets];
    GameEdgeLayer *edgeLayer = (GameEdgeLayer*)[[GameScene sharedGameScene] getEdgeLayer];
    AsteroidsLayer *asteroids = [[GameScene sharedGameScene] getAsteroids];
    GameStatsLayer *stasLayer = [[GameScene sharedGameScene] getStatsLayer];
    
    // direction joy control
    if(params.canMove) {
        disableMoveSign.visible = NO;
        CGPoint directionControl = directionJoy.velocity;
        if(params.freezeTrapEnabled == YES) {
            directionControl = ccp(directionControl.x/2,directionControl.y/2);
        }
        [bgs moveBackgrounds:directionControl];
        [planets movePlanets:directionControl];
        [asteroids moveAsteroidLayer:directionControl];
        [edgeLayer moveEdgeLayer:directionControl];
        [spaceCraft adjustAngle:directionControl];
        [spaceCraft showTail:directionControl];
    }
    else {
        disableMoveSign.visible = YES;
    }
    
    // fire joy control
    CGPoint fireControl = ccpMult(fireJoy.velocity, 2);
    if(params.canShootBullet) {
        disableShootSign.visible = NO;
        [spaceCraft showWeaponSE:0 toDirection:fireJoy.velocity];
        if (bulletTime > 0.02f) {
            bulletTime = 0;
            [asteroids shootBulletTo:fireControl];
            //        if(spaceCraftInBox2d.invincible == YES) {
            //            [asteroids shootBulletTo:reverseFireControl];
            //            [asteroids shootBulletTo:leftFireControl];
            //            [asteroids shootBulletTo:rightFireControl];
            //        }
        }
    }
    else {
        disableShootSign.visible = YES;
    }
    
    // bomb button control
    if(params.canSetBomb) {
        if (bombButton.active && bombSetTime > 0.5f) {
            [asteroids deployBomb];
            bombSetTime = 0;
        }
    }
    
    if(superSkillButton.active && params.superSkillReady) {
        if (params.superSkills == 1) {
            params.timeStop = YES;
            if(spaceCraft.isPoisoned == YES) {
                [spaceCraft revokePoisoned];
            }
            [stasLayer resetPowerBar];
        }
        else if(params.superSkills == 2) {
            params.superKill = YES;
            [stasLayer resetPowerBar];
        }
        else if(params.superSkills == 3) {
            params.energyShield = YES;
            [stasLayer resetPowerBar];
        }
        else if(params.superSkills == 4) {
            params.killEachOther = YES;
            [stasLayer resetPowerBar];
        }
    }
    
    /* super skill buttons */
    if(skill_1_button.active) {
        skill_1_button_click.visible = YES;
        skill_2_button_click.visible = NO;
        skill_3_button_click.visible = NO;
        params.superSkills = 1;
    }
    else if(skill_2_button.active) {
        skill_1_button_click.visible = NO;
        skill_2_button_click.visible = YES;
        skill_3_button_click.visible = NO;
        params.superSkills = 2;
    }
    else if(skill_3_button.active) {
        skill_1_button_click.visible = NO;
        skill_2_button_click.visible = NO;
        skill_3_button_click.visible = YES;
        params.superSkills = 3;
    }
}



@end
