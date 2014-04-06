//
//  Shapes.m
//  AsteroidHelper
//
//  Created by Richard Goulter on 14/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "Shapes.h"

#define PHI 1.618

static GLfloat gCubeVertexData[VBO_NUMCOLS * 3 * 2 * 6] =
{
    //x     y      z              nx     ny     nz     r  g  b
    1.0f, -1.0f, -1.0f,         1.0f,  0.0f,  0.0f,    0, 0, 0,
    1.0f,  1.0f, -1.0f,         1.0f,  0.0f,  0.0f,    0, 0, 0,
    1.0f, -1.0f,  1.0f,         1.0f,  0.0f,  0.0f,    0, 0, 0,
    1.0f, -1.0f,  1.0f,         1.0f,  0.0f,  0.0f,    0, 0, 0,
    1.0f,  1.0f,  1.0f,         1.0f,  0.0f,  0.0f,    0, 0, 0,
    1.0f,  1.0f, -1.0f,         1.0f,  0.0f,  0.0f,    0, 0, 0,
    
    1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,    0, 0, 0,
    -1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,    0, 0, 0,
    1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,    0, 0, 0,
    1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,    0, 0, 0,
    -1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,    0, 0, 0,
    -1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,    0, 0, 0,
    
    -1.0f,  1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,    0, 0, 0,
    -1.0f, -1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,    0, 0, 0,
    -1.0f,  1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,    0, 0, 0,
    -1.0f,  1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,    0, 0, 0,
    -1.0f, -1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,    0, 0, 0,
    -1.0f, -1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,    0, 0, 0,
    
    -1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,    0, 0, 0,
    1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,    0, 0, 0,
    -1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,    0, 0, 0,
    -1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,    0, 0, 0,
    1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,    0, 0, 0,
    1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,    0, 0, 0,
    
    1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,    0, 0, 0,
    -1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,    0, 0, 0,
    1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,    0, 0, 0,
    1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,    0, 0, 0,
    -1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,    0, 0, 0,
    -1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,    0, 0, 0,
    
    1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,    0, 0, 0,
    -1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,    0, 0, 0,
    1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,    0, 0, 0,
    1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,    0, 0, 0,
    -1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,    0, 0, 0,
    -1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,    0, 0, 0
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
void calcNormal(GLfloat x1, GLfloat y1, GLfloat z1,
                GLfloat x2, GLfloat y2, GLfloat z2,
                GLfloat x3, GLfloat y3, GLfloat z3,
                GLfloat output[])
{
    // u = 1->2
    GLfloat u1 = x2 - x1;
    GLfloat u2 = y2 - y1;
    GLfloat u3 = z2 - z1;
    
    // v = 2->3
    GLfloat v1 = x3 - x2;
    GLfloat v2 = y3 - y2;
    GLfloat v3 = z3 - z2;
    
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



// let pt1, 2, 3 be 3 pts of a triangle or polygon...
// normal is cp of 1->2 X 2->3
void calcNormalv(GLfloat data[], unsigned int ptIdx1, unsigned int ptIdx2,  unsigned int ptIdx3, GLfloat output[])
{
    GLfloat x1 = data[ptIdx1 * 3 + 0], y1 = data[ptIdx1 * 3 + 1], z1 = data[ptIdx1 * 3 + 2];
    GLfloat x2 = data[ptIdx2 * 3 + 0], y2 = data[ptIdx2 * 3 + 1], z2 = data[ptIdx2 * 3 + 2];
    GLfloat x3 = data[ptIdx3 * 3 + 0], y3 = data[ptIdx3 * 3 + 1], z3 = data[ptIdx3 * 3 + 2];
    
    return calcNormal(x1, y1, z1,
                      x2, y2, z2,
                      x3, y3, z3,
                      output);
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
    NSLog(@"Shape malloc");
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
            calcNormalv(vertices, idx1, idx2, idx3, nml);
            
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



// TODO: Refactor the other function above to use this.
void calcNormalForRowOfVertexData(GLfloat *vertexDataTri)
{
    // vertexDataRow is {x, y, z, nx, ny, nz, r, g, b}
    // vertexDataTri is expected to be 3x of these rows.
    // This function outputs the data of nx, ny, nz for these three rows.
   
    GLfloat x1 = vertexDataTri[0 * VBO_NUMCOLS + 0];
    GLfloat y1 = vertexDataTri[0 * VBO_NUMCOLS + 1];
    GLfloat z1 = vertexDataTri[0 * VBO_NUMCOLS + 2];
   
    GLfloat x2 = vertexDataTri[1 * VBO_NUMCOLS + 0];
    GLfloat y2 = vertexDataTri[1 * VBO_NUMCOLS + 1];
    GLfloat z2 = vertexDataTri[1 * VBO_NUMCOLS + 2];
   
    GLfloat x3 = vertexDataTri[2 * VBO_NUMCOLS + 0];
    GLfloat y3 = vertexDataTri[2 * VBO_NUMCOLS + 1];
    GLfloat z3 = vertexDataTri[2 * VBO_NUMCOLS + 2];
    
    // calculate normals for triangle
    GLfloat nml[3];
    calcNormal(x1, y1, z1, x2, y2, z2, x3, y3, z3, nml);
    
    // copy normal data to triangle
    memcpy(vertexDataTri + 0 * VBO_NUMCOLS + 3, nml, 3 * sizeof(GLfloat));
    memcpy(vertexDataTri + 1 * VBO_NUMCOLS + 3, nml, 3 * sizeof(GLfloat));
    memcpy(vertexDataTri + 2 * VBO_NUMCOLS + 3, nml, 3 * sizeof(GLfloat));
}



vertexdata* generateAsteroidVertexData(GLfloat vertices[], int indices[])
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
        // BUT, since we generate a triangle for every two points,
        // with the third point as the central .. numTri = numPoints.
        int numTri = numPoints;
        totalNumPoints += 3 * numTri;
        
        currentFaceIndex += numPoints + 1; // each point idx + the -1
    }
    
    // malloc the vertex data.
    // Each point has {x, y, z, nx, ny, nz}
    NSLog(@"Shape malloc for Asteroid");
    GLfloat *vertexData = (GLfloat*) malloc(totalNumPoints * VBO_NUMCOLS * sizeof(GLfloat));
    
    
    currentFaceIndex = indices;
    GLfloat *currentVertexData = vertexData;
    
    while (currentFaceIndex[0] != -1) {
        // Seek how many points there are for this face.
        int numPoints = 0;
        float cenX = 0;
        float cenY = 0;
        float cenZ = 0;
        
        while (currentFaceIndex[numPoints] != -1) {
            // Iterative formula to find average.
            // avg_i = x_i / i + (i - 1) * avg_(i-1) / i
            float xi = vertices[currentFaceIndex[numPoints] * 3 + 0];
            float yi = vertices[currentFaceIndex[numPoints] * 3 + 1];
            float zi = vertices[currentFaceIndex[numPoints] * 3 + 2];
            
            int i = numPoints;
            cenX = (xi + i * cenX) / (i + 1);
            cenY = (yi + i * cenY) / (i + 1);
            cenZ = (zi + i * cenZ) / (i + 1);
            
            numPoints += 1;
        }
        
        // Asteroid-ness, jitter the centrepoint.
        float r1 = (float)(arc4random() % 200 - 100) / 100;
        float r2 = (float)(arc4random() % 200 - 100) / 100;
        float r3 = (float)(arc4random() % 200 - 100) / 100;
        float k = 0.000000009;
        cenX += r1 * k;
        cenY += r2 * k;
        cenZ += r1 * k;
        
        float cenPt[3] = {cenX, cenY, cenZ};
        
        // For a regular polygon with n points,
        // it can be triangulated with n - 2 triangles.
        // BUT, since we generate a triangle for every two points,
        // with the third point as the central .. numTri = numPoints.
        int numTri = numPoints;
        
        // Color the face of the asteroid.
        // Random "Brown"-ish color.
        float faceR = (float)(arc4random() % 50 + 150) / 255;
        float faceG = (float)(arc4random() % 50 + 50) / 255;
        float faceB = (float)(arc4random() % 50 + 0) / 255;
        float color[3] = {faceR, faceG, faceB};
        
        GLfloat *currentTriData = currentVertexData;
        for (int i = 0; i < numTri; i++) {
            // copy vertices 0, a, b
            int idx1 = currentFaceIndex[(i) % numPoints];
            int idx2 = currentFaceIndex[(i + 1) % numPoints];
            
            cpyPoint(vertices, idx1, currentTriData + 0 * VBO_NUMCOLS);
            cpyPoint(vertices, idx2, currentTriData + 1 * VBO_NUMCOLS);
            memcpy(currentTriData + 2 * VBO_NUMCOLS, cenPt, 3 * sizeof(GLfloat));
            
            calcNormalForRowOfVertexData(currentTriData);
            
            memcpy(currentTriData + 0 * VBO_NUMCOLS + 6, color, 3 * sizeof(GLfloat));
            memcpy(currentTriData + 1 * VBO_NUMCOLS + 6, color, 3 * sizeof(GLfloat));
            memcpy(currentTriData + 2 * VBO_NUMCOLS + 6, color, 3 * sizeof(GLfloat));
            
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



vertexdata* createTetrahedronFromTriangle(GLfloat *data)
{
    // each row is assumed to be in form of {x, y, z, nx, ny, nz, r, g, b}
    // expected to have at least 3 rows.
    
    int totalNumPoints = 4 * 3; // it's a tetrahedron.
    
    GLfloat *vertexData = (GLfloat*) malloc(totalNumPoints * VBO_NUMCOLS * sizeof(GLfloat));
    
    GLfloat newPt[VBO_NUMCOLS] = {0, 0, 0, -1, -1, -1, data[6], data[7], data[8]};
    
    // Tri 0, ABC
    memcpy(vertexData + 0 * VBO_NUMCOLS, data + 0 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData + 1 * VBO_NUMCOLS, data + 1 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData + 2 * VBO_NUMCOLS, data + 2 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    // (normal already calculated).
    
    // Tri 1, ABD
    memcpy(vertexData + 3 * VBO_NUMCOLS, data + 0 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData + 4 * VBO_NUMCOLS, data + 1 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData + 5 * VBO_NUMCOLS, newPt, VBO_NUMCOLS * sizeof(GLfloat));
    calcNormalForRowOfVertexData(vertexData + 1 * 3 * VBO_NUMCOLS);
    
    // Tri 2, BCD
    memcpy(vertexData + 6 * VBO_NUMCOLS, data + 1 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData + 7 * VBO_NUMCOLS, data + 2 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData + 8 * VBO_NUMCOLS, newPt, VBO_NUMCOLS * sizeof(GLfloat));
    calcNormalForRowOfVertexData(vertexData + 2 * 3 * VBO_NUMCOLS);
    
    // Tri 3, CAD
    memcpy(vertexData + 9 * VBO_NUMCOLS, data + 2 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData +10 * VBO_NUMCOLS, data + 0 * VBO_NUMCOLS, VBO_NUMCOLS * sizeof(GLfloat));
    memcpy(vertexData +11 * VBO_NUMCOLS, newPt, VBO_NUMCOLS * sizeof(GLfloat));
    calcNormalForRowOfVertexData(vertexData + 3 * 3 * VBO_NUMCOLS);
    
    
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



void setVertexDataColor(GLfloat *data, int ptIdx, GLfloat r, GLfloat g, GLfloat b)
{
    // {x, y, z, nx, ny, nz, r, g, b}
    data[VBO_NUMCOLS * ptIdx + 6] = r;
    data[VBO_NUMCOLS * ptIdx + 7] = g;
    data[VBO_NUMCOLS * ptIdx + 8] = b;
}



@implementation BOShape {
    GLuint vertexBuffer;
    GLfloat *_vertexData;
    unsigned int _numPoints;
}

- (void)setColorAllToR:(GLfloat)r G:(GLfloat)g B:(GLfloat)b
{
    // Set vertex data color to blue (rgb = 0,0,1).
    for (int i = 0; i < _numPoints; i++) {
        setVertexDataColor(_vertexData, i, 0, 0, 1);
    }
}

- (void)setVertexData:(GLfloat *)data withNumPoints:(unsigned int)n
{
    NSLog(@"set vertex data");
    _vertexData = data;
    _numPoints = n;
}

- (void)setUp {
    NSLog(@"setup shape");
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
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    // we need the *4 since each GLfloat is 4-bytes.
    // ergo, "stride" of 6*4 is because 4*{x,y,z,nx,ny,nz}.
    // (Same for buffer offset).
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(12));
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(24));
    
    glDrawArrays(GL_TRIANGLES, 0, _numPoints);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end

@implementation BOCube

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setVertexData:gCubeVertexData withNumPoints:36];
        [self setColorAllToR:0 G:0 B:1];
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
        [self setColorAllToR:0 G:0 B:1];
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
        [self setColorAllToR:0 G:0 B:1];
    }
    
    return self;
}

@end



@implementation BOAsteroidShape {
    vertexdata *data;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        calculateIcosahedonData();
        calculateDodecahedronData();
        
        float rnd = arc4random() % 3;
        
        if (rnd < 0.5) {
            data = generateAsteroidVertexData(gIcosahedronVertices, gIcosahedronFaceIndices);
        } else {
            data = generateAsteroidVertexData(gDodecahedronVertices, gDodecahedronFaceIndices);
        }
        
        [self setVertexData:data->data withNumPoints:data->numPoints];
        [self computeCenterPoint];
    }
    
    return self;
}

//
- (id)initWithData:(vertexdata*)vdata
{
    self = [super init];
    
    if (self) {
        data = vdata;
        
        [self setVertexData:data->data withNumPoints:data->numPoints];
        [self computeCenterPoint];
    }
    
    return self;
}

- (void)tearDown
{
    [super tearDown];
    free(data);
}

- (void)computeCenterPoint
{
    // Compute average x, y, z
    float *d = data->data;
    _centerX = _centerY = _centerZ = 0;
    for (int i = 0; i < data->numPoints; i++) {
        // Use d to point to a row, which is {x, y, z, ...} of length VBO_NUMCOLS
        // Using iterative average method.
        _centerX = (d[0] + i * _centerX) / (i + 1);
        _centerY = (d[1] + i * _centerY) / (i + 1);
        _centerZ = (d[2] + i * _centerZ) / (i + 1);
        d += VBO_NUMCOLS;
    }
}

- (NSArray*)derivativeAsteroidShapes
{
    // REQUIRES before tearDown, otherwise will probably segfault.
    
    NSMutableArray *result = [NSMutableArray array];
    
    float *d = data->data;
    
    // Make a tetrahedron from every triangle;
    // Therefore, from every 3 points.
    for (int i = 0; i < data->numPoints; i += 3) {
        // **HACK** b/c creating these shapes is expensive,
        // we should do the creation of *all* the pieces in a different thread.
        // It's cheaper, however, to just only create some proportion of them.
        float rnd = (float)(arc4random() % 100) / 100;
        
        if (rnd < 0.3) {
            vertexdata *tetData = createTetrahedronFromTriangle(d);
            BOAsteroidShape *tetShape = [[BOAsteroidShape alloc] initWithData:tetData];
            [result addObject:tetShape];
        }
        
        // point to next triangle
        d += 3 * VBO_NUMCOLS;
    }
    
    return [NSArray arrayWithArray:result];
}

@end