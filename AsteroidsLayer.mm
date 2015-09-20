//
//  AsteroidsLayer.m
//  Galaxy_Escape
//
//  Created by Tony on 2/25/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "AsteroidsLayer.h"

@implementation AsteroidsLayer

@synthesize moveSpeed;

// debug mode variable
GLESDebugDraw *_debugDraw;

static b2World *_world;
static b2Body *_groundBody;
static b2Fixture *_bottomFixture;
static b2Fixture *_upFixture;
static b2Fixture *_leftFixture;
static b2Fixture *_rightFixture;

// Tony defined variables
static b2Body *_spaceCraft;
static SpaceCraft *_spaceCraftSprite;
//static b2Fixture *_spaceCraftFixture;
static CollisionDetector *_collisionDetector;
b2PolygonShape shapeArray[6];
static SpaceCraft* spaceCraftInGameScene;

//Game Scene
static GameScene *sharedGameScene;

// bullet
b2Body *bulletsArray[BULLET_COUNT];
static int nextBullet;
// bomb
static b2Body *bombBody;
// rotate laser
static CGPoint rotateLaserPos;

// enemy stats
static int enemy_current_count;
static GameStatsLayer *statsLayer;
static AsteroidsLayer *instanceofAsteroidsLayer;

// game settings params
static MainGameParameters* params;

// super kill special effects
CCSprite *timeStopImage;
static b2Body *killFullScreenBody;

// element traps
static CGPoint elementTrapPos;
static b2Body *elementTrapBody;
static BOOL trapTriggerd;

// collision filter parameter
uint16 COLLISION_FILTER_PLAYER = 0x0001;
uint16 COLLISION_FILTER_ASTEROID = 0x0002;
uint16 COLLISION_FILTER_BULLETS = 0x0004;
uint16 COLLISION_FILTER_EDGE = 0x0008;
uint16 COLLISION_FILTER_POWERUP = 0x0010;
uint16 COLLISION_FILTER_BOMB = 0x0020;
uint16 COLLISION_FILTER_LASER = 0x0040;
uint16 COLLISION_FILTER_KILLFULLSCREEN = 0x0080;
uint16 COLLISION_FILTER_ELEMENTTRAP = 0x0100;

+(id) createAsteroidLayer:(MainGameParameters*) parameters {
    return [[self alloc] initAsteroidsLayer:parameters];
}

+(id) sharedAsteroidLayer {
    return instanceofAsteroidsLayer;
}

-(id) initAsteroidsLayer:(MainGameParameters*) parameters{
    self = [super init];
    if (self) {
        params = parameters;
        BOOL debug = DEBUG_MODE;
    
        instanceofAsteroidsLayer = self;
        // some init
        spaceCraftInGameScene = [[GameScene sharedGameScene] getSpaceCraft];
        statsLayer = (GameStatsLayer*)[[GameScene sharedGameScene] getStatsLayer];
        sharedGameScene = [GameScene sharedGameScene];
        trapTriggerd = NO;
        
        // create the Box2d World
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        _world = new b2World(gravity);
        CGSize winSize = [CCDirector sharedDirector].winSize;
        moveSpeed = 15.0f;
        
        // create collisioni detector
        _collisionDetector = new CollisionDetector();
        _world->SetContactListener(_collisionDetector);
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.restitution = 1.0f;
        groundBoxDef.density = 1.0f;
        groundBoxDef.shape = &groundBox;
        groundBoxDef.filter.categoryBits = COLLISION_FILTER_EDGE;
        groundBoxDef.filter.maskBits = -1;
        groundBox.Set(b2Vec2(-winSize.width/PTM_RATIO,-winSize.height/PTM_RATIO),b2Vec2(winSize.width/PTM_RATIO*2, -winSize.height/PTM_RATIO));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        groundBox.Set(b2Vec2(-winSize.width/PTM_RATIO,-winSize.height/PTM_RATIO),b2Vec2(-winSize.width/PTM_RATIO,winSize.height/PTM_RATIO*2));
        _leftFixture =  _groundBody->CreateFixture(&groundBoxDef);
        groundBox.Set(b2Vec2(-winSize.width/PTM_RATIO,winSize.height/PTM_RATIO*2),b2Vec2(winSize.width/PTM_RATIO*2,winSize.height/PTM_RATIO*2));
        _upFixture = _groundBody->CreateFixture(&groundBoxDef);
        groundBox.Set(b2Vec2(winSize.width/PTM_RATIO*2,winSize.height/PTM_RATIO*2),b2Vec2(winSize.width/PTM_RATIO*2,-winSize.height/PTM_RATIO));
        _rightFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        // initial difficulty control        
        self.deathReason = @"No Death!";
        
        [self addSpaceCraft];
        [self initAsteroidsShape];
        [self deployAsteroidsInitial:YES];
        [self addBullets];
        
//        [self deployRotateLaser:ccp(winSize.width-300.0f, winSize.height)];
        [self schedule:@selector(tick:)];
        [self schedule:@selector(makeMoreAggressive) interval:20.0f];
        
        if(params.havePowerUp) {
            [self schedule:@selector(deployInvincible) interval:params.powerUpReleaseInterval];
        }
        
        timeStopImage = [CCSprite spriteWithSpriteFrameName:@"clock.png"];
        timeStopImage.opacity = 130;
        timeStopImage.position = ccp(winSize.width/2, winSize.height/2);
        timeStopImage.visible = NO;
        [[GameScene sharedGameScene] addChild:timeStopImage z:8];
        
        if (debug) {
            _debugDraw = new GLESDebugDraw( PTM_RATIO );
            _world->SetDebugDraw(_debugDraw);
            uint32 flags = 0;
            flags += b2Draw::e_shapeBit;
            _debugDraw->SetFlags(flags);
        }
    }
    return self;
}

-(BOOL) isOutOfShowRange:(CGPoint) pos type:(int)type{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat xDis = _spaceCraftSprite.position.x - pos.x;
    CGFloat yDis = _spaceCraftSprite.position.y - pos.y;
    if(type == 1) {
        if((xDis <= winSize.width/2 && xDis >= 0) || ((xDis <= 0) && (xDis >= -winSize.width/2))) {
            return NO;
        }
        if((yDis <= winSize.height/2 && yDis >= 0) || ((yDis <= 0) && (yDis >= -winSize.height/2))) {
            return NO;
        }
    }
    else if(type == 2) {
        if((xDis <= winSize.width*1.2 && xDis >= 0) || ((xDis <= 0) && (xDis >= -winSize.width*1.2))) {
            return NO;
        }
        if((yDis <= winSize.height*1.2 && yDis >= 0) || ((yDis <= 0) && (yDis >= -winSize.height*1.2))) {
            return NO;
        }
    }
    return YES;
}

-(void) makeMoreAggressive {
    if(params.max_enemy_speed <= 20) {
        params.max_enemy_speed += 1;
    }
    if(params.attack_interval >= 1.2f) {
        params.attack_interval -= 0.2f;
    }
    if(params.accelerate_rate <= 26.0f) {
        params.accelerate_rate += 1.5f;
    }
    if(params.base_hp <= 30) {
        params.base_hp += 5;
    }
}

