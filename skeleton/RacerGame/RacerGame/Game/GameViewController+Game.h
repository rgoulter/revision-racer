//
//  GameViewController+Game.h
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController.h"

#import "SpaceObject.h"
#import "Asteroid.h"
#import "SpaceShip.h"

#define SHOW_DEBUG_CURSORS NO
#define SHOW_DEBUG_ASTEROID_LANES NO

@interface GameViewController (Game)

@property SpaceShip *playerShip;
@property NSMutableArray *stars;
@property NSMutableArray *deadAsteroids; // **HACK**
@property NSMutableArray *laneAsteroids; // **HACK**

@property float timeSinceLastAsteroid;

// Borrow these labelso from GameVC.
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreComboLabel;

- (void)setUpGameObjects;
- (void)explodeAsteroid:(Asteroid*)aster;
- (void)addLaneAsteroid:(NSUInteger)idx;

- (void)gameEffectForCorrectAnswer;
- (void)gameEffectForIncorrectAnswer;
- (void)gameSetUpNewQuestion;

- (void)drawGameObjects;
- (void)tickGameObjects;
@end
