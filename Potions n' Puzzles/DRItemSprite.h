//
//  DRItemSprite.h
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/14/12.
//  Copyright 2012 Drenguin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DRItemSprite : CCSprite {
    
}
@property (nonatomic, assign) int pieceType;
@property (nonatomic, assign) CGPoint moveToLoc;

@end
