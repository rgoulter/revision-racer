//
//  Asteroid.m
//  RacerGame
//
//  Created by Richard Goulter on 6/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "Asteroid.h"

@implementation Asteroid

- (void)setUp
{
    NSLog(@"Asteroid setup");
    assert([self.shape isKindOfClass:[BOAsteroidShape class]]);
    
    [super setUp];
    [self.shape setUp];
}

- (void)tearDown
{
    NSLog(@"Asteroid teardown");
    assert([self.shape isKindOfClass:[BOAsteroidShape class]]);
    
    [self.shape tearDown];
    [super tearDown];
}

@end
