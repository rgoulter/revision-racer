#import "asserts.js"

function navigateToDesiredPage() {
	target.frontMostApp().mainWindow().buttons()["newGameButton"].tap();
	
	target.frontMostApp().mainWindow().logElementTree();
}

function testSegueToPreviewPage() {

	var cellToSelect = target.frontMostApp().mainWindow().collectionViews()[0].cells()[0];
	
	target.pushTimeout(10);
	cellToSelect.isVisible();
	target.popTimeout();
	
	cellToSelect.tap();

	target.pushTimeout(10);
	buttonList["Preview"].isVisible();
	target.popTimeout();

	buttonList["Preview"].tap();
	target.delay(10);
}

function testPreviewPageContent() {

	var currentWindow = target.frontMostApp().mainWindow();

	target.pushTimeout(10);
	currentWindow.collectionViews()[0].isVisible();
	target.popTimeout();
	var setItemCollectionView = currentWindow.collectionViews()[0];

	assertTrue(setItemCollectionView.cells().length > 0, "Expected number of cells > 0");

	//Test flip
	target.pushTimeout(10);
	setItemCollectionView.cells()[0].isVisible();
	target.popTimeout();

	var itemToBeFlipped = setItemCollectionView.cells()[0];

	var typeBeforeFlip = itemToBeFlipped.staticTexts()[0];
	target.pushTimeout(10);
	typeBeforeFlip.isVisible();
	target.popTimeout();

	assertTrue("Term" == typeBeforeFlip.name(), "Type of card before flip is verified as term");

	//Do the actual flip
	itemToBeFlipped.tap();

	var typeAfterFlip = itemToBeFlipped.staticTexts()[0];
	target.pushTimeout(10);
	typeAfterFlip.isVisible();
	target.popTimeout();
	
	var definitionOfTerm  = itemToBeFlipped.staticTexts()[1].name();

	assertTrue("Definition" == typeAfterFlip.name(), "Type of card after flip is verified as definition");

	//Do another flip to verify reset to term
	itemToBeFlipped.tap();
	
	typeBeforeFlip = itemToBeFlipped.staticTexts()[0];
	target.pushTimeout(10);
	typeBeforeFlip.isVisible();
	target.popTimeout();

	assertTrue("Term" == typeBeforeFlip.name(), "Type of card after 2 flips is verified as term");

	itemToBeFlipped.logElementTree();

	//Test positive search by item
	target.pushTimeout(10);
	currentWindow.searchBars()[0].isVisible();
	target.popTimeout();
	var setItemSearchBar = currentWindow.searchBars()[0];
	var searchTermText = itemToBeFlipped.staticTexts()[1].name();

	setItemSearchBar.setValue(searchTermText);

	var filteredItem = setItemCollectionView.cells()[0];
	target.pushTimeout(10);
	filteredItem.isVisible();
	target.popTimeout();

	assertTrue(setItemCollectionView.cells().length >= 1,"Search bar tests positive for complete string search by item");
	assertEquals(filteredItem.staticTexts()[1].name(),searchTermText);

	//Test positive search by definition
	searchTermText = definitionOfTerm;
	setItemSearchBar.setValue(searchTermText);

	filteredItem = setItemCollectionView.cells()[0];
	target.pushTimeout(10);
	filteredItem.isVisible();
	target.popTimeout();

	assertTrue(setItemCollectionView.cells().length >= 1,"Search bar tests positive for complete string search by definition");
	filteredItem.tap();

	var actualDefinition = setItemCollectionView.cells()[0].staticTexts()[1];
	target.pushTimeout(10);
	actualDefinition.isVisible();
	target.popTimeout();

	assertEquals(actualDefinition.name(), searchTermText);
}

navigateToDesiredPage();
testSegueToPreviewPage();
testPreviewPageContent();