-(void) initAsteroidsShape {
    if(params.backgroundNo == 3) {
        b2PolygonShape as0;
        b2Vec2 verts0[] = {
            b2Vec2(4.2f / PTM_RATIO/2, 83.6f / PTM_RATIO/2),
            b2Vec2(-66.2f / PTM_RATIO/2, 37.9f / PTM_RATIO/2),
            b2Vec2(-104.6f / PTM_RATIO/2, -29.8f / PTM_RATIO/2),
            b2Vec2(-63.7f / PTM_RATIO/2, -65.5f / PTM_RATIO/2),
            b2Vec2(-2.8f / PTM_RATIO/2, -63.5f / PTM_RATIO/2),
            b2Vec2(94.5f / PTM_RATIO/2, -12.4f / PTM_RATIO/2),
            b2Vec2(67.6f / PTM_RATIO/2, 72.9f / PTM_RATIO/2),
            b2Vec2(6.0f / PTM_RATIO/2, 82.9f / PTM_RATIO/2)
        };
        as0.Set(verts0, 8);
        b2PolygonShape as1;
        b2Vec2 verts1[] = {
            b2Vec2(-107.3f / PTM_RATIO/2, 76.8f / PTM_RATIO/2),
            b2Vec2(-147.9f / PTM_RATIO/2, -22.8f / PTM_RATIO/2),
            b2Vec2(-118.6f / PTM_RATIO/2, -63.8f / PTM_RATIO/2),
            b2Vec2(-14.0f / PTM_RATIO/2, -82.0f / PTM_RATIO/2),
            b2Vec2(127.3f / PTM_RATIO/2, 10.6f / PTM_RATIO/2),
            b2Vec2(62.9f / PTM_RATIO/2, 93.3f / PTM_RATIO/2),
            b2Vec2(-37.9f / PTM_RATIO/2, 105.2f / PTM_RATIO/2),
            b2Vec2(-107.0f / PTM_RATIO/2, 79.1f / PTM_RATIO/2)
        };
        as1.Set(verts1, 7);
        b2PolygonShape as2;
        b2Vec2 verts2[] = {
            b2Vec2(-41.3f / PTM_RATIO/2, 74.1f / PTM_RATIO/2),
            b2Vec2(-91.0f / PTM_RATIO/2, 1.5f / PTM_RATIO/2),
            b2Vec2(-64.9f / PTM_RATIO/2, -59.9f / PTM_RATIO/2),
            b2Vec2(-15.4f / PTM_RATIO/2, -86.5f / PTM_RATIO/2),
            b2Vec2(52.0f / PTM_RATIO/2, -45.1f / PTM_RATIO/2),
            b2Vec2(88.8f / PTM_RATIO/2, 24.3f / PTM_RATIO/2),
            b2Vec2(25.8f / PTM_RATIO/2, 80.7f / PTM_RATIO/2),
            b2Vec2(-40.5f / PTM_RATIO/2, 73.4f / PTM_RATIO/2)
        };
        as2.Set(verts2, 7);
        
        b2PolygonShape as3;
        b2Vec2 verts3[] = {
            b2Vec2(-46.9f / PTM_RATIO/2, 82.2f / PTM_RATIO/2),
            b2Vec2(-89.4f / PTM_RATIO/2, 24.2f / PTM_RATIO/2),
            b2Vec2(-89.4f / PTM_RATIO/2, -38.7f / PTM_RATIO/2),
            b2Vec2(-5.3f / PTM_RATIO/2, -91.0f / PTM_RATIO/2),
            b2Vec2(56.0f / PTM_RATIO/2, -74.7f / PTM_RATIO/2),
            b2Vec2(93.1f / PTM_RATIO/2, 3.4f / PTM_RATIO/2),
            b2Vec2(62.8f / PTM_RATIO/2, 79.4f / PTM_RATIO/2),
            b2Vec2(-45.6f / PTM_RATIO/2, 82.4f / PTM_RATIO/2)
        };    as3.Set(verts3, 8);
        
        b2PolygonShape as4;
        b2Vec2 verts4[] = {
            b2Vec2(-27.5f / PTM_RATIO/2, 44.4f / PTM_RATIO/2),
            b2Vec2(-75.8f / PTM_RATIO/2, 3.3f / PTM_RATIO/2),
            b2Vec2(-66.5f / PTM_RATIO/2, -39.4f / PTM_RATIO/2),
            b2Vec2(-30.4f / PTM_RATIO/2, -68.0f / PTM_RATIO/2),
            b2Vec2(51.9f / PTM_RATIO/2, -48.1f / PTM_RATIO/2),
            b2Vec2(71.5f / PTM_RATIO/2, 25.3f / PTM_RATIO/2),
            b2Vec2(48.9f / PTM_RATIO/2, 57.6f / PTM_RATIO/2),
            b2Vec2(-25.5f / PTM_RATIO/2, 43.8f / PTM_RATIO/2)
        };
        as4.Set(verts4, 8);
        
        b2PolygonShape as5;
        b2Vec2 verts5[] = {
            b2Vec2(-59.1f / PTM_RATIO/2, 73.8f / PTM_RATIO/2),
            b2Vec2(-99.3f / PTM_RATIO/2, -5.5f / PTM_RATIO/2),
            b2Vec2(-45.2f / PTM_RATIO/2, -65.4f / PTM_RATIO/2),
            b2Vec2(47.3f / PTM_RATIO/2, -89.0f / PTM_RATIO/2),
            b2Vec2(105.0f / PTM_RATIO/2, -29.8f / PTM_RATIO/2),
            b2Vec2(83.2f / PTM_RATIO/2, 62.7f / PTM_RATIO/2),
            b2Vec2(0.1f / PTM_RATIO/2, 90.5f / PTM_RATIO/2),
            b2Vec2(-58.9f / PTM_RATIO/2, 75.2f / PTM_RATIO/2)
        };
        as5.Set(verts5, 8);
/*
        b2PolygonShape as6;
        b2Vec2 verts6[] = {
            b2Vec2(-61.6f / PTM_RATIO/2, 63.6f / PTM_RATIO/2),
            b2Vec2(-107.5f / PTM_RATIO/2, -17.5f / PTM_RATIO/2),
            b2Vec2(-52.4f / PTM_RATIO/2, -72.7f / PTM_RATIO/2),
            b2Vec2(24.4f / PTM_RATIO/2, -84.6f / PTM_RATIO/2),
            b2Vec2(74.3f / PTM_RATIO/2, -59.6f / PTM_RATIO/2),
            b2Vec2(91.6f / PTM_RATIO/2, -2.7f / PTM_RATIO/2),
            b2Vec2(66.1f / PTM_RATIO/2, 60.1f / PTM_RATIO/2),
            b2Vec2(-56.7f / PTM_RATIO/2, 65.1f / PTM_RATIO/2)
        };
        as6.Set(verts6, 8);
        
        b2PolygonShape as7;
        b2Vec2 verts7[] = {
            b2Vec2(-32.5f / PTM_RATIO/2, 75.9f / PTM_RATIO/2),
            b2Vec2(-87.6f / PTM_RATIO/2, 10.6f / PTM_RATIO/2),
            b2Vec2(-61.3f / PTM_RATIO/2, -56.7f / PTM_RATIO/2),
            b2Vec2(7.4f / PTM_RATIO/2, -78.7f / PTM_RATIO/2),
            b2Vec2(69.5f / PTM_RATIO/2, -42.9f / PTM_RATIO/2),
            b2Vec2(74.4f / PTM_RATIO/2, 32.1f / PTM_RATIO/2),
            b2Vec2(54.3f / PTM_RATIO/2, 65.2f / PTM_RATIO/2),
            b2Vec2(-31.0f / PTM_RATIO/2, 75.0f / PTM_RATIO/2)
        };
        as7.Set(verts7, 8);
        
        b2PolygonShape as8;
        b2Vec2 verts8[] = {
            b2Vec2(-42.8f / PTM_RATIO/2, 76.0f / PTM_RATIO/2),
            b2Vec2(-87.7f / PTM_RATIO/2, 8.1f / PTM_RATIO/2),
            b2Vec2(-52.2f / PTM_RATIO/2, -55.5f / PTM_RATIO/2),
            b2Vec2(17.7f / PTM_RATIO/2, -78.4f / PTM_RATIO/2),
            b2Vec2(58.2f / PTM_RATIO/2, -68.0f / PTM_RATIO/2),
            b2Vec2(88.6f / PTM_RATIO/2, -4.7f / PTM_RATIO/2),
            b2Vec2(64.7f / PTM_RATIO/2, 57.8f / PTM_RATIO/2),
            b2Vec2(-40.5f / PTM_RATIO/2, 73.8f / PTM_RATIO/2)
        };
        as8.Set(verts8, 8);
        
        b2PolygonShape as9;
        b2Vec2 verts9[] = {
            b2Vec2(-36.7f / PTM_RATIO/2, 103.0f / PTM_RATIO/2),
            b2Vec2(-101.3f / PTM_RATIO/2, 34.9f / PTM_RATIO/2),
            b2Vec2(-85.0f / PTM_RATIO/2, -43.5f / PTM_RATIO/2),
            b2Vec2(14.1f / PTM_RATIO/2, -110.2f / PTM_RATIO/2),
            b2Vec2(81.3f / PTM_RATIO/2, -92.0f / PTM_RATIO/2),
            b2Vec2(109.8f / PTM_RATIO/2, -5.7f / PTM_RATIO/2),
            b2Vec2(72.5f / PTM_RATIO/2, 78.4f / PTM_RATIO/2),
            b2Vec2(-32.0f / PTM_RATIO/2, 105.7f / PTM_RATIO/2)
        };
        as9.Set(verts9, 8);
        
        b2PolygonShape as10;
        b2Vec2 verts10[] = {
            b2Vec2(-50.5f / PTM_RATIO/2, 75.1f / PTM_RATIO/2),
            b2Vec2(-92.3f / PTM_RATIO/2, 12.6f / PTM_RATIO/2),
            b2Vec2(-92.6f / PTM_RATIO/2, -36.0f / PTM_RATIO/2),
            b2Vec2(-38.8f / PTM_RATIO/2, -71.0f / PTM_RATIO/2),
            b2Vec2(49.8f / PTM_RATIO/2, -66.0f / PTM_RATIO/2),
            b2Vec2(85.2f / PTM_RATIO/2, -11.7f / PTM_RATIO/2),
            b2Vec2(51.3f / PTM_RATIO/2, 70.3f / PTM_RATIO/2),
            b2Vec2(-46.4f / PTM_RATIO/2, 78.3f / PTM_RATIO/2)
        };
        as10.Set(verts10, 8);
*/        
        shapeArray[0]=as0;
        shapeArray[1]=as1;
        shapeArray[2]=as2;
        shapeArray[3]=as3;
        shapeArray[4]=as4;
        shapeArray[5]=as5;
/*
        shapeArray[6]=as6;
        shapeArray[7]=as7;
        shapeArray[8]=as8;
        shapeArray[9]=as9;
        shapeArray[10]=as10;
*/
    }
    else if(params.backgroundNo == 1) {
        b2PolygonShape as0;
        b2Vec2 verts0[] = {
            b2Vec2(8.5f / PTM_RATIO/2, 87.1f / PTM_RATIO/2),
            b2Vec2(-51.4f / PTM_RATIO/2, 69.8f / PTM_RATIO/2),
            b2Vec2(-97.6f / PTM_RATIO/2, -14.3f / PTM_RATIO/2),
            b2Vec2(-27.1f / PTM_RATIO/2, -86.1f / PTM_RATIO/2),
            b2Vec2(69.6f / PTM_RATIO/2, -65.9f / PTM_RATIO/2),
            b2Vec2(99.3f / PTM_RATIO/2, 23.6f / PTM_RATIO/2),
            b2Vec2(61.8f / PTM_RATIO/2, 76.1f / PTM_RATIO/2),
            b2Vec2(7.6f / PTM_RATIO/2, 88.9f / PTM_RATIO/2)
        };
        as0.Set(verts0, 8);
        
        b2PolygonShape as1;
        b2Vec2 verts1[] = {
            b2Vec2(67.9f / PTM_RATIO/2, 80.8f / PTM_RATIO/2),
            b2Vec2(-125.1f / PTM_RATIO/2, -4.0f / PTM_RATIO/2),
            b2Vec2(-128.2f / PTM_RATIO/2, -53.2f / PTM_RATIO/2),
            b2Vec2(-41.9f / PTM_RATIO/2, -94.9f / PTM_RATIO/2),
            b2Vec2(94.8f / PTM_RATIO/2, -50.0f / PTM_RATIO/2),
            b2Vec2(136.6f / PTM_RATIO/2, 15.4f / PTM_RATIO/2),
            b2Vec2(117.3f / PTM_RATIO/2, 72.2f / PTM_RATIO/2),
            b2Vec2(70.1f / PTM_RATIO/2, 81.0f / PTM_RATIO/2)
        };
        as1.Set(verts1, 8);
/*
        b2PolygonShape as2;
        b2Vec2 verts2[] = {
            b2Vec2(198.5f / PTM_RATIO/2, 155.2f / PTM_RATIO/2),
            b2Vec2(-141.5f / PTM_RATIO/2, -195.5f / PTM_RATIO/2),
            b2Vec2(-196.7f / PTM_RATIO/2, -110.9f / PTM_RATIO/2),
            b2Vec2(-194.5f / PTM_RATIO/2, 20.9f / PTM_RATIO/2),
            b2Vec2(6.1f / PTM_RATIO/2, 188.5f / PTM_RATIO/2),
            b2Vec2(106.1f / PTM_RATIO/2, 199.8f / PTM_RATIO/2),
            b2Vec2(181.5f / PTM_RATIO/2, 191.9f / PTM_RATIO/2),
            b2Vec2(198.1f / PTM_RATIO/2, 154.5f / PTM_RATIO/2)
        };
        as2.Set(verts2, 8);
*/
        
        b2PolygonShape as2;
        b2Vec2 verts2[] = {
            b2Vec2(67.9f / PTM_RATIO/2, 80.8f / PTM_RATIO/2),
            b2Vec2(-125.1f / PTM_RATIO/2, -4.0f / PTM_RATIO/2),
            b2Vec2(-128.2f / PTM_RATIO/2, -53.2f / PTM_RATIO/2),
            b2Vec2(-41.9f / PTM_RATIO/2, -94.9f / PTM_RATIO/2),
            b2Vec2(94.8f / PTM_RATIO/2, -50.0f / PTM_RATIO/2),
            b2Vec2(136.6f / PTM_RATIO/2, 15.4f / PTM_RATIO/2),
            b2Vec2(117.3f / PTM_RATIO/2, 72.2f / PTM_RATIO/2),
            b2Vec2(70.1f / PTM_RATIO/2, 81.0f / PTM_RATIO/2)
        };
        as2.Set(verts2, 8);
        
        b2PolygonShape as3;
        b2Vec2 verts3[] = {
            b2Vec2(-1.5f / PTM_RATIO/2, 78.5f / PTM_RATIO/2),
            b2Vec2(-82.8f / PTM_RATIO/2, 47.8f / PTM_RATIO/2),
            b2Vec2(-98.6f / PTM_RATIO/2, -5.0f / PTM_RATIO/2),
            b2Vec2(-38.3f / PTM_RATIO/2, -76.4f / PTM_RATIO/2),
            b2Vec2(54.7f / PTM_RATIO/2, -55.0f / PTM_RATIO/2),
            b2Vec2(98.5f / PTM_RATIO/2, 15.2f / PTM_RATIO/2),
            b2Vec2(67.0f / PTM_RATIO/2, 71.9f / PTM_RATIO/2),
            b2Vec2(-1.1f / PTM_RATIO/2, 78.0f / PTM_RATIO/2)
        };
        as3.Set(verts3, 8);
        
        b2PolygonShape as4;
        b2Vec2 verts4[] = {
            b2Vec2(55.1f / PTM_RATIO/2, 89.4f / PTM_RATIO/2),
            b2Vec2(-55.6f / PTM_RATIO/2, 72.4f / PTM_RATIO/2),
            b2Vec2(-68.5f / PTM_RATIO/2, -35.2f / PTM_RATIO/2),
            b2Vec2(1.7f / PTM_RATIO/2, -91.2f / PTM_RATIO/2),
            b2Vec2(75.9f / PTM_RATIO/2, -44.6f / PTM_RATIO/2),
            b2Vec2(108.4f / PTM_RATIO/2, 12.5f / PTM_RATIO/2),
            b2Vec2(98.1f / PTM_RATIO/2, 64.7f / PTM_RATIO/2),
            b2Vec2(54.3f / PTM_RATIO/2, 91.2f / PTM_RATIO/2)
        };
        as4.Set(verts4, 8);
        
        b2PolygonShape as5;
        b2Vec2 verts5[] = {
            b2Vec2(4.4f / PTM_RATIO/2, 73.8f / PTM_RATIO/2),
            b2Vec2(-83.2f / PTM_RATIO/2, 16.3f / PTM_RATIO/2),
            b2Vec2(-101.4f / PTM_RATIO/2, -43.6f / PTM_RATIO/2),
            b2Vec2(-59.5f / PTM_RATIO/2, -76.8f / PTM_RATIO/2),
            b2Vec2(97.8f / PTM_RATIO/2, -38.8f / PTM_RATIO/2),
            b2Vec2(114.6f / PTM_RATIO/2, 19.3f / PTM_RATIO/2),
            b2Vec2(70.1f / PTM_RATIO/2, 60.5f / PTM_RATIO/2),
            b2Vec2(3.1f / PTM_RATIO/2, 74.9f / PTM_RATIO/2)
        };
        as5.Set(verts5, 8);

        shapeArray[0]=as0;
        shapeArray[1]=as1;
        shapeArray[2]=as2;
        shapeArray[3]=as3;
        shapeArray[4]=as4;
        shapeArray[5]=as5;
    }
    
}

