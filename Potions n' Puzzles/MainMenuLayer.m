//
//  MainMenuLayer.m
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/20/12.
//  Copyright 2012 Drenguin. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "AppDelegate.h"

@implementation MainMenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCMenuItemFont *play = [CCMenuItemFont itemFromString:@"Play Game" block:^(id input){
            [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
        }];
        CCMenuItemFont *highScores = [CCMenuItemFont itemFromString:@"High Scores" block:^(id input){
            id appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate displayLeaderBoard:@"highscores"];
        }];
        CCMenu *mainMenu = [CCMenu menuWithItems:play, highScores ,nil];
        [mainMenu alignItemsVerticallyWithPadding:2.0f];
        mainMenu.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:mainMenu];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"background0.2.PNG"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:bg z:-1];
    }
    return self;
}

@end
