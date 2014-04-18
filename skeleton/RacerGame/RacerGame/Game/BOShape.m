//
//  BOShape.m
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOShape.h"



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
    int totalNumPoints = 0;
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

- (void)setUp
{
    NSLog(@"setup shape");
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * VBO_NUMCOLS * _numPoints, _vertexData, GL_STATIC_DRAW);
}

- (void)tearDown
{
    glDeleteBuffers(1, &vertexBuffer);
}

- (void)draw
{
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
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end

