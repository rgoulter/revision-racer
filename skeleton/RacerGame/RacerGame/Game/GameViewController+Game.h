//
//  GameViewController+Game.h
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController.h"

#import "StarfieldStar.h"
#import "Asteroid.h"
#import "SpaceShip.h"

#define SHOW_DEBUG_CURSORS NO
#define SHOW_DEBUG_ASTEROID_LANES NO

@interface GameViewController (Game)

@property SpaceShip *playerShip;
@property NSMutableArray *stars;
@property NSMutableArray *deadAsteroids; // **HACK**
@property NSMutableArray *laneAsteroids; // **HACK**

- (void)setUpGameObjects;
- (void)explodeAsteroid:(Asteroid*)aster;
- (void)addLaneAsteroid:(NSUInteger)idx;

- (void)gameEffectForCorrectAnswer;
- (void)gameEffectForIncorrectAnswer;
- (void)gameSetUpNewQuestion;

- (void)drawGameObjects;
- (void)tickGameObjects;
@end
