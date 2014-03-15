//
//  Shapes.m
//  AsteroidHelper
//
//  Created by Richard Goulter on 14/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "Shapes.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

static GLfloat gCubeVertexData[216] =
{
    //x     y      z              nx     ny     nz
    1.0f, -1.0f, -1.0f,         1.0f,  0.0f,  0.0f,
    1.0f,  1.0f, -1.0f,         1.0f,  0.0f,  0.0f,
    1.0f, -1.0f,  1.0f,         1.0f,  0.0f,  0.0f,
    1.0f, -1.0f,  1.0f,         1.0f,  0.0f,  0.0f,
    1.0f,  1.0f,  1.0f,         1.0f,  0.0f,  0.0f,
    1.0f,  1.0f, -1.0f,         1.0f,  0.0f,  0.0f,
    
    1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,
    -1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,
    1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,
    1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,
    -1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,
    -1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,
    
    -1.0f,  1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f, -1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f,  1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f,  1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f, -1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f, -1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,
    
    -1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,
    1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,
    -1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,
    -1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,
    1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,
    1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,
    
    1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    -1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    
    1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f
};


// Icosahedron vertices. (12 points)
// Defined by:
// (      0,   +/- 1, +/- phi)
// (  +/- 1, +/- phi,       0)
// (+/- phi,       0,   +/- 1)
#define PHI 1.618

/**
static GLfloat gIsocahedronVertices[12*3] =
{
    0, +1, +PHI,
    0, +1, -PHI,
    0, -1, +PHI,
    0, -1, -PHI,
    
    +1, +PHI, 0,
    +1, -PHI, 0,
    -1, +PHI, 0,
    -1, -PHI, 0,
    
    +PHI, 0, +1,
    -PHI, 0, +1,
    +PHI, 0, -1,
    -PHI, 0, -1
};
 */