-(void) appearElementTrap:(CGPoint)pos {
    elementTrapPos = pos;
    CCParticleSystem *elementTrapAppear = [CCParticleSystemQuad particleWithFile:@"bigExplode.plist"];
    elementTrapAppear.position = pos;
    [self addChild:elementTrapAppear z:3 tag:tag_elementTrapAppearParticle];
    if(![self isOutOfShowRange:pos type:1]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"elementTrapAppear.mp3"];
    }
    [self scheduleOnce:@selector(deployElementTrap) delay:2.0f];
}

-(void) deployElementTrap {
    [self removeChildByTag:tag_elementTrapAppearParticle cleanup:YES];
    b2BodyDef elementTrapBodyDef;
    elementTrapBodyDef.type = b2_dynamicBody;
    elementTrapBodyDef.position.Set(elementTrapPos.x/PTM_RATIO, elementTrapPos.y/PTM_RATIO);
    ElementTrap *elementTrapSprite = [ElementTrap spriteWithSpriteFrameName:@"plate.png"];
    elementTrapSprite.visible = NO;
    int random_number = arc4random()%2;
    if(random_number == 0) {
        elementTrapSprite.elementType = 1;
    }
    else if(random_number == 1){
        elementTrapSprite.elementType = 2;
    }
    elementTrapSprite.tag = tag_elementTrapBox2d;
    [self addChild:elementTrapSprite];
    elementTrapBodyDef.userData = (__bridge void*)elementTrapSprite;
    elementTrapBody = _world->CreateBody(&elementTrapBodyDef);
    // Create shape definition and add to body
    b2FixtureDef elementTrapShapeDef;
    b2CircleShape elementTrapShape;
    elementTrapShape.m_radius = 200.0f/PTM_RATIO;
    elementTrapShapeDef.shape = &elementTrapShape;
    elementTrapShapeDef.density = 0.1f;
    elementTrapShapeDef.friction = 0.0f;
    elementTrapShapeDef.restitution = 1.0f;
    elementTrapShapeDef.filter.categoryBits = COLLISION_FILTER_ELEMENTTRAP;
    elementTrapShapeDef.filter.maskBits = COLLISION_FILTER_PLAYER;
    elementTrapBody->CreateFixture(&elementTrapShapeDef);
    CCParticleSystem *elementTrapExplode;
    if(elementTrapSprite.elementType == 1) {
        elementTrapExplode = [CCParticleSystemQuad particleWithFile:@"elementTrapPoisonExplode.plist"];
    }
    else if(elementTrapSprite.elementType == 2) {
        elementTrapExplode = [CCParticleSystemQuad particleWithFile:@"elementTrapFreezeExplode.plist"];
    }
    elementTrapExplode.position = ccp(elementTrapPos.x, elementTrapPos.y);
    [self addChild:elementTrapExplode z:3 tag:tag_elementTrapParticleBox2d];
    if([self isOutOfShowRange:elementTrapExplode.position type:2]) {
        elementTrapExplode.visible = NO;
    }
    if(![self isOutOfShowRange:elementTrapExplode.position type:1]) {
        if(elementTrapSprite.elementType == 1) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"poisonTrap.mp3"];
        }
        else if(elementTrapSprite.elementType == 2) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"freezeTrap.mp3"];
        }
    }
    
    [self scheduleOnce:@selector(revokeElementTrap) delay:params.elementTrapLastTime];
}

