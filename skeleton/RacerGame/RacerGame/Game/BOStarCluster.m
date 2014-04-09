//
//  BOStarCluster.m
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOStarCluster.h"

// We have 5 columns per star;
// x, y, z as well as "intensity" and "traansparency".
#define STAR_NUM_COLS 5

// related S/O question
// http://gamedev.stackexchange.com/questions/11095/opengl-es-2-0-point-sprites-size

@implementation BOStarCluster {
    GLuint vertexBuffer;
    GLfloat *_vertexData;
    unsigned int _numPoints;
}



- (id)initWithNumPoints:(unsigned int)n inWidth:(float)w Height:(float)h Length:(float)l
{
    self = [super init];
    
    if (self) {
        
        // Allocate memory for glfloats,
        // each column having STAR_NUM_COLS number of columns,
        // n rows to draw n points, if we use GL_POINTS.
        _vertexData = malloc(sizeof(GLfloat) * STAR_NUM_COLS * n);
        
        for (int i = 0; i < n; i++) {
            float x = ((float)(arc4random() % 100) / 100) - 0.5;
            float y = ((float)(arc4random() % 100) / 100) - 0.5;
            float z = ((float)(arc4random() % 100) / 100) - 0.5;
            float u = (float)(arc4random() % 100) / 100;
            float v = (float)(arc4random() % 100) / 100; // brightness?
            
            _vertexData[STAR_NUM_COLS * i + 0] = x * w;
            _vertexData[STAR_NUM_COLS * i + 1] = y * h;
            _vertexData[STAR_NUM_COLS * i + 2] = z * l;
            _vertexData[STAR_NUM_COLS * i + 3] = u;
            _vertexData[STAR_NUM_COLS * i + 4] = v;
        }
        
        _numPoints = n;
    }
    
    return self;
}



- (void)setUp
{
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * STAR_NUM_COLS * _numPoints, _vertexData, GL_STATIC_DRAW);
    
    //free(_vertexData);
}



- (void)tearDown
{
    glDeleteBuffers(1, &vertexBuffer);
}



- (void)draw
{
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    glEnableVertexAttribArray(ATTRIB_STAR_VERTEX);
    glEnableVertexAttribArray(ATTRIB_STAR_BRIGHTNESS);
    glEnableVertexAttribArray(ATTRIB_STAR_INTENSITY);
    
    // we need the *4 since each GLfloat is 4-bytes.
    // ergo, "stride" of 6*4 is because 4*{x,y,z,nx,ny,nz}.
    // (Same for buffer offset).
    glVertexAttribPointer(ATTRIB_STAR_VERTEX, 3, GL_FLOAT, GL_FALSE, STAR_NUM_COLS * sizeof(GLfloat), BUFFER_OFFSET(0));
    glVertexAttribPointer(ATTRIB_STAR_BRIGHTNESS, 1, GL_FLOAT, GL_FALSE, STAR_NUM_COLS * sizeof(GLfloat), BUFFER_OFFSET(12));
    glVertexAttribPointer(ATTRIB_STAR_INTENSITY, 1, GL_FLOAT, GL_FALSE, STAR_NUM_COLS * sizeof(GLfloat), BUFFER_OFFSET(16));
    
    glDrawArrays(GL_POINTS, 0, _numPoints);
    
    glDisableVertexAttribArray(ATTRIB_STAR_VERTEX);
    glDisableVertexAttribArray(ATTRIB_STAR_BRIGHTNESS);
    glDisableVertexAttribArray(ATTRIB_STAR_INTENSITY);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end
