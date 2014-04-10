//
//  BODodecahedron.h
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOShape.h"



// Dodecehedron vertices. (20 points)
// Defined by:
// (    +/- 1,     +/- 1,     +/- 1)
// (        0, +/- 1/PHI,   +/- PHI)
// (+/- 1/PHI,   +/- PHI,         0)
// (  +/- PHI,         0, +/- 1/PHI)

static GLfloat gDodecahedronVertices[20*3] =
{
    +1, +1, +1, // 0
    +1, +1, -1,
    +1, -1, +1,
    +1, -1, -1, // 3
    -1, +1, +1,
    -1, +1, -1,
    -1, -1, +1, // 6
    -1, -1, -1, //7
    
    0, +1/PHI, +PHI, // 8
    0, +1/PHI, -PHI,
    0, -1/PHI, +PHI, // 10
    0, -1/PHI, -PHI,
    
    +1/PHI, +PHI, 0, // 12
    +1/PHI, -PHI, 0,
    -1/PHI, +PHI, 0, // 14
    -1/PHI, -PHI, 0,
    
    +PHI, 0, +1/PHI, // 16
    +PHI, 0, -1/PHI,
    -PHI, 0, +1/PHI, // 18
    -PHI, 0, -1/PHI
};



// Faces are indices separated by -1.
// each Dodecahedron face has 5 vertices;
// each Dodecahedron has 12 faces.
// specified in CCW order.
static int gDodecahedronFaceIndices[12 * (5 + 1) + 1] =
{
    12, 1, 9, 5, 14, -1,
    14, 4, 8, 0, 12, -1,
    0, 16, 17, 1, 12, -1,
    5, 19, 18, 4, 14, -1,
    
    11, 7, 19, 5, 9, -1,
    9, 1, 17, 3, 11, -1,
    8, 4, 18, 6, 10, -1,
    10, 2, 16, 0, 8, -1,
    
    15, 7, 11, 3, 13, -1,
    13, 2, 10, 6, 15, -1,
    15, 6, 18, 19, 7, -1,
    3, 17, 16, 2, 13, -1,
    
    -1
};



@interface BODodecahedron : BOShape

@end