-(void) revokeElementTrap {
    if(trapTriggerd == YES) {
        [self removeChildByTag:tag_elementTrapParticleBox2d cleanup:YES];
        trapTriggerd = NO;
    }
    else {
        if (elementTrapBody->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) elementTrapBody->GetUserData();
            [self removeChild:sprite cleanup:YES];
            [self removeChildByTag:tag_elementTrapParticleBox2d cleanup:YES];
            _world->DestroyBody(elementTrapBody);
        }
    }
}

-(void) killFullScreen {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    b2BodyDef killFullScreenBodyDef;
    killFullScreenBodyDef.type = b2_staticBody;
    CGPoint spaceCraftPos = _spaceCraftSprite.position;
    killFullScreenBodyDef.position.Set(spaceCraftPos.x/PTM_RATIO, spaceCraftPos.y/PTM_RATIO);
    CCSprite *killFullScreenSprite = [CCSprite spriteWithSpriteFrameName:@"plate.png"];
    killFullScreenSprite.visible = NO;
    killFullScreenSprite.tag = tag_killFullScreenBox2d;
    [self addChild:killFullScreenSprite];
    killFullScreenBodyDef.userData = (__bridge void*)killFullScreenSprite;
    killFullScreenBody = _world->CreateBody(&killFullScreenBodyDef);
    
    // Create shape definition and add to body
    b2FixtureDef killFullScreenShapeDef;
    b2CircleShape killFullScreenShape;
    killFullScreenShape.m_radius = screenSize.height/2/PTM_RATIO;
    killFullScreenShapeDef.shape = &killFullScreenShape;
    killFullScreenShapeDef.density = 0.1f;
    killFullScreenShapeDef.friction = 0.0f;
    killFullScreenShapeDef.restitution = 1.0f;
    killFullScreenShapeDef.filter.categoryBits = COLLISION_FILTER_KILLFULLSCREEN;
    killFullScreenShapeDef.filter.maskBits = COLLISION_FILTER_ASTEROID | COLLISION_FILTER_LASER;
    killFullScreenBody->CreateFixture(&killFullScreenShapeDef);
    CCParticleSystem *killFullScreenExplode = [CCParticleSystemQuad particleWithFile:@"killFullScreenExplode.plist"];
    killFullScreenExplode.position = ccp(screenSize.width/2, screenSize.height/2);
    [sharedGameScene addChild:killFullScreenExplode z:3 tag:tag_kill_screen_particle];
    [self scheduleOnce:@selector(revokeKillFullScreen) delay:2.5f];
    [[SimpleAudioEngine sharedEngine] playEffect:@"superKill.mp3"];
}

-(void) revokeKillFullScreen {
    if (killFullScreenBody->GetUserData() != NULL) {
        CCSprite *sprite = (__bridge CCSprite *) killFullScreenBody->GetUserData();
        [self removeChild:sprite cleanup:YES];
        [sharedGameScene removeChildByTag:tag_kill_screen_particle cleanup:YES];
        _world->DestroyBody(killFullScreenBody);
    }
}

-(void) deployBomb {
    CCSprite *bomb = [CCSprite spriteWithSpriteFrameName:@"bomb.png"];
    bomb.visible = YES;
    bomb.tag = tag_bombBox2d;
    bomb.position = _spaceCraftSprite.position;
    [self addChild:bomb];
    id actionDealy = [CCDelayTime actionWithDuration:2.0f];
    id actionIgnite = [CCCallFuncND actionWithTarget:self selector:@selector(igniteBomb:data:) data:(void*)bomb];
    id actionSequence = [CCSequence actions:actionDealy, actionIgnite, nil];
    CCSprite* justForCall = [[CCSprite alloc] init];
    [self addChild:justForCall];
    [justForCall runAction:actionSequence];
}

-(void) igniteBomb:(id)node data:(void*)bomb {
    // Create body
    [node removeFromParentAndCleanup:YES];
    b2BodyDef bombBodyDef;
    bombBodyDef.type = b2_staticBody;
    bombBodyDef.position.Set(((__bridge CCSprite*)bomb).position.x/PTM_RATIO, ((__bridge CCSprite*)bomb).position.y/PTM_RATIO);
    bombBodyDef.userData = bomb;
    bombBody = _world->CreateBody(&bombBodyDef);
    
    // Create shape definition and add to body
    b2FixtureDef bombShapeDef;
    b2CircleShape bombShape;
    bombShape.m_radius = 150.0f/PTM_RATIO;
    bombShapeDef.shape = &bombShape;
    bombShapeDef.density = 0.1f;
    bombShapeDef.friction = 0.0f;
    bombShapeDef.restitution = 1.0f;
    bombShapeDef.filter.categoryBits = COLLISION_FILTER_BOMB;
    bombShapeDef.filter.maskBits = COLLISION_FILTER_ASTEROID | COLLISION_FILTER_LASER;
    bombBody->CreateFixture(&bombShapeDef);
    CCParticleSystem *bombExplode = [CCParticleSystemQuad particleWithFile:@"bombExplode.plist"];
    bombExplode.position = ((__bridge CCSprite*)bomb).position;
    [self addChild:bombExplode z:3 tag:tag_bombParticleBox2d];
    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
    [self scheduleOnce:@selector(revokeBomb) delay:0.3f];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombExplode.mp3"];
}

-(void) revokeBomb {
    if (bombBody->GetUserData() != NULL) {
        CCSprite *sprite = (__bridge CCSprite *) bombBody->GetUserData();
        [self removeChild:sprite cleanup:YES];
        [self removeChildByTag:tag_bombParticleBox2d cleanup:YES];
        _world->DestroyBody(bombBody);
    }
}

