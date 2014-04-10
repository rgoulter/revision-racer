//
//  BOShape.h
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define VBO_NUMCOLS 9
#define PHI 1.618

typedef struct
{
    GLfloat *data;
    unsigned int numPoints;
} vertexdata;

// Utility methods
void cpyPoint(GLfloat vertexArray[], unsigned int idx, GLfloat output[]);
void calcNormalForRowOfVertexData(GLfloat *vertexDataTri);
vertexdata* calculateVertexData(GLfloat vertices[], int indices[]);
void setVertexDataColor(GLfloat *data, int ptIdx, GLfloat r, GLfloat g, GLfloat b);

@interface BOShape : NSObject

// TODO: Change to initWithVertexData...
- (void)setVertexData:(GLfloat *)data withNumPoints:(unsigned int)n;

- (void)setUp;
- (void)tearDown;
- (void)draw;

@end