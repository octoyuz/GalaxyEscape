//
//  GameEdgeLayer.m
//  Galaxy_Escape
//
//  Created by Tony on 3/4/13.
//  Copyright 2013 USC. All rights reserved.
//

#import "GameEdgeLayer.h"


CCArray *upperEdgeElement;
CCArray *bottomEdgeElement;
CCArray *leftEdgeElement;
CCArray *rightEdgeElement;


@implementation GameEdgeLayer

- (id)init
{
    self = [super init];
    if (self) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGFloat width = winSize.width;
        CGFloat height = winSize.height;
        CCSprite *tester = [CCSprite spriteWithSpriteFrameName:@"edgeElement0.png"];
        
        // init the arrays
        upperEdgeElement = [CCArray arrayWithCapacity:12];
        bottomEdgeElement = [CCArray arrayWithCapacity:12];
        leftEdgeElement = [CCArray arrayWithCapacity:9];
        rightEdgeElement = [CCArray arrayWithCapacity:9];
        
        
        // bottom edge
        CGFloat posX=-width+tester.contentSize.width/2;
        CGFloat posY=-height;
        for (int i=0; i<12; i++) {
            CCSprite *edgeElement = [CCSprite spriteWithSpriteFrameName:@"edgeElement0.png"];
            edgeElement.position = ccp(posX, posY);
            [self addChild:edgeElement];
            posX += edgeElement.contentSize.width;
            [bottomEdgeElement addObject:edgeElement];
        }
        // up edge
        posX =-width+tester.contentSize.width/2;
        posY =height*2;
        for (int i=0; i<12; i++) {
            CCSprite *edgeElement = [CCSprite spriteWithSpriteFrameName:@"edgeElement0.png"];
            edgeElement.position = ccp(posX, posY);
            [self addChild:edgeElement];
            posX += edgeElement.contentSize.width;
            [upperEdgeElement addObject:edgeElement];
        }
        // left edge
        posX = -width;
        posY = -height+tester.contentSize.width/2;
        for (int i=0; i<9; i++) {
            CCSprite *edgeElement = [CCSprite spriteWithSpriteFrameName:@"edgeElement0.png"];
            edgeElement.rotation = 90;
            edgeElement.position = ccp(posX, posY);
            [self addChild:edgeElement];
            posY += edgeElement.contentSize.width;
            [leftEdgeElement addObject:edgeElement];
        }
        // right edge
        posX = width*2;
        posY = -height+tester.contentSize.width/2;
        for (int i=0; i<9; i++) {
            CCSprite *edgeElement = [CCSprite spriteWithSpriteFrameName:@"edgeElement0.png"];
            edgeElement.rotation = 90;
            edgeElement.position = ccp(posX, posY);
            [self addChild:edgeElement];
            posY += edgeElement.contentSize.width;
            [rightEdgeElement addObject:edgeElement];
        }
        
    }
    return self;
}

-(void) moveEdgeLayer:(CGPoint)velocity {
    velocity = ccpMult(velocity, 15);
    self.position = ccp(self.position.x-velocity.x, self.position.y-velocity.y);
}

-(void) setUpEdgeToDegree:(int)degree {
    for(CCSprite* edgeElement in upperEdgeElement) {
        NSString* frameName = [NSString stringWithFormat:@"edgeElement%i.png",degree];
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [edgeElement setDisplayFrame:frame];
    }
}

-(void) setBottomEdgeToDegree:(int)degree {
    for(CCSprite* edgeElement in bottomEdgeElement) {
        NSString* frameName = [NSString stringWithFormat:@"edgeElement%i.png",degree];
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [edgeElement setDisplayFrame:frame];
    }
}

-(void) setLeftEdgeToDegree:(int)degree {
    for(CCSprite* edgeElement in leftEdgeElement) {
        NSString* frameName = [NSString stringWithFormat:@"edgeElement%i.png",degree];
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [edgeElement setDisplayFrame:frame];
    }
}

-(void) setRightEdgeToDegree:(int)degree {
    for(CCSprite* edgeElement in rightEdgeElement) {
        NSString* frameName = [NSString stringWithFormat:@"edgeElement%i.png",degree];
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [edgeElement setDisplayFrame:frame];
    }
}

@end
