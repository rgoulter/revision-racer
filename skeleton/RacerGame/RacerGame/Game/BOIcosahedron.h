//
//  BOIcosahedron.h
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOShape.h"



// Icosahedron vertices. (12 points)
// Defined by:
// (      0,   +/- 1, +/- phi)
// (  +/- 1, +/- phi,       0)
// (+/- phi,       0,   +/- 1)

static GLfloat gIcosahedronVertices[12*3] =
{
    -1, +PHI, 0,
    +1, +PHI, 0,
    -1, -PHI, 0,
    +1, -PHI, 0,
    
    0, +1, +PHI,
    0, -1, +PHI,
    0, +1, -PHI,
    0, -1, -PHI,
    
    +PHI, 0, +1,
    -PHI, 0, +1,
    +PHI, 0, -1,
    -PHI, 0, -1
};



// Indices of the vertices for the faces. (20 faces)
// 5 triangles on top,
// 10 triangles around centre,
// 5 triangles on bottom.
//
// Also note that the below is fucked up,
// because the vertices themselves are in order,
// and I don't know shit about where the vertices should be..

// cf. http://rbwhitaker.wikidot.com/index-and-vertex-buffers
// (but they use diff coords..)
static int gIcosahedronFaceIndices[20 * (3 + 1) + 1] =
{
    1, 0, 4, -1,
    1, 4, 8, -1,
    4, 5, 8, -1,
    5, 4, 9, -1,
    4, 0, 9, -1,
    0, 1, 6, -1,
    0, 6, 11, -1,
    1, 8, 10, -1,
    2, 3, 5, -1,
    2, 5, 9, -1,
    2, 9, 11, -1,
    3, 2, 7, -1,
    3, 7, 10, -1,
    5, 3, 8, -1,
    6, 1, 10, -1,
    6, 7, 11, -1,
    7, 6, 10, -1,
    7, 2, 11, -1,
    8, 3, 10, -1,
    9, 0, 11, -1,
    -1
};



@interface BOIcosahedron : BOShape

@end
