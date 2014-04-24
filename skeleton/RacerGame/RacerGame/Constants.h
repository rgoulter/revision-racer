//
//  Constants.h
//  RacerGame
//
//  Created by Hunar Khanna on 24/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#ifndef RacerGame_Constants_h
#define RacerGame_Constants_h

#define GAME_RESULT_TABLE_CELL_IMAGE @"GameResultTableViewCellImage"
#define REGULAR_BUTTON_FONT [UIFont fontWithName:@"Georgia-BoldItalic" size:20];
#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithRed:(17.0/255.0) green:(8.0/255.0) blue:(51.0/255.0) alpha:1.0]
#define BUTTON_DISABLED_COLOR [UIColor colorWithRed:(201.0/255.0) green:(201.0/255.0) blue:(201.0/255.0) alpha:1.0]
#define BUTTON_ENABLED_COLOR [UIColor colorWithRed:1.0 green:(189.0/255.0) blue:(36.0/255.0) alpha:1.0]

//Entity names and attributes
#define FLASHSET_INFO_ENTITY_NAME @"FlashSetInfo"
#define FLASHSET_ITEM_ENTITY_NAME @"FlashSetItem"
#define USER_INFO_ENTITY_NAME @"UserInfo"
#define GAME_RESULT_INFO_ENTITY_NAME @"GameResultInfo"
#define GAME_RESULT_DETAILS_ENTITY_NAME @"GameResultDetails"

//Entity attributes keys found in raw json data downloaded
//from Quizlet
#define JSON_SET_KEY @"set"
#define JSON_SET_ID_KEY @"id"
#define JSON_SET_TITLE_KEY @"title"
#define JSON_SET_CREATED_DATE_KEY @"created_date"
#define JSON_SET_MODIFIED_DATE_KEY @"modified_date"
#define JSON_SET_ITEM_LIST_KEY @"terms"

#define JSON_SET_ITEM_ID_KEY @"id"
#define JSON_SET_ITEM_TERM_KEY @"term"
#define JSON_SET_ITEM_DEFINITION_KEY @"definition"

#endif