static GLfloat gIsocahedronVertices[12*3] =
{
    -1, +PHI, 0, // 0
    +1, +PHI, 0, // 1
    -1, -PHI, 0, // 2
    +1, -PHI, 0, // 3
    
    0, +1, +PHI, // 4
    0, -1, +PHI, // 5
    0, +1, -PHI, // 6
    0, -1, -PHI, // 7
    
    +PHI, 0, +1, // 8
    -PHI, 0, +1, // 9
    +PHI, 0, -1, // 10
    -PHI, 0, -1  // 11
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
static GLushort gIsocahedronIndices[20 * 3] =
{
    // rearranged these while debugging.
    1, 0, 4,
    1, 4, 8,
    4, 5, 8,
    5, 4, 9,
    4, 0, 9,
    0, 1, 6,
    0, 6, 11,
    1, 8, 10,
    2, 3, 5,
    2, 5, 9,
    2, 9, 11,
    3, 2, 7,
    3, 7, 10,
    5, 3, 8,
    6, 1, 10,
    6, 7, 11,
    7, 6, 10,
    7, 2, 11,
    8, 3, 10,
    9, 0, 11
};

// 20 faces,
// each face is 3 points,
// each point is {x, y, z, nx, ny, nz};
static GLfloat gIsocahedronVertexData[20 * 3 * 6];

// let pt1, 2, 3 be 3 pts of a triangle or polygon...
// normal is cp of 1->2 X 2->3
void calcNormal(GLfloat data[], unsigned int ptIdx1, unsigned int ptIdx2,  unsigned int ptIdx3, GLfloat output[])
{
    // u = 1->2
    GLfloat u1 = data[ptIdx2 * 3 + 0] - data[ptIdx1 * 3 + 0];
    GLfloat u2 = data[ptIdx2 * 3 + 1] - data[ptIdx1 * 3 + 1];
    GLfloat u3 = data[ptIdx2 * 3 + 2] - data[ptIdx1 * 3 + 2];
    
    // v = 2->3
    GLfloat v1 = data[ptIdx3 * 3 + 0] - data[ptIdx2 * 3 + 0];
    GLfloat v2 = data[ptIdx3 * 3 + 1] - data[ptIdx2 * 3 + 1];
    GLfloat v3 = data[ptIdx3 * 3 + 2] - data[ptIdx2 * 3 + 2];
    
    // Cross-Product
    // cf. Wikipedia
    // http://en.wikipedia.org/wiki/Cross_product#Matrix_notation
    
    GLfloat nx = u2 * v3 - u3 * v2;
    GLfloat ny = -(u1 * v3 - u3 * v1);
    GLfloat nz = u1 * v2 - u2 * v1;
    
    GLfloat len = sqrtf(nx * nx + ny * ny + nz * nz);
    
    output[0] = nx / len;
    output[1] = ny / len;
    output[2] = nz / len;
}

void calculateIsocahedonData(GLfloat isoData[20 * 6])
{
    int numFaces = 20;
    
    // for each face ...
    for (int face = 0; face < numFaces; face++) {
        int idx1 = gIsocahedronIndices[face * 3 + 0];
        int idx2 = gIsocahedronIndices[face * 3 + 1];
        int idx3 = gIsocahedronIndices[face * 3 + 2];
        
        unsigned int faceOffset = face * 3 * 6;
        
        // Point 1's x,y,z
        isoData[faceOffset + 0] = gIsocahedronVertices[idx1 * 3 + 0];
        isoData[faceOffset + 1] = gIsocahedronVertices[idx1 * 3 + 1];
        isoData[faceOffset + 2] = gIsocahedronVertices[idx1 * 3 + 2];
        
        // Point 2's x,y,z
        isoData[faceOffset + 6 + 0] = gIsocahedronVertices[idx2 * 3 + 0];
        isoData[faceOffset + 6 + 1] = gIsocahedronVertices[idx2 * 3 + 1];
        isoData[faceOffset + 6 + 2] = gIsocahedronVertices[idx2 * 3 + 2];
        
        // Point 3's x,y,z
        isoData[faceOffset + 12 + 0] = gIsocahedronVertices[idx3 * 3 + 0];
        isoData[faceOffset + 12 + 1] = gIsocahedronVertices[idx3 * 3 + 1];
        isoData[faceOffset + 12 + 2] = gIsocahedronVertices[idx3 * 3 + 2];
        
        // Calculate the normal,
        // normal of the face will be the normal for each vertex.
        calcNormal(gIsocahedronVertices, idx1, idx2, idx3, isoData + faceOffset +  0 + 3);
        calcNormal(gIsocahedronVertices, idx1, idx2, idx3, isoData + faceOffset +  6 + 3);
        calcNormal(gIsocahedronVertices, idx1, idx2, idx3, isoData + faceOffset + 12 + 3);
        
        if (face < 5) {
            float nx = isoData[faceOffset + 3 + 0];
            float ny = isoData[faceOffset + 3 + 1];
            float nz = isoData[faceOffset + 3 + 2];
            NSLog(@"Row %d normal: %f, %f, %f", face, nx, ny, nz);
        }
    }
}



@implementation BOShape

- (void)setUp {}
- (void)tearDown {}
- (void)draw {}

@end

@implementation BOCube {
    GLuint vertexBuffer;
}

- (void)setUp
{
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
}

- (void)tearDown
{
    glDeleteBuffers(1, &vertexBuffer);
}

- (void)draw
{
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end

@implementation BOIsocahedron {
    GLuint vertexBuffer;
}

- (void)setUp
{
    // Calculate vertex data
    calculateIsocahedonData(gIsocahedronVertexData);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gIsocahedronVertexData), gIsocahedronVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    // we need the *4 since each GLfloat is 4-bytes.
    // ergo, "stride" of 6*4 is because 4*{x,y,z,nx,ny,nz}.
    // (Same for buffer offset).
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 6 * 4, BUFFER_OFFSET(0 * 4));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 6 * 4, BUFFER_OFFSET(3 * 4));
}

- (void)tearDown
{
    glDeleteBuffers(1, &vertexBuffer);
}

- (void)draw
{
    glDrawArrays(GL_TRIANGLES, 0, 20 * 3);
}

@end
