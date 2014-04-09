//
//  Shapes.h
//  AsteroidHelper
//
//  Created by Richard Goulter on 14/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define VBO_NUMCOLS 9

typedef struct
{
    GLfloat *data;
    unsigned int numPoints;
} vertexdata;

// Utility methods
void setVertexDataColor(GLfloat *data, int ptIdx, GLfloat r, GLfloat g, GLfloat b);

@interface BOShape : NSObject

// TODO: Change to initWithVertexData...
- (void)setVertexData:(GLfloat *)data withNumPoints:(unsigned int)n;

- (void)setUp;
- (void)tearDown;
- (void)draw;

@end

@interface BOCube : BOShape

@end

@interface BOIcosahedron : BOShape

@end

@interface BODodecahedron : BOShape

@end

@interface BOAsteroidShape : BOShape

@property (readonly) GLfloat centerX;
@property (readonly) GLfloat centerY;
@property (readonly) GLfloat centerZ;

@property (readonly) NSArray *derivativeAsteroidShapes;

@end