-(void) deployInvincible {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    PowerUp *invincible = [PowerUp createPowerUp];
    /*
    if (type == 0) {
        invincible.type = 0;
        type = 1;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerup_increase_life.png"];
        [invincible setDisplayFrame:frame];
    }
    else {
        invincible.type = 1;
        type = 0;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"explosion.png"];
        [invincible setDisplayFrame:frame];
    }
    */
    invincible.visible = YES;
    CGFloat posX = arc4random()%21 * winSize.width/10 - winSize.width/2;
    CGFloat posY = arc4random()%21 * winSize.height/10 - winSize.height/2;
    CGPoint pos = ccp(posX, posY);
    invincible.position = pos;
    invincible.tag = tag_invincibleBox2d;
    [self addChild:invincible];
    
    // Create body
    b2BodyDef invincibleBodyDef;
    invincibleBodyDef.type = b2_dynamicBody;
    invincibleBodyDef.position.Set(invincible.position.x/PTM_RATIO, invincible.position.y/PTM_RATIO);
    invincibleBodyDef.userData = (__bridge void*)invincible;
    b2Body *invincibleBody = _world->CreateBody(&invincibleBodyDef);
    
    // Create shape definition and add to body
    b2FixtureDef invincibleShapeDef;
    b2CircleShape invincibleShape;
    invincibleShape.m_radius = 40.0f/PTM_RATIO;
    invincibleShapeDef.shape = &invincibleShape;
    invincibleShapeDef.density = 0.1f;
    invincibleShapeDef.friction = 0.0f;
    invincibleShapeDef.restitution = 1.0f;
    invincibleShapeDef.filter.categoryBits = COLLISION_FILTER_POWERUP;
    invincibleShapeDef.filter.maskBits = COLLISION_FILTER_PLAYER | COLLISION_FILTER_EDGE | COLLISION_FILTER_POWERUP;
    invincibleBody->CreateFixture(&invincibleShapeDef);
    
    b2Vec2 force = b2Vec2(1, 1);
    invincibleBody->ApplyLinearImpulse(force, invincibleBodyDef.position);
    invincibleBody->ApplyAngularImpulse(1);
}

-(void) addSpaceCraft {
    // Create spaceCraft shadow in Box2dWorld
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _spaceCraftSprite = [SpaceCraft createSpaceCraft];
    _spaceCraftSprite.visible = NO;
    [self addChild:_spaceCraftSprite];
    _spaceCraftSprite.tag = tag_spaceCraftBox2d;
    _spaceCraftSprite.position = ccp(winSize.width/2, winSize.height/2);
    b2BodyDef spaceCraftBodyDef;
    spaceCraftBodyDef.type = b2_staticBody;
    spaceCraftBodyDef.position.Set(winSize.width/2/PTM_RATIO, winSize.height/2/PTM_RATIO);
    spaceCraftBodyDef.userData = (__bridge void*)_spaceCraftSprite;
    _spaceCraft = _world->CreateBody(&spaceCraftBodyDef);
    b2CircleShape spaceCraftShape;
    b2FixtureDef spaceCraftFixture;
    spaceCraftShape.m_radius = 35.0f/PTM_RATIO;
    spaceCraftFixture.shape=&spaceCraftShape;
    spaceCraftFixture.density = 100.0f;
    spaceCraftFixture.restitution = 0.0f;
    spaceCraftFixture.filter.categoryBits = COLLISION_FILTER_PLAYER;
    spaceCraftFixture.filter.maskBits = COLLISION_FILTER_ASTEROID|COLLISION_FILTER_POWERUP | COLLISION_FILTER_LASER | COLLISION_FILTER_ELEMENTTRAP;
    _spaceCraft->CreateFixture(&spaceCraftFixture);
}


-(void) draw
{
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
//	glDisable(GL_TEXTURE_2D);
//	glDisableClientState(GL_COLOR_ARRAY);
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	_world->DrawDebugData();
    
//	glEnable(GL_TEXTURE_2D);
//	glEnableClientState(GL_COLOR_ARRAY);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}


-(void) moveAsteroidLayer:(CGPoint)velocity {
    velocity = ccpMult(velocity, moveSpeed);
    self.position = ccp(self.position.x-velocity.x, self.position.y-velocity.y);
    b2Vec2 newCraftPos = b2Vec2(_spaceCraft->GetPosition().x+velocity.x/PTM_RATIO, _spaceCraft->GetPosition().y+velocity.y/PTM_RATIO);
    _spaceCraft->SetTransform(newCraftPos, 0);
    
    for (int i=0; i<BULLET_COUNT; i++) {
        b2Body *bullet = bulletsArray[i];
        b2Vec2 newBulletsPos = b2Vec2(bullet->GetPosition().x+velocity.x/PTM_RATIO, bullet->GetPosition().y+velocity.y/PTM_RATIO);
        if ((bullet->GetLinearVelocity().Normalize() == 0)) {
            bullet->SetTransform(newBulletsPos, 0);
        }
    }
}

-(void) addBullets {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSpriteFrame *bulletFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"];
    CCSpriteBatchNode *bulletCache = [CCSpriteBatchNode batchNodeWithTexture:bulletFrame.texture capacity:BULLET_COUNT];
    nextBullet = 0;
    [self addChild:bulletCache];
    
    for (int i=0; i<BULLET_COUNT; i++) {
        Bullet *newBullet = [Bullet createBulletWithFrame:bulletFrame];
        newBullet.shootSpeed = 30;
        newBullet.position = ccp(winSize.width/2, winSize.height/2);
        newBullet.tag = tag_bulletInactiveBox2d;
        newBullet.visible = NO;
        [bulletCache addChild:newBullet];
        
        b2BodyDef bulletBodyDef;
        bulletBodyDef.type = b2_dynamicBody;
        bulletBodyDef.position.Set(newBullet.position.x/PTM_RATIO, newBullet.position.y/PTM_RATIO);
        bulletBodyDef.userData = (__bridge void*)newBullet;
        b2Body *bulletBody = _world->CreateBody(&bulletBodyDef);
        
        b2FixtureDef bulletFixtureDef;
        
        b2CircleShape bulletShape;
        bulletShape.m_radius=20.0/PTM_RATIO;
        bulletFixtureDef.shape=&bulletShape;
        bulletFixtureDef.restitution = 0.0f;
        bulletFixtureDef.density = 0.001f;
        bulletFixtureDef.filter.categoryBits = COLLISION_FILTER_BULLETS;
        bulletFixtureDef.filter.maskBits = COLLISION_FILTER_EDGE | COLLISION_FILTER_ASTEROID;
        bulletBody->CreateFixture(&bulletFixtureDef);
        
        bulletsArray[i] = bulletBody;
    }
}

-(void) shootBulletTo: (CGPoint) velocity {
    
    if ((velocity.x!=0) || (velocity.y!=0) ) {
        b2Body *bulletBody = bulletsArray[nextBullet];
        nextBullet++;
        Bullet *bullet = (__bridge Bullet*)bulletBody->GetUserData();
        bullet.tag = tag_bulletBox2d;
//        bullet.visible = YES;
        bulletBody->ApplyForce(b2Vec2(velocity.x*200,velocity.y*200), bulletBody->GetPosition());
        
        
//        [[SimpleAudioEngine sharedEngine] playEffect:@"bulletShoot.mp3"];
        if (nextBullet >= BULLET_COUNT) {
            nextBullet = 0;
        }
    }
}

-(void) deployAsteroidsInitial:(BOOL) initial{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    if(initial == YES) {
        enemy_current_count = params.enemy_count;
        for (int i=0; i<params.enemy_count; i++) {
            CGFloat posX = arc4random()%24 * winSize.width/10 - winSize.width/2;
            CGFloat posY = arc4random()%24 * winSize.height/10 - winSize.height/2;
            if ( (abs( (int)(posX-_spaceCraftSprite.position.x) )<100 ) &&  (abs( (int)(posY-_spaceCraftSprite.position.y) )<100 ) ) {
                posX = winSize.width;
                posY = winSize.height;
            }
            CGPoint pos = ccp(posX, posY);
            float32 forceX = CCRANDOM_MINUS1_1()*8;
            float32 forceY = CCRANDOM_MINUS1_1()*8;
            b2Vec2 force = b2Vec2(forceX, forceY);
            int j = arc4random()%6;
            NSString *frameName;
            if (params.backgroundNo == 3) {
                frameName = [NSString stringWithFormat:@"asteroid%i.png",j];
            }
            else if(params.backgroundNo == 1) {
                frameName = [NSString stringWithFormat:@"asteroid1%i.png",j];
            }
            [self addAsteroidAtPosition:pos Force:force WithFrameName:frameName Shape:shapeArray[j]];
        }
    }
    else {
        CGFloat posX = arc4random()%24 * winSize.width/10 - winSize.width/2;
        CGFloat posY = arc4random()%24 * winSize.height/10 - winSize.height/2;
        if ( (abs( (int)(posX-_spaceCraftSprite.position.x) )<100 ) &&  (abs( (int)(posY-_spaceCraftSprite.position.y) )<100 ) ) {
            posX = winSize.width;
            posY = winSize.height;
        }
        CGPoint pos = ccp(posX, posY);
        float32 forceX = CCRANDOM_MINUS1_1()*8;
        float32 forceY = CCRANDOM_MINUS1_1()*8;
        b2Vec2 force = b2Vec2(forceX, forceY);
        int j = arc4random()%6;
        NSString *frameName;
        if(params.backgroundNo == 3) {
            frameName = [NSString stringWithFormat:@"asteroid%i.png",j];
        }
        else if(params.backgroundNo == 1) {
            frameName = [NSString stringWithFormat:@"asteroid1%i.png",j];
        }
        [self addAsteroidAtPosition:pos Force:force WithFrameName:frameName Shape:shapeArray[j]];
    }
}

-(void) addAsteroidAtPosition: (CGPoint) pos
                        Force: (b2Vec2) force
                WithFrameName: (NSString*) name
                        Shape: (b2PolygonShape) shape{
    
    Asteroid *asteroid = [[Asteroid alloc] initWithSpriteFrameName:name];
    asteroid.position = pos;
    asteroid.healthPoint = arc4random() % 11 + params.base_hp;
    asteroid.tag = tag_asteroidsBox2d;
    [self addChild:asteroid];
    
    // Create ball body
    b2BodyDef asteroidBodyDef;
    asteroidBodyDef.type = b2_dynamicBody;
    asteroidBodyDef.position.Set(asteroid.position.x/PTM_RATIO, asteroid.position.y/PTM_RATIO);
    asteroidBodyDef.userData = (__bridge void*)asteroid;
    b2Body *asteroidBody = _world->CreateBody(&asteroidBodyDef);
    
    // Create shape definition and add to body
    b2FixtureDef asteroidShapeDef;
    asteroidShapeDef.shape = &shape;
    asteroidShapeDef.density = 0.3f;
    asteroidShapeDef.friction = 0.0f;
    asteroidShapeDef.restitution = 1.0f;
    asteroidShapeDef.filter.categoryBits = COLLISION_FILTER_ASTEROID;
    asteroidShapeDef.filter.maskBits = -1;
    asteroidBody->CreateFixture(&asteroidShapeDef);
    
    asteroidBody->ApplyLinearImpulse(force, asteroidBodyDef.position);
    
}

-(void) appearRotateLaser:(CGPoint)pos {
    rotateLaserPos = pos;
    CCParticleSystem *rotateLaserAppear = [CCParticleSystemQuad particleWithFile:@"rotateLaserAppear.plist"];
    rotateLaserAppear.position = pos;
    [self addChild:rotateLaserAppear z:3 tag:tag_rotateLaserParticleBox2d];
    [self scheduleOnce:@selector(deployRotateLaser) delay:2.0f];
    if(![self isOutOfShowRange:pos type:1]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"rotateLaserAppear.mp3"];
    }
}

