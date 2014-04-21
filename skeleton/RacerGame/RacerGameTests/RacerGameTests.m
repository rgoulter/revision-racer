//
//  RacerGameTests.m
//  RacerGameTests
//
//  Created by Hunar Khanna on 20/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GameRules.h"

@interface RacerGameTests : XCTestCase

@end

@implementation RacerGameTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGameRulesDurationCanBeAdjusted
{
    // Test that the increase() & decrease() methods of
    // GameRules will increase/decrease time,
    // without going past maximums.
    
    GameRules *rules = [[GameRules alloc] init];
    
    float min = rules.minimumQuestionDuration;
    float max = rules.maximumQuestionDuration;
    
    float currentDuration, nextDuration;
    
    // Try decrease
    currentDuration = rules.questionDuration;
    [rules decreaseQuestionDuration];
    nextDuration = rules.questionDuration;
    XCTAssert(nextDuration < currentDuration);
    
    
    // Try increase
    currentDuration = rules.questionDuration;
    [rules increaseQuestionDuration];
    nextDuration = rules.questionDuration;
    XCTAssert(nextDuration > currentDuration);
    
    
    // Check won't quickly go below minimum
    for (int i = 0; i < 1000; i++) {
        [rules decreaseQuestionDuration];
    }
    XCTAssert(rules.questionDuration >= min);
    
    
    // Check won't quickly go above max
    for (int i = 0; i < 1000; i++) {
        [rules increaseQuestionDuration];
    }
    XCTAssert(rules.questionDuration <= max);
}

@end
