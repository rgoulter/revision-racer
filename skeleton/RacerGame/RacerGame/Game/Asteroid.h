//
//  Asteroid.h
//  RacerGame
//
//  Created by Richard Goulter on 6/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "StarfieldStar.h"

@interface Asteroid : StarfieldStar

// To create the effect of exploding an Asteroid,
//  we can either in GameVC take these "debris" pieces and manage them,
// (which is quick & cheap, but maybe dirty),
// OR,
// we could simulate the effect as part of Asteroid itself..
//  (which is cleaner, and puts all the mess here).
//
// **DESIGN**
// The only tricky thing here, though, is that the modelviewMatrix used by
//  vertex shader / pipeline, and the call to drawArrays are separated.
// This is a problem for drawing sub-asteroids in different place.
// So (for now at least), our design only supports the former. :/
- (NSArray*)debrisPieces;

@end