-(void) deployRotateLaser {
    [self removeChildByTag:tag_rotateLaserParticleBox2d cleanup:YES];
    CGPoint pos = rotateLaserPos;
    CCSprite *laserAnchorSprite = [CCSprite spriteWithSpriteFrameName:@"plate.png"];
    laserAnchorSprite.position = pos;
    laserAnchorSprite.tag = tag_rotateLaserBox2d;
    [self addChild:laserAnchorSprite];
    b2BodyDef laserAnchorBodyDef;
    laserAnchorBodyDef.type = b2_dynamicBody;
    laserAnchorBodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
    laserAnchorBodyDef.userData = (__bridge void*)laserAnchorSprite;
    b2Body *laserAnchorBody = _world->CreateBody(&laserAnchorBodyDef);
    b2FixtureDef laserAnchorFixDef;
    b2CircleShape laserAnchorShape;
    laserAnchorShape.m_radius = 30.0f/PTM_RATIO;
    laserAnchorFixDef.shape = &laserAnchorShape;
    laserAnchorFixDef.density = 10.0f;
    laserAnchorFixDef.filter.categoryBits = COLLISION_FILTER_LASER;
    laserAnchorFixDef.filter.maskBits = COLLISION_FILTER_PLAYER | COLLISION_FILTER_EDGE | COLLISION_FILTER_BOMB | COLLISION_FILTER_KILLFULLSCREEN;
    laserAnchorBody->CreateFixture(&laserAnchorFixDef);

    CCSprite *laserSprite;
    if(params.backgroundNo == 3) {
        laserSprite = [CCSprite spriteWithSpriteFrameName:@"sword01.png"];
        laserSprite.position = ccp(pos.x+90.0f, pos.y+15);
    }
    else if(params.backgroundNo == 1) {
        laserSprite = [CCSprite spriteWithSpriteFrameName:@"sword02.png"];
        laserSprite.position = ccp(pos.x+90.0f, pos.y);
    }
    laserSprite.tag = tag_rotateLaserBox2d;
    [self addChild:laserSprite];
    b2BodyDef laserBodyDef;
    laserBodyDef.type = b2_dynamicBody;
    laserBodyDef.position.Set(laserSprite.position.x/PTM_RATIO, laserSprite.position.y/PTM_RATIO);
    laserBodyDef.userData = (__bridge void*)laserSprite;
    b2Body *laserBody = _world->CreateBody(&laserBodyDef);
    b2FixtureDef laserFixDef;
    b2PolygonShape laserShape;
    laserShape.SetAsBox(150.0f/PTM_RATIO, 10.0f/PTM_RATIO);
    laserFixDef.shape = &laserShape;
    laserFixDef.density = 0.1f;
    laserFixDef.filter.categoryBits = COLLISION_FILTER_LASER;
    laserFixDef.filter.maskBits = COLLISION_FILTER_PLAYER | COLLISION_FILTER_EDGE | COLLISION_FILTER_BOMB;
    laserBody->CreateFixture(&laserFixDef);
    
    b2RevoluteJointDef laserJointDef;
    laserJointDef.Initialize(laserAnchorBody, laserBody, laserAnchorBody->GetWorldCenter());
    laserJointDef.enableMotor = true;
    laserJointDef.maxMotorTorque = 10;
    laserJointDef.motorSpeed = 5;
    (b2RevoluteJoint*)_world->CreateJoint(&laserJointDef);
}

-(void) determinEdgeAlert:(edgeAlert)alert {
    GameEdgeLayer* edgeLayer = (GameEdgeLayer*)[[GameScene sharedGameScene] getEdgeLayer];
    // set Left and Right edge
    switch (alert.typeLR) {
        case 0:
            [edgeLayer setLeftEdgeToDegree:0];
            [edgeLayer setRightEdgeToDegree:0];
            break;
        case 1:
            [edgeLayer setLeftEdgeToDegree:alert.degreeLR];
            break;
        case 2:
            [edgeLayer setRightEdgeToDegree:alert.degreeLR];
            break;
        default:
            break;
    }
    // set Up and Bottom edge
    switch (alert.typeUB) {
        case 0:
            [edgeLayer setUpEdgeToDegree:0];
            [edgeLayer setBottomEdgeToDegree:0];
            break;
        case 1:
            [edgeLayer setUpEdgeToDegree:alert.degreeUB];
            break;
        case 2:
            [edgeLayer setBottomEdgeToDegree:alert.degreeUB];
            break;
        default:
            break;
    }
    
}

-(void) revokeTimeStop {
    timeStopImage.visible = NO;
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    [self schedule:@selector(tick:)];
}

-(void) revodeKillEachOther {
    params.killEachOther = NO;
}

