//
//  Singleton.h
//  UniPong
//
//  Created by Patrick Mc Gartoll on 11/16/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject {
    
}
@property (assign) int gameScore;

+(Singleton*)sharedSingleton;
@end