//
//  LoadingScene.m
//  Galaxy_Escape
//
//  Created by Tony on 4/10/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "LoadingScene.h"

static MainGameParameters *params;

@implementation LoadingScene
+(CCScene*) sceneWithParameters:(MainGameParameters *)parameters {
    CCScene* scene = [CCScene node];
    // add the main game scene layer
    LoadingScene* layer = [[LoadingScene alloc] initWithParameters:parameters];
    [scene addChild:layer z:-1];
    return scene;
}

- (id)initWithParameters:(MainGameParameters*)parameters
{
    self = [super init];
    if (self) {
        params = parameters;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CCSprite *bg = [CCSprite spriteWithFile:@"loadingSceneBG.png"];
        bg.position = ccp(screenSize.width/2,screenSize.height/2);
        [self addChild:bg z:0];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF * label = [CCLabelTTF labelWithString:@"L O A D I N G . . . . . ." fontName:@"Arial" fontSize:32];
        label.color = ccc3(105,158,250);
        label.position = ccp(winSize.width-200, 80);
        [self addChild:label z:1];
        
        [self scheduleOnce:@selector(changeToGameScene) delay:2.0f];
    }
    return self;
}

-(void)changeToGameScene {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressInOut transitionWithDuration:0.5f scene:[GameScene sceneWithParams:params]]];
}

@end
