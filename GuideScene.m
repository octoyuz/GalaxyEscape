//
//  GuideScene.m
//  Galaxy_Escape
//
//  Created by Tony on 4/26/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "GuideScene.h"


@implementation GuideScene

+(CCScene*) scene {
    CCScene* scene = [CCScene node];
    
    // add the main game scene layer
    GuideScene* layer = [GuideScene node];
    [scene addChild:layer z:-1];
    return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CCSprite *bg = [CCSprite spriteWithFile:@"guideImage.png"];
        bg.position = ccp(screenSize.width/2,screenSize.height/2);
        [self addChild:bg z:1];
        
        CCSprite *lowerBG = [CCSprite spriteWithFile:@"guideSceneBG.png"];
        lowerBG.position = ccp(screenSize.width/2,screenSize.height/2);
        [self addChild:lowerBG z:0];
        
        CCMenuItem *starMenuItem_1 = [CCMenuItemImage
                                      itemWithNormalImage:@"menuButton_back.png" selectedImage:@"menuButton_back_light.png" target:self selector:@selector(backToGameScene)];
        starMenuItem_1.position = CGPointZero;
        CCMenu *starMenu_1 = [CCMenu menuWithItems:starMenuItem_1, nil];
        starMenu_1.position = ccp(screenSize.width/2,70);
        [self addChild:starMenu_1 z:2];
    }
    return self;
}

-(void)backToGameScene {
    [[CCDirector sharedDirector] popScene];
}

@end
