//
//  Asteroid.m
//  Galaxy_Escape
//
//  Created by Tony on 3/1/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "Asteroid.h"


@implementation Asteroid

-(id) initWithSpriteFrameName: (NSString *)spriteFrameName {
    self = [super initWithSpriteFrameName:spriteFrameName];
    self.healthPoint = 10;
    self.changeColor = NO;
    [self schedule:@selector(restoreColorAndPosition:) interval:0.2f];
    return self;
}

-(void) restoreColorAndPosition:(ccTime)delta {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if (self.changeColor == YES) {
        [self setColor:ccc3(255, 255, 255)];
    }
    if ([self isOutOfArea]) {
        self.position = ccp(-winSize.width+40, -winSize.height+40);
    }
}

-(BOOL) isOutOfArea {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if ( (self.position.x<(-winSize.width)) || (self.position.x>(winSize.width*2)) ) {
        return YES;
    }
    if ( (self.position.y<(-winSize.height)) || (self.position.y>(winSize.height*2)) ) {
        return YES;
    }
    return NO;
}

@end
