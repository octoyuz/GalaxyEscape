//
//  Bullet.m
//  Galaxy_Escape
//
//  Created by Tony on 2/24/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "Bullet.h"


@implementation Bullet

@synthesize shootSpeed;


+(id) createBulletWithFrameName: (NSString*) name {
    return [[self alloc] initWithSpriteFrameName:name];
}

+(id) createBulletWithFrame: (CCSpriteFrame*) frame {
    return [[self alloc] initWithSpriteFrame:frame];
}

-(void) shootToDirection:(CGPoint)direction {
    self.visible = YES;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    self.position = ccpAdd(ccp(screenSize.width/2,screenSize.height/2), ccpMult(direction,BULLET_INITIAL_POSTION));
    CCAction *shoot = [CCMoveBy actionWithDuration:shootSpeed position:ccp(direction.x*screenSize.width*1.5, direction.y*screenSize.height*1.5)];
    [self runAction:shoot];
}

@end