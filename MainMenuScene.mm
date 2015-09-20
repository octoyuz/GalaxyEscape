//
//  MainMenuScene.m
//  Galaxy_Escape
//
//  Created by Tony on 4/24/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "MainMenuScene.h"
#import "GuideScene.h"

@implementation MainMenuScene

static CCSprite *changingBG1;
static CCSprite *changingBG2;
static BOOL isBG1;

static BOOL isHardMode;

static MainGameParameters *params;

static CCSprite *hcButton;

+(CCScene*) scene {
    CCScene* scene = [CCScene node];
    // add the main game scene layer
    MainMenuScene *layer = [[MainMenuScene alloc] init];
    [scene addChild:layer z:-1];
    return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        params = [MainGameParameters node];
        changingBG1 = [CCSprite spriteWithFile:@"MainMenuBG1.png"];
        changingBG2 = [CCSprite spriteWithFile:@"MainMenuBG2.png"];
        changingBG1.position = ccp(screenSize.width/2, screenSize.height/2);
        changingBG2.position = ccp(screenSize.width/2, screenSize.height/2);
        changingBG1.opacity = 0;
        changingBG2.opacity = 255;
        isBG1 = NO;
        [self addChild:changingBG1 z:0];
        [self addChild:changingBG2 z:0];
        [self schedule:@selector(changingBackground) interval:0.03f];
        isHardMode = NO;
        
        CCMenuItem *playButton = [CCMenuItemImage
                                     itemWithNormalImage:@"playButton.png" selectedImage:@"playButton_light.png" target:self selector:@selector(changeToThemeScene)];
        playButton.position = CGPointZero;
        CCMenu *playButtonMenu = [CCMenu menuWithItems:playButton, nil];
        playButtonMenu.position = ccp(screenSize.width/2,screenSize.height/2 + 100.0f);
        [self addChild:playButtonMenu z:1];
        
        CCMenuItem *guideButton = [CCMenuItemImage
                                      itemWithNormalImage:@"guideButton.png" selectedImage:@"guideButton_light.png" target:self selector:@selector(changeToGuideScene)];
        guideButton.position = CGPointZero;
        CCMenu *guideButtonMenu = [CCMenu menuWithItems:guideButton, nil];
        guideButtonMenu.position = ccp(screenSize.width/2,screenSize.height/2 - 100.0f);
        [self addChild:guideButtonMenu z:1];
        
        CCMenuItem *modeButton = [CCMenuItemImage
                                   itemWithNormalImage:@"HCButton.png" selectedImage:@"HCButton.png" target:self selector:@selector(changeToHardCoreMode)];
        modeButton.position = CGPointZero;
        CCMenu *modeButtonMenu = [CCMenu menuWithItems:modeButton, nil];
        modeButtonMenu.position = ccp(screenSize.width/2,screenSize.height/2 - 300.0f);
        [self addChild:modeButtonMenu z:1];
        
        hcButton = [CCSprite spriteWithFile:@"HCButton_red.png"];
        hcButton.position = ccp(screenSize.width/2,screenSize.height/2 - 300.0f);;
        hcButton.visible = NO;
        [self addChild:hcButton z:2];
        
/*
        CCLabelTTF * label = [CCLabelTTF labelWithString:@"Galaxy Escape" fontName:@"Courier" fontSize:70];
        // Snell Roundhand
        label.color = ccc3(200,200,200);
        label.position = ccp(285, screenSize.height-100);
        [self addChild:label z:3];
*/ 
/*
        CCSprite *uscLogo = [CCSprite spriteWithFile:@"USCGameLogo.png"];
        uscLogo.position = ccp(screenSize.width-150,70);
        [self addChild:uscLogo z:2];
*/        
    }
    return self;
}

-(void) changeToHardCoreMode {
    if (isHardMode == YES) {
        params.canShootBullet = YES;
        params.canSetBomb = YES;
        params.havePowerUp = YES;
        params.isHardCore = NO;
        
        isHardMode = NO;
        hcButton.visible = NO;
        params.enemy_count = 10;
    }
    else {
        params.canShootBullet = NO;
        params.canSetBomb = NO;
        params.havePowerUp = NO;
        params.isHardCore = YES;
        
        isHardMode = YES;
        hcButton.visible = YES;
        params.enemy_count = 15;
    }
}

-(void) changeToThemeScene {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ThemeScene sceneWithParameters:params]]];
}

-(void) changeToGuideScene {
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GuideScene scene]]];
    [[CCDirector sharedDirector] pushScene:[GuideScene scene]];
}

-(void) changingBackground {
    if(isBG1) {
        changingBG1.opacity -= 1;
        changingBG2.opacity += 1;
        if(changingBG1.opacity == 0) {
            isBG1 = NO;
        }
    }
    else {
        changingBG1.opacity += 1;
        changingBG2.opacity -= 1;
        if(changingBG2.opacity == 0) {
            isBG1 = YES;
        }
    }
}

@end
