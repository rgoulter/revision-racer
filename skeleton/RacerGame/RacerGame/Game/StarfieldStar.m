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
    
    BOOL _hasBeenSetUp;
    BOCurve *_pathCurve;
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
        
        _pathCurve = nil;
        _hasBeenSetUp = NO;
    }
    
    return self;
}

- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    assert(!_hasBeenSetUp);
    
    _sx = x;
    _sy = y;
    _sz = z;
}

- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    assert(!_hasBeenSetUp);
    
    _tx = x;
    _ty = y;
    _tz = z;
}

- (void)setUp
{
    //[_shape setUp];
    
    _hasBeenSetUp = YES;
    [self pathCurve]; // generate path curve.
    [_pathCurve setUp];
}

- (void)tearDown
{
    //[_shape tearDown];
    
    [_pathCurve tearDown];
    
    _hasBeenSetUp = NO;
}

- (void)draw
{
    // transform?
    // atm, transformation w/ GLKit is handled in the
    // GLKViewController whatever, since that's where the
    // .modelViewMatrix can be accessed. :/
    
    [_shape draw];
    
    glPushMatrix();
    glLoadIdentity();
    
    glColor4f(1, 0, 0, 1);
    
    glTranslatef(0, 0, -3);
    glScalef(0.2, 0.2, 0.2);
    [_shape draw];
    
    glPopMatrix();
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

- (BOCurve*)generatePathCurve
{
    int N = 100;
    
    GLfloat *data = (GLfloat*)malloc(sizeof(GLfloat) * VBO_NUMCOLS * 100);
    
    for (int i = 0; i < N; i++) {
        float t = (float) i / N;
        
        // calculate position; P = (1 - t) * A + t * B
        float x = (1 - t) * _sx + t * _tx;
        float y = (1 - t) * _sy + t * _ty;
        float z = (1 - t) * _sz + t * _tz;
        
        // Point
        data[i * VBO_NUMCOLS + 0] = x;
        data[i * VBO_NUMCOLS + 1] = y;
        data[i * VBO_NUMCOLS + 2] = z;
        
        // Normal. (for a line?!?)
        data[i * VBO_NUMCOLS + 3] = 0;
        data[i * VBO_NUMCOLS + 4] = 0;
        data[i * VBO_NUMCOLS + 5] = 0;
        
        // Color
        data[i * VBO_NUMCOLS + 6] = 0;
        data[i * VBO_NUMCOLS + 7] = 0;
        data[i * VBO_NUMCOLS + 8] = 0;
    }
    
    return [[BOCurve alloc] initWithData:data ofSize:N withColor:[CIColor colorWithRed:0 green:1 blue:1 alpha:0.5]];
}

- (BOCurve*)pathCurve
{
    if (_pathCurve) {
        return _pathCurve;
    } else {
        // BOCurve can't be changed .. so we want StarfieldStar to be "locked" into place..
        // (& if it's been setUp, then it can't change position).
        assert(_hasBeenSetUp);

        // Generate data for the path which this asteroid follows
        _pathCurve = [self generatePathCurve];
    
        return _pathCurve;
    }
}

@end