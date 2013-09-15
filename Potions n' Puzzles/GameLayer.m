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
#import <GameKit/GameKit.h>
#import "GCHelper.h"
#import "AppDelegate.h"
#import "MainMenuLayer.h"

#define horOffset 50
#define vertOffset 130

float reloadTimer = 0.0f;
float reloadTime = 1.4f;
CCParticleSystemQuad *emitter;

static CGPoint applyVelocity(CGPoint velocity, CGPoint position, float delta){
	return CGPointMake(position.x + velocity.x * delta, position.y + velocity.y * delta);
}

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
        gamePaused = NO;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        score = 0;
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Courier New" fontSize:25.0f];
        scoreLabel.position = ccp(160.0f,450.0f);
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PNPSpriteSheet.plist"];
		grid = [[GameGrid alloc] init];
        
        switchyArrow = [CCSprite spriteWithSpriteFrameName:@"switchyarrow.png"];
        switchyArrow.position = ccp(horOffset+switchyArrow.boundingBox.size.width, vertOffset-switchyArrow.boundingBox.size.height);
        
        CCSprite *gridSprite = [CCSprite spriteWithFile:@"grid.png"];
        gridSprite.position = ccp(horOffset+gridSprite.boundingBox.size.width/2.0f-25,vertOffset+gridSprite.boundingBox.size.height/2.0f-25);
        
        touchPoint = ccp(horOffset+25,0);
        
        CCMenuItemImage *switchButton = [CCMenuItemImage itemFromNormalImage:@"switchButton.png" selectedImage:@"switchButton.png" block:^(id sender) {
            [grid flipRowsOne:arrowPos andTwo:arrowPos+1];
        }];
        switchButton.position = ccp(285,60);
        
        CCMenuItemImage *leftButton = [CCMenuItemImage itemFromNormalImage:@"leftMoveButton.png" selectedImage:@"leftMoveButton.png" block:^(id sender) {
            CGPoint new = touchPoint;
            new.x-=50;
            if(new.x>horOffset && new.x<([grid gridWidth]-1)*50.0f+horOffset) {
                touchPoint = new;
            }
        }];
        leftButton.position = ccp(horOffset+25,vertOffset-leftButton.boundingBox.size.height*2);
        
        CCMenuItemImage *rightButton = [CCMenuItemImage itemFromNormalImage:@"rightMoveButton.png" selectedImage:@"rightMoveButton.png" block:^(id sender) {
            CGPoint new = touchPoint;
            new.x+=50;
            if(new.x>horOffset && new.x<([grid gridWidth]-1)*50.0f+horOffset) {
                touchPoint = new;
            }
        }];
        rightButton.position = ccp(horOffset+rightButton.boundingBox.size.width+25,vertOffset-rightButton.boundingBox.size.height*2);
        
        /*CCMenuItemImage *pause = [CCMenuItemImage itemFromNormalImage:@"FILL" selectedImage:@"FILL" target:self selector:@selector(pauseGame)];*/
        //USE IS SELECTED TO DO STURFS
        
        CCSprite *bg = [CCSprite spriteWithFile:@"background0.2.PNG"];
        bg.position = ccp(winSize.width/2.0f, winSize.height/2.0f);
        
        CCMenu *buttonsMenu = [CCMenu menuWithItems:switchButton, leftButton, rightButton, nil];
        buttonsMenu.position = ccp(0,0);
        
        [self addChild:scoreLabel];
        [self addChild:switchyArrow];
        [self addChild:buttonsMenu];
        [self addChild:gridSprite z:-1];
        [self addChild:bg z:-2];
        
        [self initializeGrid];
        [self schedule:@selector(tick:) interval:1/60.0f];
	}
	return self;
}

