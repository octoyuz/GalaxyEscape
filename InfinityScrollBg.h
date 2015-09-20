//
//  InfinityScrollBg.h
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainGameParameters.h"
#import "GameScene.h"

@interface InfinityScrollBg : CCLayer {
    
}

@property CGFloat moveSpeed;

+(id) createInfinityScrollBg;

-(void) moveBackgrounds: (CGPoint) velocity;
/*
-(void) switchInfinityBackgrounds:(CGPoint)velocity;
*/
@end
