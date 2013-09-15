//
//  GameGrid.m
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/11/12.
//  Copyright (c) 2012 Drenguin. All rights reserved.
//

#import "GameGrid.h"



@implementation GameGrid
@synthesize gridHeight, gridWidth, numOfItems, gameOver, score;

static BOOL isValid(int x, int y, int gridWidth, int gridHeight) {
	return (x>=0 && x<gridWidth && y>=0 && y<gridHeight);
}

-(id)init
{
    //Counter to set the id's of the items
    self.gridWidth = 4;
    self.gridHeight = 6;
    self.numOfItems = 4;
    self.score = 0;
    int idCount = 0;
    gameOver = NO;
    grid = [[NSMutableArray alloc] initWithObjects:nil];
    for (int i = 0; i<self.gridWidth; i++) {
        [grid addObject:[[NSMutableArray alloc] initWithObjects:nil]];
        for(int j = 0; j < self.gridHeight;j++) {
            GridItem *item = [[GridItem alloc] init];
            item.isActive = NO;
            item.pieceType = 1;
            //Set the idNum then add 1 to idCount
            item.idNum = idCount++;
            [[grid objectAtIndex:i] addObject:item];
        }
    }
    return self;
}

-(NSMutableArray *)update
{
    NSMutableArray *newGrid = grid;
    BOOL hasChanged = NO;
    //loop through grid
    for (int i = 0; i<self.gridWidth; i++) {
        for(int j = 0; j < self.gridHeight;j++) {
            GridItem *item = [[newGrid objectAtIndex:i] objectAtIndex:j];
            if (item.isActive && isValid(i,j-1, self.gridWidth, self.gridHeight)) {
                GridItem *itemDown = [[newGrid objectAtIndex:i] objectAtIndex:j-1];
                if(!itemDown.isActive) {
                    [[newGrid objectAtIndex:i] replaceObjectAtIndex:j-1 withObject:item];
                    [[newGrid objectAtIndex:i] replaceObjectAtIndex:j withObject:itemDown];
                    hasChanged = YES;
                } else {
                    //Reset the items
                    if(itemDown.pieceType == item.pieceType) {
                        item.isActive = NO;
                        itemDown.isActive = NO;
                        score+=50;
                    } else if(j==gridHeight-1) {
                        gameOver = YES;
                        return grid;
                    } else {
                        item.isFalling = NO;
                    }
                }
            }
            //If the y value is 0 then you know the item isn't falling
            if(item.isActive && j==0) 
                item.isFalling = NO;
        }
    }
    if(!hasChanged) {
        [self dropGridItems];
    }
    grid = newGrid;
    return newGrid;
}

-(void)dropGridItems
{
    int pos1 = arc4random()%(self.gridWidth);
    int pos2 = arc4random()%(self.gridWidth);
    //make sure 2nd position is different than first
    while(pos1==pos2) { pos2 = arc4random()%(gridWidth-1); }
    GridItem *item1 = [[grid objectAtIndex:pos1] objectAtIndex:self.gridHeight-1];
    GridItem *item2 = [[grid objectAtIndex:pos2] objectAtIndex:self.gridHeight-1];
    
    item1.isActive = YES;
    item1.isFalling = YES;
    item1.pieceType = (arc4random()%(numOfItems))+1;
    item2.isActive = YES;
    item2.isFalling = YES;
    item2.pieceType = (arc4random()%(numOfItems))+1;
}

-(void)flipRowsOne:(int)one andTwo:(int)two
{
    int height = gridHeight;
    for(int i = 0; i < height; i++) {
        GridItem *oneItem = [[grid objectAtIndex:one] objectAtIndex:i];
        GridItem *twoItem = [[grid objectAtIndex:two] objectAtIndex:i];
        if((!oneItem.isFalling && oneItem.isActive) || (!twoItem.isFalling && twoItem.isActive)) {
            [[grid objectAtIndex:one] replaceObjectAtIndex:i withObject:twoItem];
            [[grid objectAtIndex:two] replaceObjectAtIndex:i withObject:oneItem];
        } else {
            height = -1;
        }
    }
}

-(NSMutableArray *)getGrid
{
    return grid;
}

-(void)dealloc
{
    [super dealloc];
    [grid removeAllObjects];
    [grid release];
}

@end
