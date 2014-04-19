//
//  Asteroid.m
//  RacerGame
//
//  Created by Richard Goulter on 6/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "Asteroid.h"

@implementation Asteroid



- (id)initWithShape:(BOShape*)shape Path:(PathEffect*)path
{
    NSArray *effects = @[[[RotationEffect alloc] initWithRandomRotation]];
    
    self = [super initWithShape:shape
                           Path:path
                     andEffects:effects];
    
    if (self) {
        
    }
    
    return self;
}

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

- (void)draw:(void (^)(GLKMatrix4))modelViewMatCallback
{
    // Intercept draw-call from parent so we scale down the asteroid..
    // We can scale the object down by applying the scale matrix after the transformation
    [super draw:^(GLKMatrix4 mvMat) {
        GLfloat scale = 0.25;
        GLKMatrix4 lhsMat = GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, scale);
        
        modelViewMatCallback(GLKMatrix4Multiply(mvMat, lhsMat));
    }];
}

- (Asteroid*)createFromBOAsteroidShapePiece:(BOAsteroidShape*)tetShape
{
    // If the rotX/Y isn't considered, then prob'ly
    // the effect of the explosion will be quite strange.
    // TODO: Remove strangeness of explosion effect.
    
    BOShape *shape = tetShape;
    
    float k = 3;
    
    float dx = k * tetShape.centerX;
    float dy = k * tetShape.centerX;
    float dz = k * tetShape.centerX;
    
    // Here we depend on knowing current x, y, z of aster.
    // **MAGIC** duration
    float x = self.path.x;
    float y = self.path.y;
    float z = self.path.z;
    PathEffect *asteroidPath = [[PathEffect alloc]
                                initWithStartX:x Y:y Z:z
                                EndX:x + dx Y:y + dy Z:z + dz
                                Duration:1.5];
    
    Asteroid *asteroid = [[Asteroid alloc] initWithShape:shape Path:asteroidPath];
    
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