-(void)tick:(ccTime)dt {
    
    // check whether need to add more enemies
    if(enemy_current_count < params.enemy_count) {
        for (int i=0; i<params.enemy_count - enemy_current_count; i++) {
            [self deployAsteroidsInitial:NO];
        }
        enemy_current_count = params.enemy_count;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _world->Step(dt, 10, 10);
    static ccTime attackTime = 0;
    static ccTime laserReleaseTime = 0;
    static ccTime elementTrapReleaseTime = 0;
    /*
    static ccTime garbageCleanTime = 0;
    garbageCleanTime += dt;
    BOOL doGarbageClean;
    if(garbageCleanTime >= params.garbageCleanInterval) {
        doGarbageClean = YES;
        garbageCleanTime=0;
    }
    else {
        doGarbageClean = NO;
    }
    */
    // put rotateLasers into the battle field
    if (params.haveRotateLasers) {
        laserReleaseTime += dt;
        if (laserReleaseTime >= params.rotateLaserInterval) {
            CGFloat posX = arc4random()%21 * winSize.width/10 - winSize.width/2;
            CGFloat posY = arc4random()%21 * winSize.height/10 - winSize.height/2;
            CGPoint pos = ccp(posX, posY);
            [self appearRotateLaser:pos];
            laserReleaseTime = 0;
        }
    }
    // put element trap
    elementTrapReleaseTime += dt;
    if(elementTrapReleaseTime >= params.elementTrapInterval) {
        CGFloat posX = arc4random()%21 * winSize.width/10 - winSize.width/2;
        CGFloat posY = arc4random()%21 * winSize.height/10 - winSize.height/2;
        CGPoint pos = ccp(posX, posY);
        [self appearElementTrap:pos];
        elementTrapReleaseTime = 0;
    }
    
    attackTime += dt;
    int enemyAttackCount = 0;
    std::vector<b2Body*> toDestroy;
    int attack_wave = (arc4random()%enemy_current_count);
    
    int garbageCountPowerUp = 0;
    int garbageCountLaser = 0;
    /* move bodies in Box2d world */
    for (b2Body *b = _world->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite*)b->GetUserData();
            
            // make the enemy attacking
            if (sprite.tag == tag_asteroidsBox2d) {
                
                // limit the highest speed
                if (b->GetLinearVelocity().Length() >= params.max_enemy_speed) {
                    b->SetLinearDamping(0.3);
                }
                // attack AI
                if (attackTime > params.attack_interval) {
                    if(++enemyAttackCount > attack_wave) {
                        attackTime = 0;
 //                       enemyAttackCount=0;
 //                       attack_wave = (arc4random()%enemy_current_count);
                    }
                    // attack to center
                    float32 impulseX = (_spaceCraft->GetPosition().x-b->GetPosition().x)*params.accelerate_rate;
                    float32 impulseY = (_spaceCraft->GetPosition().y-b->GetPosition().y)*params.accelerate_rate;
                    b2Vec2 impulse = b2Vec2(impulseX, impulseY);
                    b->ApplyForce(impulse, b->GetPosition());
                }
            }
            else if(sprite.tag == tag_invincibleBox2d) {
                garbageCountPowerUp++;
                if(garbageCountPowerUp>5) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), b)==toDestroy.end()) {
                        toDestroy.push_back(b);
                    }
                }
            }
            else if(sprite.tag == tag_rotateLaserBox2d) {
                garbageCountLaser++;
                if(garbageCountLaser>=10) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), b)==toDestroy.end()) {
                        toDestroy.push_back(b);
                    }
                }
            }
            // change the sprite position according to box2d body position
            sprite.position = ccp(b->GetPosition().x*PTM_RATIO, b->GetPosition().y*PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    /* check whether spaceCraft is out of bound */
    SpaceCraft* spa = (__bridge SpaceCraft*)_spaceCraft->GetUserData();
    if ([spa isOutOfArea]) {
        NSString* deathReasonString = @"Stay away from the edge!";
        [spaceCraftInGameScene explode:spa.position :deathReasonString :YES];
    }
    else {
        edgeAlert alert = [spa checkEdgeAlertStatus];
        [self determinEdgeAlert:alert];
    }
    
    /* check super skills */
    // check whethre timeStop has been activated
    if(params.timeStop == YES) {
        params.timeStop = NO;
        timeStopImage.visible = YES;
        [self scheduleOnce:@selector(revokeTimeStop) delay:params.timeStopInterval];
        [[SimpleAudioEngine sharedEngine] playEffect:@"timeStop.mp3"];
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [self unschedule:@selector(tick:)];
    }
    // check for superKill
    else if(params.superKill == YES) {
        params.superKill = NO;
        //      [_spaceCraftSprite showBigExplode];
        [self killFullScreen];
    }
    else if(params.energyShield == YES) {
        params.energyShield = NO;
        if (_spaceCraftSprite.invincible == YES) {
            [_spaceCraftSprite revokeInvincible];
        }
        [_spaceCraftSprite becomeInvincible];
    }
    
    
    /* check for collision  */
    std::vector<CollisionData>::iterator pos;
    for (pos = _collisionDetector->collisions.begin(); pos!= _collisionDetector->collisions.end(); pos++) {
        CollisionData collsion = *pos;
        b2Body* body1 = collsion.fixtureA->GetBody();
        b2Body* body2 = collsion.fixtureB->GetBody();
        
        // check collision between bullet and edge
        if (body1 == _groundBody) {
                CCSprite *sprite2 = (__bridge CCSprite*)body2->GetUserData();
            if ( (sprite2.tag == tag_bulletBox2d) || (sprite2.tag == tag_bulletInactiveBox2d)) {
                body2->SetLinearVelocity(b2Vec2(0,0));
                body2->SetAngularVelocity(0);
                
                Bullet* bullet = (__bridge Bullet*)body2->GetUserData();
                bullet.tag = tag_bulletInactiveBox2d;
                bullet.visible = NO;
                
                body2->SetTransform(_spaceCraft->GetPosition(), 0);
            }
        }
        else if (body2 == _groundBody) {
            CCSprite *sprite1 = (__bridge CCSprite*)body1->GetUserData();
            if ((sprite1.tag == tag_bulletBox2d) || (sprite1.tag == tag_bulletInactiveBox2d)) {
                body1->SetLinearVelocity(b2Vec2(0,0));
                body1->SetAngularVelocity(0);
                
                Bullet* bullet = (__bridge Bullet*)body1->GetUserData();
                bullet.tag = tag_bulletInactiveBox2d;
                bullet.visible = NO;
                
                body1->SetTransform(_spaceCraft->GetPosition(), 0);
            }
        }
        
        if((body1->GetUserData()!=NULL) && (body2->GetUserData()!=NULL)) {
            CCSprite *sprite1 = (__bridge CCSprite*)body1->GetUserData();
            CCSprite *sprite2 = (__bridge CCSprite*)body2->GetUserData();
            
            
            // check collision between SpaceCraft and Asteroid
            if((sprite1.tag == tag_spaceCraftBox2d) && ((sprite2.tag == tag_asteroidsBox2d))) {
                NSString* deathReasonString = @"You're hit by the asteroid!";
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                enemy_current_count--;
                params.enemyEliminate++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite2.position)];
                if ( _spaceCraftSprite.invincible != YES) {
                    [spaceCraftInGameScene explode: sprite1.position :deathReasonString :NO];
                }
            }
            else if((sprite2.tag == tag_spaceCraftBox2d) && ((sprite1.tag == tag_asteroidsBox2d))) {
                NSString* deathReasonString = @"You're hit by the asteroid!";
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                enemy_current_count--;
                params.enemyEliminate++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite1.position)];
                if ( _spaceCraftSprite.invincible != YES) {
                    [spaceCraftInGameScene explode: sprite2.position :deathReasonString :NO];
                }
            }
            
            
            // collision between SpaceCraft and Rotate Laser
            else if(sprite1.tag==tag_spaceCraftBox2d && sprite2.tag==tag_rotateLaserBox2d) {
                NSString* deathReasonString = @"You're hit by rotate laser! Avoid them!";
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                params.enemyEliminate++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite2.position)];
                if ( _spaceCraftSprite.invincible != YES) {
                    [spaceCraftInGameScene explode: sprite1.position :deathReasonString :NO];
                }
            }
            else if(sprite2.tag==tag_spaceCraftBox2d && sprite1.tag==tag_rotateLaserBox2d) {
                NSString* deathReasonString = @"You're hit by rotate laser! Avoid them!";
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                params.enemyEliminate++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite1.position)];
                if ( _spaceCraftSprite.invincible != YES) {
                    [spaceCraftInGameScene explode: sprite2.position :deathReasonString :NO];
                }
            }
            
            // check collision between SpaceCraft and Element Trap
            else if(sprite1.tag == tag_spaceCraftBox2d && sprite2.tag == tag_elementTrapBox2d) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                }
                trapTriggerd = YES;
                ElementTrap *trap = (ElementTrap*)sprite2;
                if(trap.elementType == 1) {
                    if(spaceCraftInGameScene.isPoisoned == NO) {
                        [spaceCraftInGameScene getPoisoned];
                    }
                }
                else if(trap.elementType == 2) {
                    if(spaceCraftInGameScene.isFreezed == NO) {
                        [spaceCraftInGameScene getFreezed];
                    }
                }
            }
            else if(sprite2.tag == tag_spaceCraftBox2d && sprite1.tag == tag_elementTrapBox2d) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                }
                trapTriggerd = YES;
                ElementTrap *trap = (ElementTrap*)sprite1;
                if(trap.elementType == 1) {
                    if(spaceCraftInGameScene.isPoisoned == NO) {
                        [spaceCraftInGameScene getPoisoned];
                    }
                }
                else if(trap.elementType == 2) {
                    if(spaceCraftInGameScene.isFreezed == NO) {
                        [spaceCraftInGameScene getFreezed];
                    }
                }
            }
            
            // check collision between Bullet and Asteroid
            else if((sprite1.tag == tag_bulletBox2d) && (sprite2.tag == tag_asteroidsBox2d)) {
                body1->SetLinearVelocity(b2Vec2(0,0));
                body1->SetAngularVelocity(0);
                Bullet* bullet = (__bridge Bullet*)body1->GetUserData();
                bullet.tag = tag_bulletInactiveBox2d;
                bullet.visible = NO;
                body1->SetTransform(_spaceCraft->GetPosition(), 0);
                Asteroid *asteroid = (Asteroid*)sprite2;
                asteroid.healthPoint = asteroid.healthPoint-1;
                
                if (spaceCraftInGameScene.weaponSE == 0) {
                  //  [asteroid setColor:ccc3(153, 205, 255)];
                    [asteroid setColor:ccc3(255, 0, 0)];
                    body2->SetLinearDamping(0.2);
                }
                else {
                    [asteroid setColor:ccc3(255, 0, 0)];
                }
                asteroid.changeColor = YES;
                
                if(asteroid.healthPoint<=0) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                        toDestroy.push_back(body2);
                        [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                    }
                    enemy_current_count--;
                    params.enemyEliminate++;
                    [statsLayer increasePowerBar];
                    [self runParticleEffect:1 :(sprite2.position)];
                }
                
            }
            else if((sprite2.tag == tag_bulletBox2d) && (sprite1.tag == tag_asteroidsBox2d)) {
                body2->SetLinearVelocity(b2Vec2(0,0));
                body2->SetAngularVelocity(0);
                Bullet* bullet = (__bridge Bullet*)body2->GetUserData();
                bullet.tag = tag_bulletInactiveBox2d;
                bullet.visible = NO;
                body2->SetTransform(_spaceCraft->GetPosition(), 0);
                Asteroid *asteroid = (Asteroid*)sprite1;
                asteroid.healthPoint = asteroid.healthPoint-1;
                
                if (spaceCraftInGameScene.weaponSE == 0) {
                  //  [asteroid setColor:ccc3(153, 204, 255)];
                    [asteroid setColor:ccc3(255, 0, 0)];
                    body1->SetLinearDamping(0.2);
                }
                else {
                    [asteroid setColor:ccc3(255, 0, 0)];
                }
                asteroid.changeColor = YES;
                
                if(asteroid.healthPoint<=0) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                        toDestroy.push_back(body1);
                        [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                    }
                    enemy_current_count--;
                    params.enemyEliminate++;
                    [statsLayer increasePowerBar];
                    [self runParticleEffect:1 :(sprite1.position)];
                }
            }
            
            
            // check collision between Asteroid and Asteroid
            else if(params.killEachOther==YES && (sprite1.tag == tag_asteroidsBox2d) && (sprite2.tag == tag_asteroidsBox2d)) {
                Asteroid *asteroid2 = (Asteroid*)sprite2;
                asteroid2.healthPoint = asteroid2.healthPoint-1;
                [asteroid2 setColor:ccc3(255, 0, 0)];
                asteroid2.changeColor = YES;
                
                Asteroid *asteroid1 = (Asteroid*)sprite1;
                asteroid1.healthPoint = asteroid1.healthPoint-1;
                [asteroid1 setColor:ccc3(255, 0, 0)];
                asteroid1.changeColor = YES;
                
                if(asteroid2.healthPoint<=0) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                        toDestroy.push_back(body2);
                    }
                    enemy_current_count--;
                    params.enemyEliminate++;
                    [self runParticleEffect:1 :(sprite2.position)];
                }
                if(asteroid1.healthPoint<=0) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                        toDestroy.push_back(body1);
                    }
                    enemy_current_count--;
                    params.enemyEliminate++;
                    [self runParticleEffect:1 :(sprite1.position)];
                }
                [self scheduleOnce:@selector(revodeKillEachOther) delay:5.0f];
            }

            // check collision between Bomb and Asteroid
            else if ((sprite1.tag == tag_bombBox2d) && (sprite2.tag == tag_asteroidsBox2d)) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                }
                enemy_current_count--;
                params.enemyEliminate++;
                params.bombHit++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite2.position)];
            }
            else if ((sprite2.tag == tag_bombBox2d) && (sprite1.tag == tag_asteroidsBox2d)) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                }
                enemy_current_count--;
                params.enemyEliminate++;
                params.bombHit++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite1.position)];
            }
            
            // check collision between Bomb and rotate laser
            else if ((sprite1.tag == tag_bombBox2d) && (sprite2.tag == tag_rotateLaserBox2d)) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                params.bombHit++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite2.position)];
            }
            else if ((sprite2.tag == tag_bombBox2d) && (sprite1.tag == tag_rotateLaserBox2d)) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                params.bombHit++;
                [statsLayer increasePowerBar];
                [self runParticleEffect:1 :(sprite1.position)];
            }
            
            // check collision between killFullScreen and other things
            else if(sprite1.tag==tag_killFullScreenBox2d && (sprite2.tag==tag_rotateLaserBox2d || sprite2.tag==tag_asteroidsBox2d)) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                [statsLayer increasePowerBar];
                params.bombHit++;
                if(sprite2.tag==tag_asteroidsBox2d) {
                    enemy_current_count--;
                    params.enemyEliminate++;
                }
                [self runParticleEffect:1 :(sprite2.position)];
            }
            else if(sprite2.tag==tag_killFullScreenBox2d && (sprite1.tag==tag_rotateLaserBox2d || sprite1.tag==tag_asteroidsBox2d)) {
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                    [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
                }
                [statsLayer increasePowerBar];
                params.bombHit++;
                if(sprite1.tag==tag_asteroidsBox2d) {
                    enemy_current_count--;
                    params.enemyEliminate++;
                }
                [self runParticleEffect:1 :(sprite1.position)];
            }
            
            // check collision between Invincible and spaceCraft
            else if((sprite1.tag == tag_invincibleBox2d) && (sprite2.tag == tag_spaceCraftBox2d)) {
                if (((PowerUp*)sprite1).type == 1) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.mp3"];
                    [statsLayer increaseLife];
                }
                else if(((PowerUp*)sprite1).type == 2) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerDown.mp3"];
                    [spaceCraftInGameScene disableShootBullet];
                }
                else if(((PowerUp*)sprite1).type == 3) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.mp3"];
                    params.tick_survived += 10;
                }
                else if(((PowerUp*)sprite1).type == 4) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerDown.mp3"];
                    [spaceCraftInGameScene disableMove];
                }
                else if(((PowerUp*)sprite1).type == 5) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.mp3"];
                    [statsLayer fullPowerBar];
                }
                else if(((PowerUp*)sprite1).type == 6) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerDown.mp3"];
                    [statsLayer disablePowerBar];
                }
                if (std::find(toDestroy.begin(), toDestroy.end(), body1)==toDestroy.end()) {
                    toDestroy.push_back(body1);
                }
            }
            else if((sprite2.tag == tag_invincibleBox2d) && (sprite1.tag == tag_spaceCraftBox2d)) {
                if (((PowerUp*)sprite2).type == 1) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.mp3"];
                    [statsLayer increaseLife];
                }
                else if(((PowerUp*)sprite2).type == 2) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerDown.mp3"];
                    [spaceCraftInGameScene disableShootBullet];
                }
                else if(((PowerUp*)sprite2).type == 3) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.mp3"];
                    params.tick_survived += 10;
                }
                else if(((PowerUp*)sprite2).type == 4) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerDown.mp3"];
                    [spaceCraftInGameScene disableMove];
                }
                else if(((PowerUp*)sprite2).type == 5) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.mp3"];
                    [statsLayer fullPowerBar];
                }
                else if(((PowerUp*)sprite2).type == 6) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"powerDown.mp3"];
                    [statsLayer disablePowerBar];
                }
                if (std::find(toDestroy.begin(), toDestroy.end(), body2)==toDestroy.end()) {
                    toDestroy.push_back(body2);
                }
            }
            
        }
    }
    
    std::vector<b2Body *>::iterator destroyerPos;
    for (destroyerPos = toDestroy.begin(); destroyerPos!= toDestroy.end(); ++destroyerPos) {
        b2Body *body = *destroyerPos;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        _world->DestroyBody(body);
//        [statsLayer increasePowerBar];
    }
    if (toDestroy.size() > 0) {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"asteroidExplosion.mp3"];
    }
}

-(void) runParticleEffect: (int) type :(CGPoint) pos {
    static int runTimes = 0;
    runTimes++;
    int random = 0;
    if (type == 1) {
        random = arc4random() % 10+1;
    }
    CCParticleSystem *particleSystem;
    if (runTimes >= 5) {
        runTimes = 0;
        [self removeChildByTag:tag_particleSysBox2d cleanup:YES];
    }
    NSString* effectName = [NSString stringWithFormat:@"rockExplosion%i.plist",random];
    particleSystem = [CCParticleSystemQuad particleWithFile:effectName];
    particleSystem.position = pos;
    [self addChild:particleSystem z:3 tag:tag_particleSysBox2d];
}

-(int) getCurrentEnemyCount {
    return enemy_current_count;
}

-(id) getSpaceCraftInBox2d {
    return _spaceCraftSprite;
}

-(void)dealloc {
    delete _world;
    delete _debugDraw;
    delete _collisionDetector;
}

@end


