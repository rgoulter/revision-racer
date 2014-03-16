//
//  Shapes.m
//  AsteroidHelper
//
//  Created by Richard Goulter on 14/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "Shapes.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define PHI 1.618

typedef struct
{
    GLfloat *data;
    unsigned int numPoints;
} vertexdata;

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
static int gIcosahedronIndices[20 * 3] =
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
static GLfloat gIcosahedronVertexData[20 * 3 * 6];



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
static int gDodecahedronFaceIndices[12 * (5 + 1)] =
{
    14, 5, 9, 1, 12, -1, // top front
    12, 0, 8, 4, 14, -1, // top back
    12, 1, 17, 16, 0, -1, // top right
    14, 4, 18, 19, 5, -1, // top left.
    
    9, 5, 19, 7, 11, -1,  // front left
    11, 3, 17, 1, 9, -1,  // front right
    -1
};


static vertexdata *gDodecahedronVertexData = NULL;




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
        int idx1 = gIcosahedronIndices[face * 3 + 0];
        int idx2 = gIcosahedronIndices[face * 3 + 1];
        int idx3 = gIcosahedronIndices[face * 3 + 2];
        
        unsigned int faceOffset = face * 3 * 6;
        
        // Point 1's x,y,z
        isoData[faceOffset + 0] = gIcosahedronVertices[idx1 * 3 + 0];
        isoData[faceOffset + 1] = gIcosahedronVertices[idx1 * 3 + 1];
        isoData[faceOffset + 2] = gIcosahedronVertices[idx1 * 3 + 2];
        
        // Point 2's x,y,z
        isoData[faceOffset + 6 + 0] = gIcosahedronVertices[idx2 * 3 + 0];
        isoData[faceOffset + 6 + 1] = gIcosahedronVertices[idx2 * 3 + 1];
        isoData[faceOffset + 6 + 2] = gIcosahedronVertices[idx2 * 3 + 2];
        
        // Point 3's x,y,z
        isoData[faceOffset + 12 + 0] = gIcosahedronVertices[idx3 * 3 + 0];
        isoData[faceOffset + 12 + 1] = gIcosahedronVertices[idx3 * 3 + 1];
        isoData[faceOffset + 12 + 2] = gIcosahedronVertices[idx3 * 3 + 2];
        
        // Calculate the normal,
        // normal of the face will be the normal for each vertex.
        calcNormal(gIcosahedronVertices, idx1, idx2, idx3, isoData + faceOffset +  0 + 3);
        calcNormal(gIcosahedronVertices, idx1, idx2, idx3, isoData + faceOffset +  6 + 3);
        calcNormal(gIcosahedronVertices, idx1, idx2, idx3, isoData + faceOffset + 12 + 3);
    }
}


