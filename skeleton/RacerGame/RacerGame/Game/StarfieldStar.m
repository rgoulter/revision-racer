//
//  StarfieldStar.m
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "StarfieldStar.h"

# pragma mark - Starfield Star stuff.

@implementation StarfieldStar {
    float _sx, _sy, _sz;
    float _tx, _ty, _tz;
    float _age;
    
    float _rotX, _rotDX, _rotY, _rotDY;
    
    float _r, _g, _b;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _age = 0;
        
        _rotX = (float)(arc4random() % 100) / 100;
        _rotDX = (float)(arc4random() % 10) / 100;
        _rotY = (float)(arc4random() % 100) / 100;
        _rotDY = (float)(arc4random() % 10) / 100;
    }
    
    return self;
}

- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    _sx = x;
    _sy = y;
    _sz = z;
}

- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    _tx = x;
    _ty = y;
    _tz = z;
}

- (void)setUp
{
    //[_shape setUp];
}

- (void)tearDown
{
    //[_shape tearDown];
}

- (void)draw
{
    // transform?
    // atm, transformation w/ GLKit is handled in the
    // GLKViewController whatever, since that's where the
    // .modelViewMatrix can be accessed. :/
    
    [_shape draw];
}

- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    _age += timeSinceLastUpdate;
    
    _rotX += _rotDX;
    _rotY += _rotDY;
}

- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    // Returns a matrix, M' = translationMat * M
    
    float t = _age / _duration;
    
    if (t > 1) { t = 1; }
    
    // calculate position; P = (1 - t) * A + t * B
    float x = (1 - t) * _sx + t * _tx;
    float y = (1 - t) * _sy + t * _ty;
    float z = (1 - t) * _sz + t * _tz;
    
    mat = GLKMatrix4Translate(mat, x, y, z);
    
    // We could rotate here if we wanted to.
    mat = GLKMatrix4Rotate(mat, _rotX * M_2_PI, 1, 0, 0);
    mat = GLKMatrix4Rotate(mat, _rotY * M_2_PI, 0, 1, 0);
    
    return mat;
}

- (BOOL)isExpired
{
    return _age > _duration;
}

@end