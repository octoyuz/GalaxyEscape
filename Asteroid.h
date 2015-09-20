//
//  Asteroid.h
//  Galaxy_Escape
//
//  Created by Tony on 3/1/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface Asteroid : CCSprite {
    
}


@property int healthPoint;

@property BOOL changeColor;

-(BOOL) isOutOfArea;
 
@end
