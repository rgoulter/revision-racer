//
//  GameViewController+Game.m
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController+Game.h"
#import "GameViewController+MCQ.h"

@implementation GameViewController (Game)



@dynamic playerShip;
@dynamic stars;
@dynamic deadAsteroids; // **HACK**
@dynamic laneAsteroids; // **HACK**



- (void)setUpGameObjects
{
    // Setup Game Entities
    self.playerShip = [[SpaceShip alloc] initInView:self.view];
    [self.playerShip setPointOnScreen:[self spaceshipRestPosition]];
    
    self.stars = [[NSMutableArray alloc] init];
    self.deadAsteroids = [[NSMutableArray alloc] init];
    self.laneAsteroids = [[NSMutableArray alloc] init];
}



- (void)explodeAsteroid:(Asteroid*)aster
{
    NSArray *debris = [aster debrisPieces];
    [aster tick:INFINITY];
    
    for (Asteroid *debrisAster in debris) {
        [self.deadAsteroids addObject:debrisAster];
    }
}




- (void)gameQuestionAnsweredEffect
{
    // Transfer asteroids from self.laneAsteroids to self.deadAsteroids
    for (Asteroid *aster in self.laneAsteroids) {
        [aster extendLifeByDuration:2];
        [self.deadAsteroids addObject:aster];
    }
    
    [self.laneAsteroids removeAllObjects];
}



- (void)gameEffectForCorrectAnswer
{
//    [self checkQnAnsStateRep]; TODO
    
    [self explodeAsteroidForSelectedAnswer];
    
    // Tidy up asteroids..
    // **DEP** The design here is a little strange at this point.
    // Would prefer more like:
    //     --> gameQuestionAnsweredEvent(), checkCorrect() -> ..
    [self gameQuestionAnsweredEffect];
}



- (void)gameEffectForIncorrectAnswer
{
//    [self checkQnAnsStateRep]; TODO
    
    [self.playerShip incorrectWobble];
    
    // Tidy up asteroids..
    // **DEP** The design here is a little strange at this point.
    [self gameQuestionAnsweredEffect];
}



- (void)gameSetUpNewQuestion
{
    // We have _laneAsteroids to be only the *current* question's
    // asteroids.
    // The previous round of asteroids were changed in |gameEffectFor*Answer|
    assert(self.laneAsteroids.count == 0);
    
    
    // add 5x lane asteroids. **HACK**
    for (int i = 0; i < NUM_QUESTIONS; i++) {
        [self addLaneAsteroid:i];
    }
    
    
    // Move ship back to centre
    if (!self.playerShip.isBeingDragged) {
        [self.playerShip setDestinationPointOnScreen:[self spaceshipRestPosition] withSpeedPerSecond:SPACESHIP_LOW_SPEED];
    }
}



- (void)tickSpaceShip
{
    [self.playerShip tick:self.timeSinceLastUpdate];
    
    // _playerShip.answerHasBeenGiven is used to ensure that the player keeping a
    // pan-gesture about an answer won't repeatedly keep firing of "answered" events.
    
    if (self.playerShip.canAnswer &&
        self.playerShip.speed < 10 * self.timeSinceLastUpdate) {
        // Check whether we're close to any answer UIs,
        // Set selected answer if so.
        
        // **DEP** on GameVC, MCQ
        for (UIAnswerButton *uiAnsBtn in self.answerUIs) {
            // "close enough" = spaceship point in rect of answer
            
            CGRect ansRect = [self.view convertRect:uiAnsBtn.frame
                                           fromView:uiAnsBtn.superview];
            
            if (CGRectContainsPoint(ansRect, self.playerShip.pointOnScreen)) {
                [self selectAnswerUI:uiAnsBtn];
                
                
                // I forget what to do here.
                QuestionState *currentQuestionState = [self.questionUI associatedQuestionState];
                [currentQuestionState endState]; // invoke.
                
                
                // Deal with SpaceShip so it doesn't trigger "answers" too frequently.
                // Consider **DESIGN** here, as it feels hackish.
                [self.playerShip answeredQuestion];
            }
        }
    }
}



- (void)tickAsteroids
{
    // update stars
    // **CODEDUPL** **HACK** Forgive me..
    for (StarfieldStar *star in self.stars) {
        [star tick:self.timeSinceLastUpdate];
    }
    for (Asteroid *aster in self.deadAsteroids) {
        [aster tick:self.timeSinceLastUpdate];
    }
    for (Asteroid *aster in self.laneAsteroids) {
        [aster tick:self.timeSinceLastUpdate];
    }
    
    for (int i = (int)[self.stars count] - 1; i >= 0; i--) {
        StarfieldStar *star = [self.stars objectAtIndex:i];
        
        if ([star isExpired]) {
            [star tearDown];
            [self.stars removeObjectAtIndex:i];
        }
    }
    for (int i = (int)[self.laneAsteroids count] - 1; i >= 0; i--) {
        // Because _laneAsteroids' lifetime is the same as question duration,
        //  it's likely that the question is answered before this code is.
        // This is here in case we stagger answers?
        Asteroid *aster = [self.laneAsteroids objectAtIndex:i];
        
        if ([aster isExpired]) {
            // Do we remove lane asters here?..
            [self.laneAsteroids removeObjectAtIndex:i];
            
            NSLog(@"Lane Aster -> Dead Aster, extend");
            [self.deadAsteroids addObject:aster];
        }
    }
    for (int i = (int)[self.deadAsteroids count] - 1; i >= 0; i--) {
        Asteroid *aster = [self.deadAsteroids objectAtIndex:i];
        
        if ([aster isExpired]) {
            [aster tearDown];
            [self.deadAsteroids removeObjectAtIndex:i];
        }
    }
}