vertexdata* calculateVertexData(GLfloat vertices[], int indices[])
{
    // Indices array:
    // Each "polygon" is delimited by -1s.
    // Terminate when -1 followed by -1.
    
    // Construct vertex data into vertexData array by
    // mapping indices array to vertcies array,
    // and calculating the normal for each "face".
    
    
    // Seek how many points exist in the structure.
    int totalNumPoints = 5;
    int *currentFaceIndex = indices;
    
    while (currentFaceIndex[0] != -1) {
        // Seek how many points there are for this face.
        int numPoints = 0;
        while (currentFaceIndex[numPoints] != -1) {
            numPoints += 1;
        }
        
        // For a regular polygon with n points,
        // it can be triangulated with n - 2 triangles.
        int numTri = numPoints - 2;
        totalNumPoints += 3 * numTri;
        
        currentFaceIndex += numPoints + 1;
    }
    
    // malloc the vertex data.
    // Each point has {x, y, z, nx, ny, nz}
    GLfloat *vertexData = (GLfloat*) malloc(totalNumPoints * 6 * sizeof(GLfloat));
    
    
    currentFaceIndex = indices;
    GLfloat *currentVertexData = vertexData;
    
    while (currentFaceIndex[0] != -1) {
        // Seek how many points there are for this face.
        int numPoints = 0;
        while (currentFaceIndex[numPoints] != -1) {
            numPoints += 1;
        }
        
        // For a regular polygon with n points,
        // it can be triangulated with n - 2 triangles.
        int numTri = numPoints - 2;
        
        GLfloat *currentTriData = currentVertexData;
        for (int i = 0; i < numTri; i++) {
            // copy vertices 0, a, b
            int idx1 = currentFaceIndex[0];
            int idx2 = currentFaceIndex[i + 1];
            int idx3 = currentFaceIndex[i + 2];
            
            GLfloat x1 = vertices[idx1 * 3 + 0];
            GLfloat y1 = vertices[idx1 * 3 + 1];
            GLfloat z1 = vertices[idx1 * 3 + 2];
            
            currentTriData[0 * 6 + 0] = x1;
            currentTriData[0 * 6 + 1] = y1;
            currentTriData[0 * 6 + 2] = z1;
            
            GLfloat x2 = vertices[idx2 * 3 + 0];
            GLfloat y2 = vertices[idx2 * 3 + 1];
            GLfloat z2 = vertices[idx2 * 3 + 2];
            
            currentTriData[1 * 6 + 0] = x2;
            currentTriData[1 * 6 + 1] = y2;
            currentTriData[1 * 6 + 2] = z2;
            
            GLfloat x3 = vertices[idx3 * 3 + 0];
            GLfloat y3 = vertices[idx3 * 3 + 1];
            GLfloat z3 = vertices[idx3 * 3 + 2];
            
            currentTriData[2 * 6 + 0] = x3;
            currentTriData[2 * 6 + 1] = y3;
            currentTriData[2 * 6 + 2] = z3;

            // calculate normals for triangle
            GLfloat nml[3];
            calcNormal(vertices, idx3, idx2, idx1, nml);
            // TODO **** NOTE THAT THIS IS PROBABLY INCORRECT JUST NOW,
            // AND WE PROBABLY NEED TO REVERSE THE ABOVE INDICES.
            
            // copy normal data to triangle
            memcpy(currentTriData + 0 * 6 + 3, nml, 3 * sizeof(GLfloat));
            memcpy(currentTriData + 1 * 6 + 3, nml, 3 * sizeof(GLfloat));
            memcpy(currentTriData + 2 * 6 + 3, nml, 3 * sizeof(GLfloat));
            
            // advance tri data pointer
            currentTriData += 3 * 6;
        }
        
        
        // Advance pointers.
        currentVertexData = currentTriData; // Next output is where the last output finished.
        currentFaceIndex += numPoints + 1;  // each point idx + the -1
    }
    
    
    vertexdata *val = (vertexdata*) malloc(sizeof(vertexdata));
    val->data = vertexData;
    val->numPoints = totalNumPoints;
    return val;
}

void calculateDodecahedronData()
{
    if (gDodecahedronVertexData != NULL) {
        free(gDodecahedronVertexData);
    }
    
    gDodecahedronVertexData = calculateVertexData(gDodecahedronVertices, gDodecahedronFaceIndices);
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



@implementation BOIcosahedron {
    GLuint vertexBuffer;
}

- (void)setUp
{
    // Calculate vertex data
    calculateIsocahedonData(gIcosahedronVertexData);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gIcosahedronVertexData), gIcosahedronVertexData, GL_STATIC_DRAW);
    
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




@implementation BODodecahedron {
    GLuint vertexBuffer;
}

- (void)setUp
{
    // Calculate vertex data
    calculateDodecahedronData();
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    // populate buffer from our struct.
    int numBytes = sizeof(GLfloat) * 6 * gDodecahedronVertexData->numPoints;
    GLfloat *data = gDodecahedronVertexData->data;
    glBufferData(GL_ARRAY_BUFFER, numBytes, data, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
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
    glDrawArrays(GL_TRIANGLES, 0, gDodecahedronVertexData->numPoints);
}

@end