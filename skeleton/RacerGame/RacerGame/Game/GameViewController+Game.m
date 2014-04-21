//
//  GameViewController+Game.m
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController+Game.h"
#import "GameViewController+MCQ.h"

#import "BOStarCluster.h"

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
    
    assert(self.gameRules != nil);
    
    [self updateNumLives];
    [self updateScoreLabels];
}



- (void)explodeAsteroid:(Asteroid*)aster
{
    NSArray *debris = [aster debrisPieces];
    [aster tick:INFINITY];
    
    NSLog(@"Program Uniform idx for alpha: %d", [self.program uniformIndex:@"alpha"]);
    
    for (Asteroid *debrisAster in debris) {
        [self.deadAsteroids addObject:debrisAster];
        
        // **MAGIC** debris duration is 1.5 seconds.
        [debrisAster addEffect:[[FadeOutEffect alloc]
                                initWithDuration:1.5]];
    }
}




- (void)gameQuestionAnsweredEffect
{
    // Transfer asteroids from self.laneAsteroids to self.deadAsteroids
    for (Asteroid *aster in self.laneAsteroids) {
        [aster.path extendLifeByDuration:2];
        [self.deadAsteroids addObject:aster];
    }
    
    [self.laneAsteroids removeAllObjects];
}



- (void)updateScoreLabels
{
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score %3d", self.gameRules.score]];
    [self.scoreComboLabel setText:[NSString stringWithFormat:@"Combo %d", self.gameRules.combo]];
    
    // Make scorecombo label visible only if we have
    // a combo
    [self.scoreComboLabel setAlpha:self.gameRules.combo > 0 ? 1 : 0];
    
    // Set the label colors;
    UIColor *col = [UIColor whiteColor];
    self.scoreLabel.textColor = col;
    self.scoreComboLabel.textColor = col;
}



- (void)updateNumLives
{
    [self.livesVC setNumLives:self.gameRules.numLivesRemaining];
}



- (void)gameEffectForCorrectAnswer
{
    [self checkQnAnsStateRep];
    
    [self.gameRules updateRulesForCorrectAnswer];
    [self updateScoreLabels];
    
    [self explodeAsteroidForSelectedAnswer];
    
    // Tidy up asteroids..
    // **DEP** The design here is a little strange at this point.
    // Would prefer more like:
    //     --> gameQuestionAnsweredEvent(), checkCorrect() -> ..
    [self gameQuestionAnsweredEffect];
}



- (void)gameEffectForIncorrectAnswer
{
    [self checkQnAnsStateRep];
    
    [self.gameRules updateRulesForIncorrectAnswer];
    [self updateScoreLabels];
    
    [self.playerShip incorrectWobble];
    
    FlashEffect *flash = [[FlashEffect alloc]
                          initWithDuration:2.0
                               AndPeriod:0.6];
    [self.playerShip addEffect:flash];
    
    // Tidy up asteroids..
    // **DEP** The design here is a little strange at this point.
    [self gameQuestionAnsweredEffect];
    
    // Update num lives.
    [self updateNumLives];
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
    for (SpaceObject *star in self.stars) {
        [star tick:self.timeSinceLastUpdate];
    }
    for (Asteroid *aster in self.deadAsteroids) {
        [aster tick:self.timeSinceLastUpdate];
    }
    for (Asteroid *aster in self.laneAsteroids) {
        [aster tick:self.timeSinceLastUpdate];
    }
    
    for (int i = (int)[self.stars count] - 1; i >= 0; i--) {
        SpaceObject *star = [self.stars objectAtIndex:i];
        
        if ([star.path isExpired]) {
            [star tearDown];
            [self.stars removeObjectAtIndex:i];
        }
    }
    for (int i = (int)[self.laneAsteroids count] - 1; i >= 0; i--) {
        // Because _laneAsteroids' lifetime is the same as question duration,
        //  it's likely that the question is answered before this code is.
        // This is here in case we stagger answers?
        Asteroid *aster = [self.laneAsteroids objectAtIndex:i];
        
        if ([aster.path isExpired]) {
            // Do we remove lane asters here?..
            [self.laneAsteroids removeObjectAtIndex:i];
            
            NSLog(@"Lane Aster -> Dead Aster, extend");
            [self.deadAsteroids addObject:aster];
        }
    }
    for (int i = (int)[self.deadAsteroids count] - 1; i >= 0; i--) {
        Asteroid *aster = [self.deadAsteroids objectAtIndex:i];
        
        if ([aster.path isExpired]) {
            [aster tearDown];
            [self.deadAsteroids removeObjectAtIndex:i];
        }
    }
    
    if (self.stars.count < 1) {
        [self addStarCluster];
        SpaceObject *latestStar = [self.stars lastObject];
        [latestStar tick:self.gameRules.questionDuration / 2]; // **MAGIC**
    }
    if (self.stars.count < 2) {
        [self addStarCluster];
    }
}



- (void)tickGameObjects
{
    // Tick spaceship
    [self tickSpaceShip];
    
    [self tickAsteroids];
    
    
    // Game Rules
    [self.gameRules tick:self.timeSinceLastUpdate];
    if (self.gameRules.isOutOfLives) {
        [self gameOverWithMessage:@"You answered too many questions incorrectly"];
    } else if (self.gameRules.isOutOfTime) {
        [self gameOverWithMessage:@"Time is over"];
    }
    
    // Update Time Remaining label.
    if (self.gameRules.timeLimitEnabled) {
        float timeRemaining = self.gameRules.timeRemaining;
        int m = (int)(timeRemaining) / 60;
        int s = (int)(timeRemaining) % 60;
        
        self.timeRemainingLabel.text = [NSString stringWithFormat:@"%d:%02d", m, s];
    }
}



