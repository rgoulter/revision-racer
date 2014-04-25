#import "asserts.js"

test(function navigateToDesiredPage() {
	target.frontMostApp().mainWindow().buttons()["newGameButton"].tap();
});

testOnlyIfLoggedIn(function startGameInTrainingMode() {

	//Select the first available set
	assertTrue(window.collectionViews().length == 1, "Set collection view present on screen");
	var setCollectionView = window.collectionViews()[0];
	var setCells = setCollectionView.cells();

	waitForObject(setCells[0]);
	setCells[0].tap();

	//Set the training mode
	waitForObject(window.segmentedControls()[1]);
	window.segmentedControls()[1].buttons()["Training"].tap();

	//Start the game
	buttonList["Start Game"].tap();
});


test(function testGameObjects() {

	var comboLabel = app.mainWindow().staticTexts()["Combo 0"];
	waitForObject(comboLabel);
	assertTrue(comboLabel.isVisible() == 0, "Combo label hidden in training mode");

	var livesLabel = app.mainWindow().staticTexts()["Lives"];
	waitForObject(livesLabel);
	assertTrue(livesLabel.isVisible() == 0, "Lives label hidden in training mode");

	var scoreLabel = app.mainWindow().staticTexts()["scoreText"];
	waitForObject(scoreLabel);
	assertTrue(scoreLabel.isVisible() == 0, "Score label hidden in training mode");
})