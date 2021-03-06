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
            [self addEffect:effect];
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



- (void)addEffect:(AnimatedEffect*)effect
{
    if ([effect isKindOfClass:[TransformationEffect class]]) {
        [_transformEffects addObject:effect];
    } else if ([effect isKindOfClass:[ShaderUniformEffect class]]) {
        assert(_uniformEffects != nil);
        [_uniformEffects addObject:effect];
        assert(_uniformEffects.count > 0);
    } else {
        // All effects should be one or the other.
        assert(false);
    }
}



- (void)drawWithProgram:(GLProgram*)prog andCallback:(void (^)(GLKMatrix4))modelViewMatCallback
{
    // callback with the model transformation matrix for this
    // SpaceObject.
    // callback *before* setting uniforms, as the preparation step
    // may set the uniforms
    
    // Prepare for drawing
    GLKMatrix4 modelMat = [self transformation:GLKMatrix4Identity];
    modelViewMatCallback(modelMat);
    
    // Set the effect uniforms here. (Slightly awkward **DESIGN**).
    for (ShaderUniformEffect *effect in _uniformEffects) {
        [effect applyForProgram:prog];
    }
    
    
    [_shape draw];
}



- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    _age += timeSinceLastUpdate;
    
    [self.path tick:timeSinceLastUpdate];
    
    
    // Tick effects, remove the ones which have expired.
    for (TransformationEffect *effect in _transformEffects) {
        [effect tick:timeSinceLastUpdate];
    }
    
    for (ShaderUniformEffect *effect in _uniformEffects) {
        [effect tick:timeSinceLastUpdate];
    }
    
    [self removeExpiredEffectsFrom:_transformEffects];
    [self removeExpiredEffectsFrom:_uniformEffects];
}



- (void)removeExpiredEffectsFrom:(NSMutableArray*)array
{
    for (int i = (int)array.count - 1; i >= 0; i--) {
        AnimatedEffect *effect = [array objectAtIndex:i];
        
        if (effect.isExpired) {
            [array removeObjectAtIndex:i];
        }
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



- (GLKVector3)position
{
    return GLKVector3Make(_path.x, _path.y, _path.z);
}





@end