//
//  HelloWorldLayer.m
//  study_Scrolllayer
//
//  Created by lee living on 11-2-24.
//  Copyright LieHuo Tech 2011. All rights reserved.
//

// Import the interfaces
#import "ThemeScene.h"
#import "CCBReader.h"
#import "LoadingScene.h"

// HelloWorld implementation
@implementation ThemeScene

static MainGameParameters *params;

+(id) sceneWithParameters:(MainGameParameters *)parameters
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ThemeScene *layer = [[ThemeScene alloc] initWithParameters:parameters];
	
	// add layer as a child to scene
	[scene addChild: layer ];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) initWithParameters:(MainGameParameters*)parameters
{
    self = [super init];
    if (self) {
        
    params = parameters;
	scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];//srollview as ipad
    scrollview.pagingEnabled =  YES;//to subview's border
    scrollview.contentSize = CGSizeMake(1024*2, 768);//set scrollview sliding range, three UI, so 1024*3
    scrollview.alwaysBounceHorizontal = YES;
        
    //add 3 buttons to scrollview
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(0, 0, 1024, 768);
    [button1 setBackgroundImage:[UIImage imageNamed:@"selectScene3.png"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(changeToScene3) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:button1];
     
            
   
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5.frame = CGRectMake(1024, 0, 1024, 768);
    [button5 setBackgroundImage:[UIImage imageNamed:@"selectScene1.png"] forState:UIControlStateNormal];
    [button5 addTarget:self action:@selector(changeToScene1) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:button5];
    
/*
    UIButton *button9 = [UIButton buttonWithType:UIButtonTypeCustom];
    button9.frame = CGRectMake(2339, 206, 100, 100);
    [button9 setBackgroundImage:[UIImage imageNamed:@"Icon.png"] forState:UIControlStateNormal];
    [button9 addTarget:self action:@selector(menu) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:button9];
*/    


    
    [[[CCDirector sharedDirector] view] addSubview:scrollview];
/*
    //little point for seperating pages
    pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(385, 700, 100, 50)];
    //pagecontrol.hidesForSinglePage = YES;
    //pagecontrol.userInteractionEnabled = NO;
    pagecontrol.numberOfPages = 2;// three pages
    
    [[[CCDirector sharedDirector] view] addSubview:pagecontrol];
*/
        scrollview.delegate = self;
    }
    return self;
}

-(void)changeToScene3 {
    params.backgroundNo = 3;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LoadingScene sceneWithParameters:params]]];
}

-(void)changeToScene1 {
    params.backgroundNo = 1;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LoadingScene sceneWithParameters:params]]];
}

-(void)menu
{
    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithParameters:params]];
    NSLog(@"button pressed\n");
}

-(void) gameScene1 {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LoadingScene sceneWithParameters:params]]];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    NSLog(@"%d",index);
    pagecontrol.currentPage = index;
}

-(void) dealloc {
    [scrollview removeFromSuperview];
    [pagecontrol removeFromSuperview];
    return;
}

@end
