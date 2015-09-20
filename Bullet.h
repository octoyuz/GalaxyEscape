//
//  Bullet.h
//  Galaxy_Escape
//
//  Created by Tony on 2/24/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Bullet : CCSprite {
    
}

// should be set according to content size of the spaceCraft
#define BULLET_INITIAL_POSTION 14 

@property CGFloat shootSpeed;   // the less, the faster

+(id) createBulletWithFrameName: (NSString*) name;
+(id) createBulletWithFrame: (CCSpriteFrame*) frame;

-(void) shootToDirection: (CGPoint) direction;

@end
