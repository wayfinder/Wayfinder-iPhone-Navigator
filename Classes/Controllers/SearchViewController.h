/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIKit.h>

#import "CategoryTableViewController.h"
#import "CountryTableViewController.h"
#import "SearchTermsTableViewController.h"
#import "SearchHistoryTableViewController.h"
#import "PlaceListViewController.h"
#import "SearchDetail.h"
#import "GeocodingHandler.h"
#import "EmailDelegate.h"

@class SearchResultPlaceDataSource;
@class MainMenuSearchTableViewController;

@interface SearchViewController : UITableViewController<UITextFieldDelegate, UIAlertViewDelegate, GeocodingHandler, EmailDelegate> {	
	BOOL categorySearch;
	BOOL addressMode;
	NSString *currentAddress;
	BOOL aroundMeSwitchOn;
	
	CategoryTableViewController *categoryTableViewController;
	CountryTableViewController *countryTableViewController;

	SearchHistoryTableViewController *searchHistoryTableViewController;
	SearchTermsTableViewController *searchTermHistoryTableViewController;
	PlaceListViewController *searchResultViewController;
	MainMenuSearchTableViewController *parentController;
	
	SearchDetail *currentSearch;
	
	// This var must be kept as a member variable in order to be able to deregister it before a new search is began.
	// We don't know when the data source finished to feed us, thus don't know when to release to it otherwhere
	SearchResultPlaceDataSource *currentDataSource;
	
	IBOutlet UITableViewCell *searchTermCell;
	IBOutlet UITextField *searchTermTextField;
	IBOutlet UIButton *searchHistoryButton;
	IBOutlet UITableViewCell *categoriesCell;
	
	IBOutlet UIView *whereSectionHeader;
	IBOutlet UILabel *whereSectionLabel;
	IBOutlet UITableViewCell *aroundMeCell;
	IBOutlet UILabel *aroundMeLabel;
	IBOutlet UISwitch *aroundMeSwitch;
	IBOutlet UITableViewCell *locationCell;
	IBOutlet UITextField *locationTextField;
	IBOutlet UITableViewCell *countryCell;
	IBOutlet UITableViewCell *searchButtonCell;
	IBOutlet UIButton *searchButton;
}

@property (nonatomic) BOOL categorySearch;
@property (nonatomic) BOOL addressMode;
@property (nonatomic, retain) NSString *currentAddress;

@property (nonatomic, retain) CategoryTableViewController *categoryTableViewController;
@property (nonatomic, retain) CountryTableViewController *countryTableViewController;
@property (nonatomic, retain) SearchHistoryTableViewController *searchHistoryTableViewController;
@property (nonatomic, retain) SearchTermsTableViewController *searchTermHistoryTableViewController;
@property (nonatomic, retain) PlaceListViewController *searchResultViewController;

@property (nonatomic, retain) SearchResultPlaceDataSource *currentDataSource;

@property (nonatomic, retain) SearchDetail *currentSearch;

@property (nonatomic, retain) MainMenuSearchTableViewController *parentController;

@property (nonatomic, retain) UITableViewCell*searchTermCell;
@property (nonatomic, retain) UITextField *searchTermTextField;
@property (nonatomic, retain) UIButton *searchHistoryButton;
@property (nonatomic, retain) UITableViewCell *categoriesCell;

@property (nonatomic, retain) UIView *whereSectionHeader;
@property (nonatomic, retain) UILabel *whereSectionLabel;
@property (nonatomic, retain) UITableViewCell *aroundMeCell;
@property (nonatomic, retain) UILabel *aroundMeLabel;
@property (nonatomic, retain) UISwitch *aroundMeSwitch;
@property (nonatomic, retain) UITableViewCell *locationCell;
@property (nonatomic, retain) UITextField *locationTextField;
@property (nonatomic, retain) UITableViewCell *countryCell;
@property (nonatomic, retain) UITableViewCell *searchButtonCell;
@property (nonatomic, retain) UIButton *searchButton;

- (void)historyClicked:(id)sender;
- (IBAction)termHistoryClicked:(id)sender;
- (IBAction)aroundMeSwitchChanged:(id)sender;
- (IBAction)searchButtonClicked:(id)sender;

- (void)initializeSearch;
- (void)refreshCurrentLocation;

@end
