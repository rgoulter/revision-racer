//
//  BOCurve.m
//  RacerGame
//
//  Created by Richard Goulter on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOCurve.h"

// Just reimplement for now,
// and figure out a good way to try and ensure this is closer to BOShape..
@implementation BOCurve {
    GLuint vertexBuffer;
    GLfloat *_vertexData;
    unsigned int _numPoints;
}

- (id)initWithData:(GLfloat*)data ofSize:(GLuint)n withColor:(CIColor*)col
{
    self = [super init];
    
    if (self) {
        _vertexData = data;
        _numPoints = n;
        
        [self setColorAllToR:col.red G:col.green B:col.blue];
    }
    
    return self;
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
    
    [self setColorAllToR:0 G:0 B:1];
}

- (void)setUp {
    NSLog(@"setup shape");
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * VBO_NUMCOLS * _numPoints, _vertexData, GL_STATIC_DRAW);
    
    // We free the vertex data when we setup the curve, okay?
    free(_vertexData);
}

- (void)tearDown {
    glDeleteBuffers(1, &vertexBuffer);
}

- (void)draw {
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    // Not sure notion of "normal" makes sense applied to lines??
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //glEnableVertexAttribArray(GLKVertexAttribNormal);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    // we need the *4 since each GLfloat is 4-bytes.
    // ergo, "stride" of 6*4 is because 4*{x,y,z,nx,ny,nz}.
    // (Same for buffer offset).
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(0));
    //glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(12));
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, VBO_NUMCOLS * sizeof(GLfloat), BUFFER_OFFSET(24));
    
    glDrawArrays(GL_LINE_STRIP, 0, _numPoints);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end
