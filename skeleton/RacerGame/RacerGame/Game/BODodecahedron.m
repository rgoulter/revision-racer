//
//  BODodecahedron.m
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "BODodecahedron.h"
#import "BOShape_Color.h"



vertexdata *gDodecahedronVertexData = NULL;


void calculateDodecahedronData()
{
    if (gDodecahedronVertexData != NULL) {
        free(gDodecahedronVertexData);
    }
    
    gDodecahedronVertexData = calculateVertexData(gDodecahedronVertices, gDodecahedronFaceIndices);
}


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

