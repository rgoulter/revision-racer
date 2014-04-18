//
//  BOSquarePyramid.h
//  RacerGame
//
//  Created by Richard Goulter on 18/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOShape.h"


static GLfloat gSquarePyramidVertices[5*3] =
{
    -1, -1, 0,
    +1, -1, 0,
    +1, +1, 0,
    -1, +1, 0,
    0, 0, +1
};


static int gSquarePyramidFaceIndices[4 * (3 + 1) + (4 + 1) + 1] =
{
    0, 1, 2, 3, -1,
    0, 1, 4, -1,
    1, 2, 4, -1,
    2, 3, 4, -1,
    3, 0, 4, -1,
    -1
};



@interface BOSquarePyramid : BOShape

@end
