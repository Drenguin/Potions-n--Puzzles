//
//  GridItem.h
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/11/12.
//  Copyright (c) 2012 Drenguin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridItem : NSObject {
    
}
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) int pieceType;
@property (nonatomic, assign) int idNum;
@property (nonatomic, assign) BOOL isFalling;

@end
