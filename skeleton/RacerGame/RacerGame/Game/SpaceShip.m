//
//  SpaceShip.m
//  RacerGame
//
//  Represents the player's avatar for the game.
//  Will presumably manage the GLKit stuff when we get there.
//  Manages animation / destination stuff.
//
//  **DESIGN** I'm unsure how much of 'SpaceShip' can be here and how
//   much would be better off in GameVC.
//
//  Created by Richard Goulter on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SpaceShip.h"
#import "SpaceShipShape.h"
#import "BOSquarePyramid.h"



@interface AfterBurner : SpaceObject
@end

@implementation AfterBurner

- (id)init
{
    BOSquarePyramid *pyra = [[BOSquarePyramid alloc] init];
    ShaderUniformEffect *sinFX = [[SinusoidalEffect alloc]
                               initWithAmplitude:0.05
                                       Frequency:M_PI * 2
                                         YOffset:0.3
                                        Duration:-0.4  // **TODO**: Indefinite time
                                      ForUniform:@"alpha"];
    self = [super initWithShape:pyra Path:nil andEffects:@[sinFX]];
    
    if (self) {
    }
    
    return self;
}

- (void)drawWithProgram:(GLProgram *)prog andCallback:(void (^)(GLKMatrix4))modelViewMatCallback
{
    // draw the afterburner with a translation.
    
    GLKMatrix4 lhsMat = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, 0.5);
    
    GLKMatrix4 scaleMat = GLKMatrix4Scale(GLKMatrix4Identity, 0.1, 0.1, 2);
    lhsMat = GLKMatrix4Multiply(lhsMat, scaleMat);
    
    // Intercept draw-call from parent so we scale down the asteroid..
    // We can scale the object down by applying the scale matrix after the transformation
    [super drawWithProgram:prog andCallback:^(GLKMatrix4 mvMat) {
        modelViewMatCallback(lhsMat);
    }];
}

@end



@interface SpaceShip ()

// The view which this spaceship is the "player avatar" for.
@property UIView *view;

@property float distTillCanNextAnswer;
@property BOOL isBeingDragged;

@property float hoverx;
@property float hovery;
@property float t;

// wobble effect
@property float rotZ;
@property float rotDZ;

@end

@implementation SpaceShip
{
    AfterBurner* _afterburner;
}

- (id)initInView:(UIView *)v
{
    BOShape *spaceshipShape = [[BOSpaceShipShape alloc] init];
    self = [super initWithShape:spaceshipShape Path:nil andEffects:nil];
    
    if (self) {
        _view = v;
        
        _pointOnScreen = CGPointMake(0, 0);
        _destinationPointOnScreen = CGPointMake(0, 0);
        _deltaPositionVector = CGPointMake(0, 0);
        
        _distTillCanNextAnswer = -1;
        
        _afterburner = [[AfterBurner alloc] init];
    }
    
    return self;
}

- (void)setUp
{
    [super setUp];
    [_afterburner setUp];
}

- (void)tearDown
{
    [_afterburner tearDown];
    [super tearDown];
};

- (BOOL)canAnswer
{
    return _distTillCanNextAnswer <= 0 &&
           [self speed] < 0.3;
}

- (void)answeredQuestion
{
    // **MAGIC** (particularly since this is 'independent' of screen size).
    _distTillCanNextAnswer = 100;
}

- (CGFloat)speed
{
    CGPoint d = self.deltaPositionVector;
    CGFloat dx = d.x, dy = d.y;
    
    return sqrtf(dx*dx + dy*dy);
}

- (void)setDestinationPointOnScreen:(CGPoint)pt withSpeedPerSecond:(float)sp
{
    self.destinationPointOnScreen = pt;
    self.speedPerSecond = sp;
}

- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    [super tick:timeSinceLastUpdate];
    
    
    // Aim for "destination"
    CGPoint relDestination = CGPointMake(_destinationPointOnScreen.x - _pointOnScreen.x,
                                         _destinationPointOnScreen.y - _pointOnScreen.y);
    CGFloat destVecLen = sqrtf(relDestination.x * relDestination.x + relDestination.y * relDestination.y);
    
    if (destVecLen <= _speedPerSecond * timeSinceLastUpdate) {
        _deltaPositionVector = relDestination;
        _pointOnScreen = _destinationPointOnScreen;
    } else {
        CGFloat k = timeSinceLastUpdate * _speedPerSecond / destVecLen;
        _deltaPositionVector = CGPointMake(relDestination.x * k,
                                           relDestination.y * k);
        
        _pointOnScreen = CGPointMake(_pointOnScreen.x + _deltaPositionVector.x,
                                     _pointOnScreen.y + _deltaPositionVector.y);
    }
    
    // Hover
    _t += timeSinceLastUpdate;
    while (_t > 12) { _t = _t - 12; }
    
    // ProTip: M_2_PI is *NOT* 2 * M_PI.
    _hoverx = 8 * cosf((_t / 4) * 2 * M_PI);
    _hovery = 5 * sinf((_t / 12) * 2 * M_PI);
    
    
    // Wobble effect
    float minRotDZ = M_PI / 60;
    float maxRotZ = M_PI / 9;
    float decayPerSecond = 0.9;
    _rotZ += _rotDZ * timeSinceLastUpdate;
    if (_rotZ > maxRotZ) { _rotZ = maxRotZ; _rotDZ *= -1; }
    if (_rotZ < -maxRotZ) { _rotZ = -maxRotZ; _rotDZ *= -1; }
    if (abs(_rotDZ) < minRotDZ) { _rotDZ = 0; _rotZ = 0; }
    _rotDZ *= (1 - decayPerSecond * timeSinceLastUpdate);
    
    [_afterburner tick:timeSinceLastUpdate];
    
    
    if (_distTillCanNextAnswer >= 0) {
        _distTillCanNextAnswer -= [self speed];
    }
}

- (void)drawWithProgram:(GLProgram*)prog andCallback:(void (^)(GLKMatrix4))modelViewMatCallback
{
    // Intercept draw-call from parent so we scale down the asteroid..
    // We can scale the object down by applying the scale matrix after the transformation
    [super drawWithProgram:prog andCallback:^(GLKMatrix4 mvMat) {
        // **HACK** Awkward hack, check to make sure SpaceShip is drawn the right way. (-z).
        GLfloat scale = 0.4;
        GLKMatrix4 lhsMat = GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, -scale); // Scale model down.
        
        modelViewMatCallback(GLKMatrix4Multiply(mvMat, lhsMat));
    }];
    
    GLKMatrix4 spaceshipTransform = [self transformation:GLKMatrix4Identity];
    [_afterburner drawWithProgram:prog andCallback:^(GLKMatrix4 mvMat){
        // ???
        
        //modelViewMatCallback(GLKMatrix4Multiply(mvMat, spaceshipTransform));
        modelViewMatCallback(GLKMatrix4Multiply(spaceshipTransform, mvMat));
        //modelViewMatCallback(spaceshipTransform);
    }];
}


- (void)incorrectWobble
{
    int sign = (arc4random() % 10 < 5) ? +1 : -1;
    _rotDZ = sign * 2 * M_PI;
}



- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    // SpaceShip will translate by the positionOnScreen,
    // so scaling will have to be done outside of SpaceShip
    
    // REQUIRES that the coord system has +x to the right, +y down.
    mat = GLKMatrix4Translate(mat, _pointOnScreen.x + _hoverx, _pointOnScreen.y + _hovery, 0);
    return GLKMatrix4Rotate(mat, _rotZ, 0, 0, 1);
}



- (void)respondToPanGesture:(UIPanGestureRecognizer*)recog
{
    if (recog.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [recog locationInView:self.view];
        
        // TODO: If pt *starts* close-to current spaceship.. HOW TO VETO??
        NSLog(@"Start pan at %f, %f", pt.x, pt.y);
        _isBeingDragged = YES;
    }
    
    if (recog.state == UIGestureRecognizerStateChanged) {
        CGPoint pt = [recog locationInView:self.view];
        
        _destinationPointOnScreen = pt;
        _speedPerSecond = SPACESHIP_HIGH_SPEED;
    }
    
    if (recog.state == UIGestureRecognizerStateEnded) {
        _isBeingDragged = NO;
    }
}

- (void)respondToTapGesture:(UITapGestureRecognizer*)recog
{
    if (recog.state == UIGestureRecognizerStateEnded) {
        CGPoint pt = [recog locationInView:self.view];
        
        _destinationPointOnScreen = pt;
        _speedPerSecond = SPACESHIP_HIGH_SPEED;
    }
}

@end
