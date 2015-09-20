//
//  InfinityScrollBg.m
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "InfinityScrollBg.h"


@implementation InfinityScrollBg

CCSprite *background;

static MainGameParameters *params;

@synthesize moveSpeed;

+(id) createInfinityScrollBg {
    return [[self alloc] initNineBackgrounds];
}

-(id) initNineBackgrounds {
    self = [super init];
    if (self) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        params = [[GameScene sharedGameScene] getSharedParameters];
        if(params.backgroundNo == 1) {
            background = [CCSprite spriteWithFile:@"background_1.png"];
        }
        else if(params.backgroundNo == 3) {
            background = [CCSprite spriteWithFile:@"background_3.png"];
        }
        
        self.moveSpeed = params.lowerBackgroundMoveSpeed;
        
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background];
        
        /*
        backgrounds = [CCArray arrayWithCapacity:9];
        for (int i=0; i<9; i++) {
            NSString *frameName = [NSString stringWithFormat:@"bg%i.png",arc4random()%9];
            [backgrounds addObject:[CCSprite spriteWithFile:frameName]];
            [self addChild:[backgrounds objectAtIndex:i] z:0];
        }
        ((CCSprite*)[backgrounds objectAtIndex:0]).position = ccp(-screenSize.width/2, screenSize.height*1.5);
        ((CCSprite*)[backgrounds objectAtIndex:1]).position = ccp(screenSize.width/2, screenSize.height*1.5);
        ((CCSprite*)[backgrounds objectAtIndex:2]).position = ccp(screenSize.width*1.5, screenSize.height*1.5);
        ((CCSprite*)[backgrounds objectAtIndex:3]).position = ccp(-screenSize.width/2, screenSize.height/2);
        ((CCSprite*)[backgrounds objectAtIndex:4]).position = ccp(screenSize.width/2, screenSize.height/2);
        ((CCSprite*)[backgrounds objectAtIndex:5]).position = ccp(screenSize.width*1.5, screenSize.height/2);
        ((CCSprite*)[backgrounds objectAtIndex:6]).position = ccp(-screenSize.width/2, -screenSize.height/2);
        ((CCSprite*)[backgrounds objectAtIndex:7]).position = ccp(screenSize.width/2, -screenSize.height/2);
        ((CCSprite*)[backgrounds objectAtIndex:8]).position = ccp(screenSize.width*1.5, -screenSize.height/2);
        [self scheduleUpdate];
        */
    }
    
    return self;
}

-(void) moveBackgrounds:(CGPoint)velocity {
    velocity = ccpMult(velocity, moveSpeed);
    background.position = ccp(background.position.x-velocity.x, background.position.y-velocity.y);
}
/*
-(void) switchInfinityBackgrounds:(CGPoint)velocity {
    [self moveBackgrounds:velocity];
    [self update:0];
}

-(void) update:(ccTime)delta {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for(CCSprite* bg in backgrounds) {
        if (bg.position.y < -screenSize.height*1.5 ) {
            bg.position = CGPointMake(bg.position.x, screenSize.height*1.5);
        }
        
        if (bg.position.y > screenSize.height*1.5 ) {
            bg.position = CGPointMake(bg.position.x, -screenSize.height*1.5);
        }
        
        if (bg.position.x < -screenSize.width*1.5 ) {
            bg.position = CGPointMake(screenSize.width*1.5, bg.position.y);
        }
        
        if (bg.position.x > screenSize.width*1.5 ) {
            bg.position = CGPointMake(-screenSize.width*1.5, bg.position.y);
        }
    }
}
*/
@end
