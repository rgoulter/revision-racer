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

@interface GameViewController : GLKViewController

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn0;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn1;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn2;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn3;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn4;

@property FlashSetInfo *flashSet;

- (void)setUpGL;
- (void)tearDownGL;

@end
