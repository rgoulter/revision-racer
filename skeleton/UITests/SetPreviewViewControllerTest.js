#import "asserts.js"

function navigateToDesiredPage() {
	target.frontMostApp().mainWindow().buttons()["newGameButton"].tap();
	
	target.frontMostApp().mainWindow().logElementTree();
}

function testSegueToPreviewPage() {

	var cellToSelect = target.frontMostApp().mainWindow().collectionViews()[0].cells()[0];
	
	waitForObject(cellToSelect);
	
	cellToSelect.tap();
	
	waitForObject(buttonList["Preview"]);

	buttonList["Preview"].tap();
	target.delay(10);
}

function testPreviewPageContent() {

	var currentWindow = target.frontMostApp().mainWindow();

	waitForObject(currentWindow.collectionViews()[0]);
	var setItemCollectionView = currentWindow.collectionViews()[0];

	assertTrue(setItemCollectionView.cells().length > 0, "Expected number of cells > 0");

	//Test flip
	waitForObject(setItemCollectionView.cells()[0]);

	var itemToBeFlipped = setItemCollectionView.cells()[0];
	var typeBeforeFlip = itemToBeFlipped.staticTexts()[0];

	waitForObject(typeBeforeFlip);
	assertTrue("Term" == typeBeforeFlip.name(), "Type of card before flip is verified as term");

	//Do the actual flip
	itemToBeFlipped.tap();

	var typeAfterFlip = itemToBeFlipped.staticTexts()[0];
	waitForObject(typeAfterFlip);
	
	var definitionOfTerm  = itemToBeFlipped.staticTexts()[1].name();

	assertTrue("Definition" == typeAfterFlip.name(), "Type of card after flip is verified as definition");

	//Do another flip to verify reset to term
	itemToBeFlipped.tap();
	
	typeBeforeFlip = itemToBeFlipped.staticTexts()[0];
	waitForObject(typeBeforeFlip);

	assertTrue("Term" == typeBeforeFlip.name(), "Type of card after 2 flips is verified as term");

	itemToBeFlipped.logElementTree();

	//Test positive search by item
	waitForObject(currentWindow.searchBars()[0]);
	var setItemSearchBar = currentWindow.searchBars()[0];
	var searchTermText = itemToBeFlipped.staticTexts()[1].name();

	setItemSearchBar.setValue(searchTermText);

	var filteredItem = setItemCollectionView.cells()[0];
	waitForObject(filteredItem);

	assertTrue(setItemCollectionView.cells().length >= 1,"Search bar tests positive for complete string search by item");
	assertEquals(filteredItem.staticTexts()[1].name(),searchTermText);

	//Test positive search by definition
	searchTermText = definitionOfTerm;
	setItemSearchBar.setValue(searchTermText);

	filteredItem = setItemCollectionView.cells()[0];
	waitForObject(filteredItem);

	assertTrue(setItemCollectionView.cells().length >= 1,"Search bar tests positive for complete string search by definition");
	filteredItem.tap();

	var actualDefinition = setItemCollectionView.cells()[0].staticTexts()[1];
	waitForObject(actualDefinition);

	assertEquals(actualDefinition.name(), searchTermText);
}

navigateToDesiredPage();
testSegueToPreviewPage();
testPreviewPageContent();