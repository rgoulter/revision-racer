#import "asserts.js"

function navigateToDesiredPage() {
	target.frontMostApp().mainWindow().buttons()["newGameButton"].tap();
}

function testViewControllerContent() {
	
	//Check if the user is already logged in
	buttonList["Sign In"].logElementTree();
	var isUserLoggedIn = !buttonList["Sign In"].isValid();
	
	var updateButton = buttonList["Update"];
	assertTrue(updateButton.isValid(), "Update button present on screen");
	assertTrue(!updateButton.isEnabled(), "Update button disabled currently on screen");
	
	var backButton = buttonList["Back"];
	assertTrue(backButton.isValid(), "Back button present on screen");
	assertTrue(backButton.isEnabled(), "Back button enabled on screen");
	
	var previewButton = buttonList["Preview"];
	assertTrue(previewButton.isValid(), "Preview button present on screen");
	assertTrue(!previewButton.isEnabled(), "Preview button disabled currently on screen");
	
	var startGameButton = buttonList["Start Game"];
	assertTrue(startGameButton.isValid(), "Start Game button present on screen");
	assertTrue(! startGameButton.isEnabled(), "Start Game button disabled currently on screen");
	
	assertTrue(window.collectionViews().length == 1, "Set collection view present on screen");
	var setCollectionView = window.collectionViews()[0];
	
	var collectionViewStatus = window.staticTexts()["collectionViewStatus"];
	assertTrue(collectionViewStatus.isValid(), "Set collection view present on screen");
	
	if(isUserLoggedIn) {
		target.frontMostApp().mainWindow().logElementTree();
		//See if the user has existing sets, none should be selected
		//If no sets are present, then background label should present something
		UIALogger.logMessage("Existing user logged in");
		var setCells = setCollectionView.cells();
		var totalNumberOfCells = setCells.length;
		
		if(setCells.length > 0) {
			//Probably check properties of any one cell
			UIALogger.logMessage("Testing when user has multiple set items");

			//Verify enable of some buttons when a set is selected
			setCells[0].tap();
			
			target.pushTimeout(10);
			previewButton.isVisible();
			target.popTimeout();
			assertTrue(previewButton.isEnabled(), "Preview button now enabled on screen");
			assertTrue(updateButton.isEnabled(), "Update button now enabled on screen");
			assertTrue(startGameButton.isEnabled(), "Start game button now enabled on screen");
			
			//Verify correct functioning of the search bar
			
			var setSearchBar = window.searchBars()[0];
			
			//Verify positive searches
			//Test for substring
			var positiveSearchResult = setCells[0].name();
			setSearchBar.setValue(positiveSearchResult);
			
			assertTrue(setCollectionView.cells().length >= 1, "Positive search works for complete string");
			
			//Verify empty string search
			
			setSearchBar.setValue("");
			assertTrue(setCollectionView.cells().length == totalNumberOfCells, "Positive search works for empty string");
			
			
			//Verify negative searches
			
			var negativeSearchResult = "abcdefghijk";
			setSearchBar.setValue(negativeSearchResult);
			assertTrue(setCollectionView.cells().length == 0, "Negative search works for complete string");
		}
		
		//Log the user out
		//target.frontMostApp().mainWindow().buttons()["signIn"].tap();
		//Alert detected. Expressions for handling alerts should be moved into the UIATarget.onAlert function definition.
		//target.frontMostApp().alert().cancelButton().tap();
		assertEquals("You are not logged to any Quizlet account",collectionViewStatus.value());
		
	} else {
		throw "Start the script with the user logged in to Quizlet";
	}
}

//To test the following

navigateToDesiredPage();
testViewControllerContent();

