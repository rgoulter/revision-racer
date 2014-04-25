
//=================
// Initial Setup  
//=================
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
var buttonList = window.buttons();

function assertEquals(expected, actual) {
    if (expected != actual) {
        UIALogger.logFail("expected = [" + expected + "], actual = ["+ actual +"]"); 
    } else {
		UIALogger.logPass("Assertion passed");
	}
}

function assertTrue(trueExpression,message) {
    if (trueExpression) {
        UIALogger.logPass(message);
    } else {
        throw "assertTrue failed";
	}
}

function assertNotEquals(expected, actual) {
    if (expected == actual) {
		UIALogger.logPass("Assertion passed");
    } else {
		UIALogger.logFail("expected = [" + expected + "], actual = ["+ actual +"]"); 
	}
}

function waitForObject(object) {
    target.pushTimeout(20);
    object.isVisible();
    target.popTimeout();
}

function test (functionToTest) {
    functionToTest();
}

function testOnlyIfLoggedIn(functionToTest) {
    var isUserLoggedIn = !buttonList["Sign In"].isValid();

    if (isUserLoggedIn) {
        functionToTest();
    } else { 
        throw "Start the script with the user logged in to Quizlet";
    }
}