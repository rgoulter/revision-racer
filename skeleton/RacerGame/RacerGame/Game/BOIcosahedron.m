//
//  BOIcosahedron.m
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BOIcosahedron.h"
#import "BOShape_Color.h"



// 20 faces,
// each face is 3 points,
// each point is {x, y, z, nx, ny, nz};
vertexdata *gIcosahedronVertexData;



void calculateIcosahedronData()
{
    if (gIcosahedronVertexData != NULL) {
        free(gIcosahedronVertexData);
    }
    
    gIcosahedronVertexData = calculateVertexData(gIcosahedronVertices, gIcosahedronFaceIndices);
}



@implementation BOIcosahedron

- (id)init
{
    self = [super init];
    
    if (self) {
        // Calculate vertex data
        calculateIcosahedronData();
        
        [self setVertexData:gIcosahedronVertexData->data withNumPoints:gIcosahedronVertexData->numPoints];
        [self setColorAllToR:0 G:0 B:1];
    }
    
    return self;
}

@end





