//
//  Bomb.m
//  Galaxy_Escape
//
//  Created by Tony on 4/2/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "Bomb.h"


@implementation Bomb

+(id) createBombWithFrameName:(NSString*) name {
    return [[self alloc] initWithBombImage:name];
}

-(id) initWithBombImage:(NSString*) name {
    if (self = [super initWithSpriteFrameName:name]) {
        [self schedule:@selector(bombExplode) interval:2.0f];
    }
    return self;
}

-(void) bombExplode {
    return;
}

@end
