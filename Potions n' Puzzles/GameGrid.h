//
//  GameGrid.h
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/11/12.
//  Copyright (c) 2012 Drenguin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridItem.h"

@interface GameGrid : NSObject {
    NSMutableArray *grid;
}

@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) int gridWidth;
@property (nonatomic, assign) int gridHeight;
@property (nonatomic, assign) int numOfItems;
@property (nonatomic, assign) int score;

-(id)init;
-(NSMutableArray *)update;
-(void)dropGridItems;
-(NSMutableArray *)getGrid;
-(void)flipRowsOne:(int)one andTwo:(int)two;
@end
