//
//  GameEdgeLayer.h
//  Galaxy_Escape
//
//  Created by Tony on 3/4/13.
//  Copyright 2013 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameEdgeLayer : CCLayer {
    
}

-(void) moveEdgeLayer:(CGPoint)velocity;

-(void) setUpEdgeToDegree:(int)degree;
-(void) setBottomEdgeToDegree:(int)degree;
-(void) setLeftEdgeToDegree:(int)degree;
-(void) setRightEdgeToDegree:(int)degree;
@end
