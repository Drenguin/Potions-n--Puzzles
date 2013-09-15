//
//  GameLayer.h
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/11/12.
//  Copyright Drenguin 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameGrid.h"
#import "DRItemSprite.h"

// GameLayer
@interface GameLayer : CCLayer
{
    CCSprite *switchyArrow;
    int arrowPos;
    GameGrid *grid;
    NSMutableArray *spritesGrid;
    int score;
    CCLabelTTF *scoreLabel;
    CGPoint touchPoint;
    BOOL gamePaused;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)performUpdateChanges:(NSMutableArray *)inGrid;
-(void)displayGridToScreen:(NSMutableArray *)inGrid;
-(void)initializeGrid;
-(DRItemSprite *)spriteIn:(NSMutableArray *)g withTag:(int)t;
-(CCSpriteFrame *)spriteFrameForPieceType:(int)pieceType;
-(void)createExplosionX:(float)x y:(float)y;
-(void)reportScore:(int)aScore forCategory:(NSString*)category;
-(void)positionArrow:(CGPoint)p withTime:(ccTime)t;
@end
