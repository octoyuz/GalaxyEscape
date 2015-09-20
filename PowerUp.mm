//
//  PowerUp.m
//  Galaxy_Escape
//
//  Created by Tony on 3/12/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "PowerUp.h"


@implementation PowerUp

@synthesize type;

static MainGameParameters *params;

+(PowerUp*)createPowerUp {
    return [[self alloc] init];
}

- (id)init
{
    self = [super initWithSpriteFrameName:@"powerup_increase_life.png"];
    if (self) {
        params = [[GameScene sharedGameScene] getSharedParameters];
        self.type = 1;
        [self schedule:@selector(changePowerUpState) interval:params.powerUpChangeInterval];
    }
    return self;
}

-(void) changePowerUpState {
    if(self.type == 1) {
        self.type = 2;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerdown_noshoot.png"];
        [self setDisplayFrame:frame];
    }
    else if(self.type == 2) {
        self.type = 3;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerup_increasetime.png"];
        [self setDisplayFrame:frame];
    }
    else if(self.type == 3) {
        self.type = 4;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerdown_shipstoping.png"];
        [self setDisplayFrame:frame];
    }
    else if(self.type == 4) {
        self.type = 5;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerup_fullenergy.png"];
        [self setDisplayFrame:frame];
    }
    else if(self.type == 5) {
        self.type = 6;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerdown_energyfreeze.png"];
        [self setDisplayFrame:frame];
    }
    else if(self.type == 6) {
        self.type = 1;
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"powerup_increase_life.png"];
        [self setDisplayFrame:frame];
    }
}

@end
