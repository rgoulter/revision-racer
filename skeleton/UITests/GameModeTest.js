#import "asserts.js"

test(function navigateToDesiredPage() {
	target.frontMostApp().mainWindow().buttons()["newGameButton"].tap();
});

testOnlyIfLoggedIn(function startGameInGameMode() {

	//Select the first available set
	assertTrue(window.collectionViews().length == 1, "Set collection view present on screen");
	var setCollectionView = window.collectionViews()[0];
	var setCells = setCollectionView.cells();

	waitForObject(setCells[0]);
	setCells[0].tap();

	//Game mode should be set by default

	//Start the game
	buttonList["Start Game"].tap();
});


test(function testGameObjects() {

	target.delay(20);
	
	app.mainWindow().logElementTree();
	var comboLabel = app.mainWindow().staticTexts()["Combo 0"];
	waitForObject(comboLabel);
	assertTrue(comboLabel.isVisible() == 0, "Combo label hidden initially in game mode");

	var scoreLabel = app.mainWindow().staticTexts()["scoreText"];
	waitForObject(scoreLabel);
	assertTrue(scoreLabel.isVisible() == 1, "Score label hidden initially in game mode");

})