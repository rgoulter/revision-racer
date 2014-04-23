//
//  SpaceObject.m
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SpaceObject.h"



@implementation SpaceObject {
    NSMutableArray *_transformEffects;
    NSMutableArray *_uniformEffects;
    
    float _age;
    
    float _r, _g, _b;
    
    BOOL _hasBeenSetUp;
}



- (id)initWithShape:(BOShape*)shape Path:(PathEffect*)path andEffects:(NSArray*)effects;
{
    self = [super init];
    
    if (self) {
        _age = 0;
        
        _shape = shape;
        _path = path;
        
        // Partition the effects array
        _transformEffects = [NSMutableArray array];
        _uniformEffects = [NSMutableArray array];
        
        for (AnimatedEffect *effect in effects) {
            if ([effect isKindOfClass:[TransformationEffect class]]) {
                [_transformEffects addObject:effect];
            } else if ([effect isKindOfClass:[ShaderUniformEffect class]]) {
                [_uniformEffects addObject:effect];
            } else {
                // All effects should be one or the other.
                assert(false);
            }
        }
    }
    
    return self;
}



- (id)init
{
    self = [super init];
    
    if (self) {
        _age = 0;
        
        
        _pathCurve = nil;
        _hasBeenSetUp = NO;
    }
    
    return self;
}



- (void)setUp
{
    [_shape setUp];
    
    _hasBeenSetUp = YES;
    
    [_path setUp];
}



- (void)tearDown
{
    [_shape tearDown];
    [_path tearDown];
    
    _hasBeenSetUp = NO;
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
    
    // TODO: Tick all effects..
    [self.path tick:timeSinceLastUpdate];
    
    for (TransformationEffect *effect in _transformEffects) {
        [effect tick:timeSinceLastUpdate];
    }
    
    for (ShaderUniformEffect *effect in _uniformEffects) {
        [effect tick:timeSinceLastUpdate];
    }
}



- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    // First apply the path transformation
    GLKMatrix4 resultMat = [_path transformation:mat];
    
    // Then apply the various rotating/scaling effects
    for (TransformationEffect *effect in _transformEffects) {
        resultMat = [effect transformation:resultMat];
    }
    
    return resultMat;
}




@end