- (void)drawSpaceShip
{
    // Draws the SpaceShip object (of _playerShip),
    // using coordinates from self.view.
    
    CGRect viewFrame = self.view.frame;
    
    // Move the spaceship "forward" from the screen/camera.
    GLKMatrix4 rhsMat = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -5);
    
    
    // Translate the spaceship, corresponding to the point on the screen.
    // Magic #'s: I have no idea why 6 and 5 work? (4:3 ratio?).
    //
    // Since SpaceShip understands its coordinates in terms of TopLeft:(0,0),
    //  BottomRight:(width,height), we need to scale to map the coordinates about.
    
    // Scale to ScreenSize <- WorldSize
    GLfloat sw = 6 / viewFrame.size.width;
    GLfloat sh = 5 / viewFrame.size.height;
    rhsMat = GLKMatrix4Scale(rhsMat, sw, -(sh), 1);
    
    // Translate, since worldcoord's origin is in center of screen.
    rhsMat = GLKMatrix4Translate(rhsMat, -viewFrame.size.width / 2, -viewFrame.size.height / 2, 0);
    
    ////modelMatrix = [self.playerShip transformation:modelMatrix];
    
    // Scale to WorldSize <- ScreenSize (inverse of above).
    GLKMatrix4 lhsMat = GLKMatrix4Scale(GLKMatrix4Identity, 1 / (sw), -1 / (sh), 1);
    
    //[_program use];
    [self.playerShip drawWithProgram:self.program andCallback:^(GLKMatrix4 modelMatrix) {
        GLKMatrix4 mat = GLKMatrix4Multiply(rhsMat, modelMatrix);
        mat = GLKMatrix4Multiply(mat, lhsMat);
        
        [self prepareToDrawWithModelViewMatrix:mat
                           andProjectionMatrix:self.effect.transform.projectionMatrix];
    }];
}



- (void)drawAsteroid:(SpaceObject*)star
{
    // Draw an asteroid with an outline effect
    
    
    // Draw "Shadow"
    glDisable(GL_DEPTH_TEST);
    
    // We can scale the object down by applying the scale matrix after the transformation
    GLKMatrix4 lhsMat = GLKMatrix4Scale(GLKMatrix4Identity, 1.1, 1.1, 1.1);
    
    [star drawWithProgram:self.program andCallback:^(GLKMatrix4 modelMatrix) {
        [self prepareToDrawWithModelViewMatrix:GLKMatrix4Multiply(modelMatrix, lhsMat)
                           andProjectionMatrix:self.effect.transform.projectionMatrix];
        glUniform1i([self.program uniformIndex:@"isOutline"], 1);
    }];
    
    
    // Draw "Actual"
    glEnable(GL_DEPTH_TEST);
    
    [star drawWithProgram:self.program andCallback:^(GLKMatrix4 modelMatrix) {
        [self prepareToDrawWithModelViewMatrix:modelMatrix
                           andProjectionMatrix:self.effect.transform.projectionMatrix];
    }];
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
            [aster.pathCurve draw];
        }
    }
    for (Asteroid *aster in self.deadAsteroids) { // **HACK** **CODEDUPL**
        [self drawAsteroid:aster];
    }
    
    // draw spaceship
    [self drawSpaceShip];
    
    
    // draw stars
    [self.starShaderProgram use];
    
    for (SpaceObject *star in self.stars) {
        assert([star.shape isKindOfClass:[BOStarCluster class]]);
        
        [self.starShaderProgram useDefaultUniformValues];
        
        [star drawWithProgram:self.starShaderProgram andCallback:^(GLKMatrix4 modelMat) {
            GLKMatrix4 mvProjMatrix = GLKMatrix4Multiply(self.effect.transform.projectionMatrix, modelMat);
            glUniformMatrix4fv([self.starShaderProgram uniformIndex:@"uModelViewProjectionMatrix"], 1, 0, mvProjMatrix.m);
            glUniform3f([self.starShaderProgram uniformIndex:@"uBackgroundColor"], SPACEBG_R,  SPACEBG_G,  SPACEBG_B);
            glUniform1f([self.starShaderProgram uniformIndex:@"uAlpha"], 1);
        }];
    }
}




- (void)addLaneAsteroid:(NSUInteger)idx
{
    BOShape *shape = [[BOAsteroidShape alloc] init];
    
    // Find destination point, depending on where the corresponding answer UI is.
    CGPoint destWorldPt = [self worldPointForLaneNum:idx];
    float x = destWorldPt.x;
    float y = destWorldPt.y;
    
    float dz = (float)(arc4random() % 100) / 10;
    
    PathEffect *path = [[PathEffect alloc]
                        initWithStartX:x Y:y Z:-60 + dz
                        EndX:x Y:y Z:-5
                        Duration:self.gameRules.questionDuration];
    
    Asteroid *asteroid = [[Asteroid alloc]
                          initWithShape:shape
                                   Path:path];
    [asteroid setUp];
    
    [self.laneAsteroids addObject:asteroid];
}



- (void)addStarCluster
{
    BOShape *shape = [[BOStarCluster alloc] initWithNumPoints:100 inWidth:20 Height:20 Length:60];
    
    // Find destination point, depending on where the corresponding answer UI is.
    PathEffect *path = [[PathEffect alloc]
                        initWithStartX:0 Y:0 Z:-60
                        EndX:0 Y:0 Z:30
                        Duration:self.gameRules.questionDuration];
    
    // TODO: Fadein effect
    
    SpaceObject *starfield = [[SpaceObject alloc] initWithShape:shape
                                                           Path:path
                                                     andEffects:@[[[FadeInEffect alloc]
                                                                   initWithDuration:1.0]]];
    // setUp
    [starfield setUp];
    
    [self.stars addObject:starfield];
}

@end
