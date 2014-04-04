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

#import "UIQuestionLabel.h"
#import "UIAnswerButton.h"

@interface GameViewController : GLKViewController <QuestionSessionManager>

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property (weak, nonatomic) IBOutlet UIQuestionLabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIAnswerButton *answerBtn0;
@property (weak, nonatomic) IBOutlet UIAnswerButton *answerBtn1;
@property (weak, nonatomic) IBOutlet UIAnswerButton *answerBtn2;
@property (weak, nonatomic) IBOutlet UIAnswerButton *answerBtn3;
@property (weak, nonatomic) IBOutlet UIAnswerButton *answerBtn4;

@property FlashSetInfoAttributes *flashSet;

- (void)setUpGL;
- (void)tearDownGL;

@end
