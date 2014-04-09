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
    assert([self.shape isKindOfClass:[BOAsteroidShape class]]);
    
    [super setUp];
}

- (void)tearDown
{
    assert([self.shape isKindOfClass:[BOAsteroidShape class]]);
    
    [super tearDown];
}

- (Asteroid*)createFromBOAsteroidShapePiece:(BOAsteroidShape*)tetShape
{
    // If the rotX/Y isn't considered, then prob'ly
    // the effect of the explosion will be quite strange.
    // TODO: Remove strangeness of explosion effect.
    
    Asteroid *asteroid = [[Asteroid alloc] init];
    asteroid.shape = tetShape;
    
    float k = 3;
    
    float dx = k * tetShape.centerX;
    float dy = k * tetShape.centerX;
    float dz = k * tetShape.centerX;
    
    // Here we depend on knowing current x, y, z of aster.
    [asteroid setStartPositionX:self.x Y:self.y Z:self.z];
    [asteroid setEndPositionX:self.x + dx Y:self.y + dy Z:self.z + dz];
    
    asteroid.duration = 1.5; // **MAGIC**
    
    // Setup the asteroid. Maybe bad **DESIGN**
    [asteroid setUp];
    
    return asteroid;
}

- (NSArray*)debrisPieces
{
    NSMutableArray *result = [NSMutableArray array];
    
    BOAsteroidShape *parentShape = (BOAsteroidShape*)self.shape;
    
    for (BOAsteroidShape *asterShape in parentShape.derivativeAsteroidShapes) {
        [result addObject:[self createFromBOAsteroidShapePiece:asterShape]];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
