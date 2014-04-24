
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