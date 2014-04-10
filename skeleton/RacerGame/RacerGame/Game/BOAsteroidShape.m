//
//  BOAsteroidShape.m
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOAsteroidShape.h"
#import "BOIcosahedron.h"
#import "BODodecahedron.h"



vertexdata* generateAsteroidVertexData(GLfloat vertices[], int indices[])
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


@implementation BOAsteroidShape {
    vertexdata *data;
}

static dispatch_queue_t asteroidDispatchQueue;


+ (void)initialize {
    if (self == [BOAsteroidShape self]) {
        asteroidDispatchQueue = dispatch_queue_create("nus.cs3217.group06.asteroid", NULL);
    }
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
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
