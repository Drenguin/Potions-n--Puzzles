//
//  AppDelegate.h
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/11/12.
//  Copyright Drenguin 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, GKLeaderboardViewControllerDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

-(void)displayLeaderBoard:(NSString *)name;
@end
