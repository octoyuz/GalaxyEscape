//
//  PlanetsLayer.m
//  Galaxy_Escape
//
//  Created by Tony on 2/23/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "PlanetsLayer.h"


@implementation PlanetsLayer

CCArray *planets;

@synthesize moveSpeed;

+(id) createPlanets {
    return [[self alloc] initPlanets];
}

-(id) initPlanets {
    self = [super init];
    if (self) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGFloat width = screenSize.width;
        CGFloat height = screenSize.height;
        
        planets = [CCArray arrayWithCapacity:PLANETS_COUNT];
        for (int i=0; i<1; i++) {
            NSString *frameName = [NSString stringWithFormat:@"planet%i.png",i];
            [planets addObject:[CCSprite spriteWithSpriteFrameName:frameName]];
            [self addChild:[planets objectAtIndex:i] z:0];
        }
        
        ((CCSprite*)[planets objectAtIndex:0]).position = ccp(width/2,height/2);
//        ((CCSprite*)[planets objectAtIndex:1]).position = ccp(width/2,height/2);
//        ((CCSprite*)[planets objectAtIndex:2]).position = ccp(width,0);
//        ((CCSprite*)[planets objectAtIndex:3]).position = ccp(width,height);
        
    }

//    [self scheduleUpdate];
    return self;
}

-(void) movePlanets:(CGPoint)velocity {
    velocity = ccpMult(velocity, moveSpeed);
    for(CCSprite* planet in planets) {
        planet.position = ccp(planet.position.x-velocity.x, planet.position.y-velocity.y);
    }
}
/*
-(void) switchPlanets: (CGPoint)velocity {
    [self movePlanets:velocity];
    [self update:0];
}

-(void) update:(ccTime)delta {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for(CCSprite* planet in planets) {
        if (planet.position.y < -screenSize.height*1.5 ) {
            planet.position = CGPointMake(planet.position.x, screenSize.height*1.5);
        }
        
        if (planet.position.y > screenSize.height*1.5 ) {
            planet.position = CGPointMake(planet.position.x, -screenSize.height*1.5);
        }
        
        if (planet.position.x < -screenSize.width*1.5 ) {
            planet.position = CGPointMake(screenSize.width*1.5, planet.position.y);
        }
        
        if (planet.position.x > screenSize.width*1.5 ) {
            planet.position = CGPointMake(-screenSize.width*1.5, planet.position.y);
        }
    }
}
*/

@end
