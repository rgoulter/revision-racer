//
//  BOStarCluster.h
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "Shapes.h"

enum starattribute
{
    ATTRIB_STAR_VERTEX,
    ATTRIB_STAR_INTENSITY,
    ATTRIB_STAR_BRIGHTNESS,
    ATTRIB_STAR_THICKNESS,
    NUM_STAR_ATTRIBUTES
};

@interface BOStarCluster : BOShape

- (id)initWithNumPoints:(unsigned int)n inWidth:(float)w Height:(float)h Length:(float)l;

@end
