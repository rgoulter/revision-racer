//
//  BOSquarePyramid.m
//  RacerGame
//
//  Created by Richard Goulter on 18/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOSquarePyramid.h"
#import "BOShape_Color.h"


vertexdata *gSquarePyramidVertexData;



void calculateSquarePyramidData()
{
    if (gSquarePyramidVertexData != NULL) {
        free(gSquarePyramidVertexData);
    }
    
    gSquarePyramidVertexData = calculateVertexData(gSquarePyramidVertices, gSquarePyramidFaceIndices);
}




@implementation BOSquarePyramid

- (id)init
{
    self = [super init];
    
    if (self) {
        // Calculate vertex data
        calculateSquarePyramidData();
        
        [self setVertexData:gSquarePyramidVertexData->data withNumPoints:gSquarePyramidVertexData->numPoints];
        [self setColorAllToR:0 G:0 B:1];
    }
    
    return self;
}

@end