-(void)tick:(ccTime)t
{
    if(!grid.gameOver && !gamePaused) {
        reloadTimer += t;
        if(reloadTimer>reloadTime) {
            if(reloadTime>0.1f) {
                reloadTime-=0.01f;
            }
            reloadTimer = 0.0f;
            [self performUpdateChanges:[grid update]];
        }
        [self displayGridToScreen:[grid getGrid]];
        for(int i = 0; i < [spritesGrid count]; i++) {
            for(int j = 0; j < [[spritesGrid objectAtIndex:0] count]; j++) {
                DRItemSprite *s = [[spritesGrid objectAtIndex:i] objectAtIndex:j];
                //Check to make this work later on for if statement: && (s.position.x!=s.moveToLoc.x) && (s.position.y!=s.moveToLoc.y)
                //ANIMATION
                 if (s.visible) {
                    CGPoint sub = ccpSub(s.moveToLoc, s.position);
                    s.position = applyVelocity(sub, s.position, 15.0f*t);
                }
            }
        }
        [self positionArrow:touchPoint withTime:t];
    }
}

-(void)pauseGame
{ gamePaused = YES; }

-(void)performUpdateChanges:(NSMutableArray *)inGrid
{
    for(int i = 0; i < grid.gridWidth; i++) {
        for(int j = 0; j < grid.gridHeight; j++) {
            GridItem *item = [[inGrid objectAtIndex:i] objectAtIndex:j];
            DRItemSprite *s = [self spriteIn:spritesGrid withTag:item.idNum];
            if(s.visible && !item.isActive) {
                [self createExplosionX:s.position.x y:s.position.y];
            }
        }
    }
    if(score!=grid.score) {
        [scoreLabel setString:[NSString stringWithFormat:@"%d",grid.score]];
        score = grid.score;
    }
}

-(void)displayGridToScreen:(NSMutableArray *)inGrid
{
    //Count through the array, make sure you do x first, then y's
    /*for(int i = [[inGrid objectAtIndex:0] count]-1; i >= 0; i--) {
        NSString *line = @"";
        //x
        for(int j = 0; j < [inGrid count]; j++) {
            GridItem *item = [[inGrid objectAtIndex:j] objectAtIndex:i];
            if(item.isActive)
                if(item.isFalling) {
                    line = [NSString stringWithFormat:@"%@ 1", line];
                } else {
                    line = [NSString stringWithFormat:@"%@ 0",line];
                }
            else 
                line = [NSString stringWithFormat:@"%@  ",line];
        }
        NSLog(@"%@",line);
    } */
    for(int i = 0; i < grid.gridWidth; i++) {
        for(int j = 0; j < grid.gridHeight; j++) {
            GridItem *item = [[inGrid objectAtIndex:i] objectAtIndex:j];
            DRItemSprite *s = [self spriteIn:spritesGrid withTag:item.idNum];
            if(s) {
                s.visible = item.isActive;
                if (s.pieceType != item.pieceType) {
                    [s setDisplayFrame:[self spriteFrameForPieceType:item.pieceType]];
                }
                //If the object is seen then do the cool movement animation, else, just put it in the position
                //ANIMATION
                if(s.visible && reloadTime>0.1f) {
                    s.moveToLoc = ccp(s.boundingBox.size.width*i+horOffset, s.boundingBox.size.height*j+vertOffset);
                }
                else {
                    s.position = ccp(s.boundingBox.size.width*i+horOffset, s.boundingBox.size.height*j+vertOffset);
                    s.moveToLoc = ccp(s.boundingBox.size.width*i+horOffset, s.boundingBox.size.height*j+vertOffset);
                }
            }
        }
    }
    if(grid.gameOver) {
        if([GKLocalPlayer localPlayer].authenticated) {
            [self reportScore:score forCategory:@"highscores"];
        }
    }
}

//Find the sprite in the array with the tag
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
            DRItemSprite *s  = [DRItemSprite spriteWithSpriteFrameName:@"sword.png"];
            s.tag = item.idNum;
            s.visible = item.isActive;
            s.pieceType = 0;
            s.position = ccp(s.boundingBox.size.width*i+horOffset, s.boundingBox.size.height*j+vertOffset);
            [self addChild:s];
            [[spritesGrid objectAtIndex:i] addObject:s];
        }
    }
}

-(CCSpriteFrame *)spriteFrameForPieceType:(int)pieceType
{
    switch (pieceType) {
        case 1:
            return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sword.png"];
            break;
        case 2:
            return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"shield.png"];
            break;
        case 3:
            return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"potion.png"];
            break;
        case 4:
            return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"pileocoins.png"];
            break;
        default:
            return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sword.png"];
            break;
    }
}