- (void)tickGameObjects
{
    // Tick spaceship
    [self tickSpaceShip];
    
    [self tickAsteroids];
}



- (void)drawSpaceShip
{
    // Draws the SpaceShip object (of _playerShip),
    // using coordinates from self.view.
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    CGRect viewFrame = self.view.frame;
    
    // Move the spaceship "forward" from the screen/camera.
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -5);
    
    
    // Translate the spaceship, corresponding to the point on the screen.
    // Magic #'s: I have no idea why 6 and 5 work? (4:3 ratio?).
    //
    // Since SpaceShip understands its coordinates in terms of TopLeft:(0,0),
    //  BottomRight:(width,height), we need to scale to map the coordinates about.
    
    // Scale to ScreenSize <- WorldSize
    GLfloat sw = 6 / viewFrame.size.width;
    GLfloat sh = 5 / viewFrame.size.height;
    modelMatrix = GLKMatrix4Scale(modelMatrix, sw, -(sh), 1);
    
    // Translate, since worldcoord's origin is in center of screen.
    modelMatrix = GLKMatrix4Translate(modelMatrix, -viewFrame.size.width / 2, -viewFrame.size.height / 2, 0);
    modelMatrix = [self.playerShip transformation:modelMatrix];
    
    // Scale to WorldSize <- ScreenSize (inverse of above).
    modelMatrix = GLKMatrix4Scale(modelMatrix, 1 / (sw), -1 / (sh), 1);
    
    
    // Now draw the spaceship, since the modelviewMatrix has the right position.
    // **HACK** Awkward hack, check to make sure SpaceShip is drawn the right way. (-z).
    modelMatrix = GLKMatrix4Scale(modelMatrix, 0.4, 0.4, -0.4); // Scale model down.
    self.effect.transform.modelviewMatrix = modelMatrix;
    
    //[_program use];
    [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                       andProjectionMatrix:self.effect.transform.projectionMatrix];
    glUniform1i([self.program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 0);
    [self.playerShip draw];
}



- (void)drawAsteroid:(StarfieldStar*)star
{
    // Draw an asteroid with an outline effect
    // Calculate model view matrix.
    GLKMatrix4 modelMatrix;
    GLfloat scale = 0.25;
    
    // Draw "Shadow"
    glDisable(GL_DEPTH_TEST);
    
    modelMatrix = GLKMatrix4Identity; //GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, scale);
    modelMatrix = [star transformation:modelMatrix];
    
    // We can scale the object down by applying the scale matrix here.
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
    
    modelMatrix = GLKMatrix4Scale(modelMatrix, 1.1, 1.1, 1.1);
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                       andProjectionMatrix:self.effect.transform.projectionMatrix];
    glUniform1i([self.program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 1);
    [star.shape draw];
    
    
    // Draw "Actual"
    glEnable(GL_DEPTH_TEST);
    
    // We can scale the object down by applying the scale matrix here.
    modelMatrix = GLKMatrix4Identity; //GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, scale);
    modelMatrix = [star transformation:modelMatrix];
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    
    [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                       andProjectionMatrix:self.effect.transform.projectionMatrix];
    glUniform1i([self.program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 0);
    [star.shape draw];
}



- (void)drawGameObjects
{
    // TODO: draw stars
    for (Asteroid *aster in self.laneAsteroids) {
        [self drawAsteroid:aster];
        
        // Draw Star  Path
        if (SHOW_DEBUG_ASTEROID_LANES) {
            self.effect.transform.modelviewMatrix = GLKMatrix4Identity;
            
            [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                               andProjectionMatrix:self.effect.transform.projectionMatrix];
            glUniform1i([self.program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 0);
            [aster.pathCurve draw];
        }
    }
    for (Asteroid *aster in self.deadAsteroids) { // **HACK** **CODEDUPL**
        [self drawAsteroid:aster];
    }
    
    // draw spaceship
    [self drawSpaceShip];
}




- (void)addLaneAsteroid:(NSUInteger)idx
{
    NSLog(@"Generate lane %d aster", (int)idx);
    Asteroid *asteroid = [[Asteroid alloc] init];
    
    asteroid.shape = [[BOAsteroidShape alloc] init];//[_starShapes objectAtIndex:rndShapeIdx];
    
    // Find destination point, depending on where the corresponding answer UI is.
    CGPoint destWorldPt = [self worldPointForLaneNum:idx];
    float x = destWorldPt.x;
    float y = destWorldPt.y;
    
    float dz = (float)(arc4random() % 100) / 10;
    
    [asteroid setStartPositionX:x Y:y Z:-60 + dz];
    [asteroid setEndPositionX:x Y:y Z:-5];
    
    asteroid.duration = self.gameRules.questionDuration;
    
    
    // setUp??
    // TODO: Not sure how it reacts to IF it's called multiple times.
    [asteroid setUp];
    
    [self.laneAsteroids addObject:asteroid];
}

@end
