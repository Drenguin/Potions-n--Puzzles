//
//  Singleton.m
//  UniPong
//
//  Created by Patrick Mc Gartoll on 11/16/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
@synthesize gameScore;

static Singleton* _sharedSingleton = nil;

+(Singleton*)sharedSingleton
{
	@synchronized([Singleton class])
	{
		if (!_sharedSingleton) {
			[[self alloc] init];
        }
        
		return _sharedSingleton;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([Singleton class])
	{
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		self.gameScore = 0;
	}
    
	return self;
}


@end
