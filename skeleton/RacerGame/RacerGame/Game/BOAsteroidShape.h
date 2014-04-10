//
//  BOAsteroidShape.h
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOShape.h"

@interface BOAsteroidShape : BOShape

@property (readonly) GLfloat centerX;
@property (readonly) GLfloat centerY;
@property (readonly) GLfloat centerZ;

@property (readonly) NSArray *derivativeAsteroidShapes;

@end
