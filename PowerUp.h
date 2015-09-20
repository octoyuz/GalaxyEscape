//
//  PowerUp.h
//  Galaxy_Escape
//
//  Created by Tony on 3/12/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainGameParameters.h"
#import "GameScene.h"



@interface PowerUp : CCSprite {
    
}


/*
 1: +1 life
 2: no shoot
 3: +10 survival time
 4: stay
 5: power bar full
 6: freeze power bar
*/
@property int type;

+(PowerUp*) createPowerUp;

@end
