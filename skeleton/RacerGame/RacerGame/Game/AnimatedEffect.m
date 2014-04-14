//
//  AnimatedEffect.m
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "AnimatedEffect.h"



@interface AnimatedEffect ()

@property float age;
@property float duration;

@end



@implementation AnimatedEffect

- (id)initWithDuration:(float)duration
{
    self = [super init];
    
    if (self) {
        _age = 0;
        _duration = duration;
    }
    
    return self;
}

- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    _age += timeSinceLastUpdate;
}



- (BOOL)isExpired
{
    return _age > _duration;
}



- (void)extendLifeByDuration:(NSTimeInterval)additonalDuration
{
    _duration += additonalDuration; // T + U;
}



@end



# pragma mark - TransformEffects



@implementation TransformationEffect

- (id)initWithDuration:(float)duration
{
    self = [super initWithDuration:duration];
    
    return self;
}

- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    return mat;
}

@end



@implementation RotationEffect {
    float _rotX, _rotDX, _rotY, _rotDY;
}

- (id)initWithRandomRotation
{
    self = [super init];
    
    if (self) {
        _rotX = (float)(arc4random() % 100) / 100;
        _rotDX = (float)(arc4random() % 10) / 100;
        _rotY = (float)(arc4random() % 100) / 100;
        _rotDY = (float)(arc4random() % 10) / 100;
    }
    
    return self;
}

- (id)initWithRotX:(float)rx DRotX:(float)drx RotY:(float)ry DRotY:(float)dry
{
    self = [super init];
    
    if (self) {
        _rotX = rx;
        _rotDX = drx;
        _rotY = ry;
        _rotDY = dry;
    }
    
    return self;
}



- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    // **TODO** *timeSinceLastUpdate, for consistency.
    _rotX += _rotDX;
    _rotY += _rotDY;
}



- (float)rotationX
{
    return _rotX;
}



- (float)rotationY
{
    return _rotY;
}



- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    // Returns a matrix, M' = translationMat * M
    
    // We could rotate here if we wanted to.
    mat = GLKMatrix4Rotate(mat, _rotX * M_2_PI, 1, 0, 0);
    mat = GLKMatrix4Rotate(mat, _rotY * M_2_PI, 0, 1, 0);
    
    return mat;
}



@end



@implementation PathEffect {
    float _sx, _sy, _sz;
    float _tx, _ty, _tz;
    
    BOCurve *_pathCurve;
}



- (id)initWithStartX:(GLfloat)sx Y:(GLfloat)sy Z:(GLfloat)sz
                EndX:(GLfloat)tx Y:(GLfloat)ty Z:(GLfloat)tz
            Duration:(float)duration
{
    self = [super initWithDuration:duration];
    
    if (self) {
        [self setStartPositionX:sx Y:sy Z:sz];
        [self setEndPositionX:tx Y:ty Z:tz];
    }
    
    return self;
}



- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    _sx = x; _sy = y; _sz = z;
}



- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    _tx = x; _ty = y; _tz = z;
}



- (float)x
{
    float t = self.age / self.duration;
    if (t > 1) { t = 1; }
    return (1 - t) * _sx + t * _tx;
}



- (float)y
{
    float t = self.age / self.duration;
    if (t > 1) { t = 1; }
    return (1 - t) * _sy + t * _ty;
}



- (float)z
{
    float t = self.age / self.duration;
    if (t > 1) { t = 1; }
    return (1 - t) * _sz + t * _tz;
}



- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    // Returns a matrix, M' = translationMat * M
    
    // calculate position; P = (1 - t) * A + t * B
    mat = GLKMatrix4Translate(mat, self.x, self.y, self.z);
    
    return mat;
}





- (void)extendLifeByDuration:(NSTimeInterval)additionalDuration
{
    // TODO: For correctness, we should tidy up the PathCurve and re-create it.
    
    // Assuming Linear Path,
    // we need to extrapolate where the endpoint now is.
    
    float T = self.duration;
    float U = additionalDuration; // +duration
    
    _tx += U * (_tx - _sx) / T;
    _ty += U * (_ty - _sy) / T;
    _tz += U * (_tz - _sz) / T;
    
    [super extendLifeByDuration:additionalDuration];
}



- (void)setUp
{
    [self pathCurve]; // generate path curve.
    [_pathCurve setUp];
}



- (void)tearDown
{
    [_pathCurve tearDown];
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
        //assert(_hasBeenSetUp);
        
        // Generate data for the path which this asteroid follows
        _pathCurve = [self generatePathCurve];
        
        return _pathCurve;
    }
}


@end



# pragma mark - Uniform effects

@implementation ShaderUniformEffect

- (id)initWithDuration:(float)duration
{
    self = [super initWithDuration:duration];
    
    if (self) {
        
    }
    
    return self;
}

- (void)apply {
    
}

@end



@implementation FadeOutEffect {
    GLuint _uniform;
}

- (id)initForUniform:(GLuint)uniform WithDuration:(float)duration
{
    self = [super initWithDuration:duration];
    
    if (self) {
        _uniform = uniform;
    }
    
    return self;
}

- (void)apply
{
    float t = self.age / self.duration; // between (0, 1).
    
    glUniform1f(_uniform, 1 - t);
}

@end