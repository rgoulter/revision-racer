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

#define VBO_NUMCOLS 6

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

// 20 faces,
// each face is 3 points,
// each point is {x, y, z, nx, ny, nz};
static vertexdata *gIcosahedronVertexData;



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


static vertexdata *gDodecahedronVertexData = NULL;




void cpyPoint(GLfloat vertexArray[], unsigned int idx, GLfloat output[])
{
    // vertexArray = {x0, y0, z0, x1, y1, z1, ...}
    GLfloat x = vertexArray[idx * 3 + 0];
    GLfloat y = vertexArray[idx * 3 + 1];
    GLfloat z = vertexArray[idx * 3 + 2];
    
    output[0] = x;
    output[1] = y;
    output[2] = z;
}



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
        
        currentFaceIndex += numPoints + 1; // each point idx + the -1
    }
    
    // malloc the vertex data.
    // Each point has {x, y, z, nx, ny, nz}
    GLfloat *vertexData = (GLfloat*) malloc(totalNumPoints * VBO_NUMCOLS * sizeof(GLfloat));
    
    
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
            
            cpyPoint(vertices, idx1, currentTriData + 0 * VBO_NUMCOLS);
            cpyPoint(vertices, idx2, currentTriData + 1 * VBO_NUMCOLS);
            cpyPoint(vertices, idx3, currentTriData + 2 * VBO_NUMCOLS);

            // calculate normals for triangle
            GLfloat nml[3];
            calcNormal(vertices, idx1, idx2, idx3, nml);
            
            // copy normal data to triangle
            memcpy(currentTriData + 0 * VBO_NUMCOLS + 3, nml, 3 * sizeof(GLfloat));
            memcpy(currentTriData + 1 * VBO_NUMCOLS + 3, nml, 3 * sizeof(GLfloat));
            memcpy(currentTriData + 2 * VBO_NUMCOLS + 3, nml, 3 * sizeof(GLfloat));
            
            // advance tri data pointer
            currentTriData += 3 * VBO_NUMCOLS;
        }
        
        
        // Advance pointers.
        currentVertexData = currentTriData; // Next output is where the last output finished.
        currentFaceIndex += numPoints + 1;  // each point idx + the -1
    }
    
    
    vertexdata *vd = (vertexdata*) malloc(sizeof(vertexdata));
    vd->data = vertexData;
    vd->numPoints = totalNumPoints;
    
    return vd;
}



void calculateIcosahedonData()
{
    if (gIcosahedronVertexData != NULL) {
        free(gIcosahedronVertexData);
    }
    
    gIcosahedronVertexData = calculateVertexData(gIcosahedronVertices, gIcosahedronFaceIndices);
}



void calculateDodecahedronData()
{
    if (gDodecahedronVertexData != NULL) {
        free(gDodecahedronVertexData);
    }
    
    gDodecahedronVertexData = calculateVertexData(gDodecahedronVertices, gDodecahedronFaceIndices);
}



@implementation BOShape {
    GLuint vertexBuffer;
    GLfloat *_vertexData;
    unsigned int _numPoints;
}

- (void)setVertexData:(GLfloat *)data withNumPoints:(unsigned int)n
{
    _vertexData = data;
    _numPoints = n;
}

- (void)setUp {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * VBO_NUMCOLS * _numPoints, _vertexData, GL_STATIC_DRAW);
}

- (void)tearDown {
    glDeleteBuffers(1, &vertexBuffer);
}

- (void)draw {
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    // we need the *4 since each GLfloat is 4-bytes.
    // ergo, "stride" of 6*4 is because 4*{x,y,z,nx,ny,nz}.
    // (Same for buffer offset).
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(12));
    
    glDrawArrays(GL_TRIANGLES, 0, _numPoints);
}

@end

@implementation BOCube

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setVertexData:gCubeVertexData withNumPoints:36];
    }
    
    return self;
}

@end



@implementation BOIcosahedron

- (id)init
{
    self = [super init];
    
    if (self) {
        // Calculate vertex data
        calculateIcosahedonData();
        
        [self setVertexData:gIcosahedronVertexData->data withNumPoints:gIcosahedronVertexData->numPoints];
    }
    
    return self;
}

@end




@implementation BODodecahedron

- (id)init
{
    self = [super init];
    
    if (self) {
        // Calculate vertex data
        calculateDodecahedronData();
        
        [self setVertexData:gDodecahedronVertexData->data withNumPoints:gDodecahedronVertexData->numPoints];
    }
    
    return self;
}

@end
