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

#import "GLProgram.h"

#import "UIQuestionLabel.h"
#import "UIAnswerButton.h"
#import "LivesCounterViewController.h"

// Not sure what the best way to do color constants is;
// SPACEBG is for glClearColor(r, g, b, a);
#define SPACEBG_R 0.0074f
#define SPACEBG_G 0.0031f
#define SPACEBG_B 0.1862f

@interface GameViewController : GLKViewController

@property (weak, nonatomic) IBOutlet UIView *answersContainerView;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property (weak, nonatomic) IBOutlet UIQuestionLabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreComboLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;

@property (nonatomic) GameRules *gameRules;
@property (weak, readonly) LivesCounterViewController *livesVC;

@property FlashSetInfoAttributes *flashSet;

// The following few methods are needed by +MCQ category.
- (CGRect)getUIAnswerRectForIdx:(uint)idx;
- (IBAction)answerButtonPressed:(UIButton *)sender;
- (void)explodeAsteroidForSelectedAnswer;

// The following few methods are needed by +Game category
- (void)prepareToDrawWithModelViewMatrix:(GLKMatrix4)mvMat
                     andProjectionMatrix:(GLKMatrix4)projMat;
- (CGPoint)spaceshipRestPosition;
- (CGPoint)worldPointForLaneNum:(NSUInteger)idx;
- (void)selectAnswerUI:(id<AnswerUI>)answerUI;
- (void)checkQnAnsStateRep;
- (void)gameOverWithMessage:(NSString*)message;
@property (readonly) GLProgram *program;
@property (readonly) GLProgram *starShaderProgram;

- (void)setUpGL;
- (void)tearDownGL;

@end