-(void)positionArrow:(CGPoint)p withTime:(ccTime)t
{
    int posNum = MIN(MAX((int)((touchPoint.x-horOffset)/50.0f), 0),3);
    arrowPos = posNum;
    CGPoint sub = ccpSub(ccp(posNum*50+horOffset+switchyArrow.boundingBox.size.width/4,switchyArrow.position.y), switchyArrow.position);
    switchyArrow.position = applyVelocity(sub, switchyArrow.position, 15.0f*t);
    //switchyArrow.position = ccp(posNum*50.0f + horOffset + switchyArrow.boundingBox.size.width/4,switchyArrow.position.y);
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for(UITouch *touch in touches) {
        CGPoint tP = [touch locationInView:[touch view]];
        
        /*if(tP.x>horOffset && tP.x<([grid gridWidth]-1)*50.0f+horOffset && (winSize.height-touchPoint.y)<100.0f) {
            touchPoint = tP;
        }
        if((winSize.height-touchPoint.y)>360.0f)
            reloadTime = 0.08f;
        if(winSize.height-tP.y>0 && winSize.height-tP.y<100 && tP.x<320 && tP.x>270) {
            [grid flipRowsOne:arrowPos andTwo:arrowPos+1];
        }*/
        /**else {
            int one = MIN(MAX((int)((touchPoint.x-horOffset)/50.0f), 0),3);
            int two = MIN(MAX((int)((touchPoint.x-horOffset+50.0f)/50.0f), 0),4);
            [grid flipRowsOne:one andTwo:two];
        }**/
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint tP = [touch locationInView:[touch view]];
        if(tP.x>horOffset && tP.x<[grid gridWidth]*50.0f+horOffset) {
            //touchPoint = [touch locationInView:[touch view]];
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint tP = [touch locationInView:[touch view]];
        reloadTime = 1.4f;
    }
}

-(void)createExplosionX:(float)x y:(float)y
{
    [emitter resetSystem];
    //	ParticleSystem *emitter = [RockExplosion node];
    emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:20];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"smoke.png"];
    
    // duration
    //	emitter.duration = -1; //continuous effect
    emitter.duration = 0.1;
    
    // gravity
    emitter.gravity = CGPointZero;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // speed of particles
    emitter.speed = 80;
    emitter.speedVar = 20;
    
    // radial
    emitter.radialAccel = -100;
    emitter.radialAccelVar = 0;
    
    // tangential
    emitter.tangentialAccel = 10;
    emitter.tangentialAccelVar = 0;
    
    // life of particles
    emitter.life = 0.7;
    emitter.lifeVar = 0.2;
    
    // spin of particles
    emitter.startSpin = 0;
    emitter.startSpinVar = 0;
    emitter.endSpin = 0;
    emitter.endSpinVar = 0;
    
    // color of particles
    ccColor4F startColor = {139/255.0f, 137/255.0f, 137/255.0f, 1.0f};
    emitter.startColor = startColor;
    ccColor4F startColorVar = {0, 0, 0, 1.0f};
    emitter.startColorVar = startColorVar;
    ccColor4F endColor = {139/255.0f, 137/255.0f, 137/255.0f, 0.0f};
    emitter.endColor = endColor;
    ccColor4F endColorVar = {0, 0, 0, 0.0f};
    emitter.endColorVar = endColorVar;
    
    // size, in pixels
    emitter.startSize = 25.0f;
    emitter.startSizeVar = 5.0f;
    emitter.endSize = kParticleStartSizeEqualToEndSize;
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.life;
    // additive
    emitter.blendAdditive = YES;
    emitter.position = ccp(x,y); // setting emitter position
    [self addChild: emitter z:10]; // adding the emitter
    emitter.autoRemoveOnFinish = YES; // this removes/deallocs the emitter after its animation
}

-(void)reportScore:(int)aScore forCategory:(NSString*)category
{
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = aScore;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
            NSLog(@"error: %@", error);
        }
    }];
    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [switchyArrow release];
    [grid release];
    [spritesGrid release];
    [scoreLabel release];
    
	[super dealloc];
}
@end
