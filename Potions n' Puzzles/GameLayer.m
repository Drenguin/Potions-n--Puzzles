//
//  GameLayer.m
//  Potions n' Puzzles
//
//  Created by Patrick Mc Gartoll on 3/11/12.
//  Copyright Drenguin 2012. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "DRItemSprite.h"

#define horOffset 60
#define vertOffset 60

float reloadTimer = 0.0f;
float reloadTime = 0.6f;

// HelloWorldLayer implementation
@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        self.isTouchEnabled = YES;
        
		grid = [[GameGrid alloc] init];
        [self initializeGrid];
        [self schedule:@selector(tick:) interval:1/30.0f];
	}
	return self;
}

-(void)tick:(ccTime)t
{
    reloadTimer += t;
    if(reloadTimer>reloadTime) {
        reloadTimer = 0.0f;
        [self displayGridToScreen:[grid update]];
    }
}

-(void)displayGridToScreen:(NSMutableArray *)inGrid
{
    //Count through the array, make sure you do x first, then y's
    for(int i = [[inGrid objectAtIndex:0] count]-1; i >= 0; i--) {
        NSString *line = @"";
        //x
        for(int j = 0; j < [inGrid count]; j++) {
            GridItem *item = [[inGrid objectAtIndex:j] objectAtIndex:i];
            if(item.isActive)
                line = [NSString stringWithFormat:@"%@ %d",line,item.pieceType];
            else 
                line = [NSString stringWithFormat:@"%@  ",line];
        }
        NSLog(@"%@",line);
    }
    NSLog(@" ");
    for(int i = 0; i < grid.gridWidth; i++) {
        for(int j = 0; j < grid.gridHeight; j++) {
            GridItem *item = [[inGrid objectAtIndex:i] objectAtIndex:j];
            DRItemSprite *s = [self spriteIn:spritesGrid withTag:item.idNum];
            s.visible = item.isActive;
            if (s.pieceType != item.pieceType) {
                [s setTexture:[self textureForPieceType:(item.pieceType)]];
            }
            if(s) {
                s.position = ccp(s.boundingBox.size.width*i+horOffset, s.boundingBox.size.height*j+vertOffset);
            }
        }
    }
}
                           
-(DRItemSprite *)spriteIn:(NSMutableArray *)g withTag:(int)t
{
    for(int i = 0; i < [g count]; i++) {
        for(int j = 0; j < [[g objectAtIndex:0] count]; j++) {
            if([[[g objectAtIndex:i] objectAtIndex:j] tag] == t) {
                return [[g objectAtIndex:i] objectAtIndex:j];
            }
        }
    }
    return nil;
}

-(void)initializeGrid
{
    NSMutableArray *textGrid = [grid getGrid];
    spritesGrid = [[NSMutableArray alloc] initWithObjects:nil];
    for(int i = 0; i < grid.gridWidth; i++) {
        [spritesGrid addObject:[[NSMutableArray alloc] initWithObjects: nil]];
        for(int j = 0; j < grid.gridHeight; j++) {
            GridItem *item = [[textGrid objectAtIndex:i] objectAtIndex:j];
            DRItemSprite *s  = [DRItemSprite spriteWithFile:@"sword.png"];
            s.tag = item.idNum;
            s.visible = item.isActive;
            s.pieceType = 0;
            s.position = ccp(s.boundingBox.size.width*i+horOffset, s.boundingBox.size.height*j+vertOffset);
            [self addChild:s];
            [[spritesGrid objectAtIndex:i] addObject:s];
        }
    }
}

-(CCTexture2D *)textureForPieceType:(int)pieceType
{
    switch (pieceType) {
        case 1:
            return [[CCTextureCache sharedTextureCache] addImage:@"sword.png"];
            break;
        case 2:
            return [[CCTextureCache sharedTextureCache] addImage:@"shield.png"];
            break;
        case 3:
            return [[CCTextureCache sharedTextureCache] addImage:@"potion.png"];
            break;
        case 4:
            return [[CCTextureCache sharedTextureCache] addImage:@"pileocoins.png"];
            break;
        default:
            return [[CCTextureCache sharedTextureCache] addImage:@"sword.png"];
            break;
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
