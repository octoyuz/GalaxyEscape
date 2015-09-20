//
//  PlanetsLayer.h
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PlanetsLayer : CCLayer {
    
}

#define PLANETS_COUNT 4

@property CGFloat moveSpeed;

+(id) createPlanets;

-(void) movePlanets: (CGPoint) velocity;

-(void) switchPlanets: (CGPoint)velocity;

@end
