//
//  Shapes.h
//  AsteroidHelper
//
//  Created by Richard Goulter on 14/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BOShape : NSObject

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