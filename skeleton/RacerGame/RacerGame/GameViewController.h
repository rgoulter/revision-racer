//
//  GameViewController.h
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "FlashSetItem.h"
#import "FlashSetInfo.h"
#import "GameQuestion.h"
#import "QuestionState.h"
#import "AnswerState.h"
#import "GameRules.h"

#import "UIQuestionLabel.h"
#import "UIAnswerButton.h"

@interface GameViewController : GLKViewController

@property (weak, nonatomic) IBOutlet UIView *answersContainerView;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property (weak, nonatomic) IBOutlet UIQuestionLabel *questionLabel;

@property (readonly) GameRules *gameRules;

@property FlashSetInfoAttributes *flashSet;

// The following few methods are needed by +MCQ category.
- (CGRect)getUIAnswerRectForIdx:(uint)idx;
- (IBAction)answerButtonPressed:(UIButton *)sender;
- (void)explodeAsteroidForSelectedAnswer;
- (void)gameEffectForCorrectAnswer;
- (void)gameEffectForIncorrectAnswer;
- (void)gameSetUpNewQuestion;

- (void)setUpGL;
- (void)tearDownGL;

@end
