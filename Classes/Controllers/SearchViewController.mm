/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchViewController.h"
#import "SearchResultPlaceDataSource.h"
#import "AppSession.h"
#import "WFNavigationAppDelegate.h"
#import "UIApplication-Additions.h"
#import "LocalizationHandler.h"

#import "SearchDetail.h"
#import "Formatter.h"
#import "ErrorHandler.h"
#import "Search.h"
#import "MainMenuSearchTableViewController.h"

@implementation SearchViewController

@synthesize categorySearch;
@synthesize addressMode;
@synthesize currentAddress;

@synthesize categoryTableViewController;
@synthesize countryTableViewController;
@synthesize searchHistoryTableViewController;
@synthesize searchTermHistoryTableViewController;
@synthesize searchResultViewController;
@synthesize currentDataSource;

@synthesize parentController;

@synthesize currentSearch;

@synthesize searchTermCell;
@synthesize searchTermTextField;
@synthesize searchHistoryButton;
@synthesize categoriesCell;

@synthesize whereSectionHeader;
@synthesize whereSectionLabel;
@synthesize aroundMeCell;
@synthesize aroundMeLabel;
@synthesize aroundMeSwitch;
@synthesize locationCell;
@synthesize locationTextField;
@synthesize countryCell;
@synthesize searchButtonCell;
@synthesize searchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		parentController = nil;
		
        // Custom initialization
    }
	
    return self;
}

- (void)viewDidLoad {
	
	if (categorySearch) {
		self.title = [LocalizationHandler getString:@"iPh_categories_txt"];
	}
	else {
		UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHandler getString:@"iPh_history_tk"] style:UIBarButtonItemStylePlain target:nil action:nil];
		rightBarButtonItem.target = self;
		rightBarButtonItem.action = @selector(historyClicked:);
		[self navigationItem].rightBarButtonItem = rightBarButtonItem;
		[rightBarButtonItem release];
		
		self.title = [LocalizationHandler getString:@"iPh_search_txt"];
	}
	
	self.currentAddress = [LocalizationHandler getString:@"iPh_current_location_txt"];

	CategoryTableViewController *catTableViewController = [[CategoryTableViewController alloc] initWithNibName:@"SimpleTableView" bundle:[NSBundle mainBundle]];
	self.categoryTableViewController = catTableViewController;
	[catTableViewController release];
	CountryTableViewController *cntTableViewController = [[CountryTableViewController alloc] initWithNibName:@"SimpleTableView" bundle:[NSBundle mainBundle]];
	self.countryTableViewController = cntTableViewController;
//	cntTableViewController.view;
	[cntTableViewController release];
	
	self.whereSectionLabel.text = [LocalizationHandler getString:@"iPh_where_txt"];
	self.searchTermTextField.clearButtonMode = UITextFieldViewModeAlways;
	self.searchTermTextField.clearsOnBeginEditing = NO;
	[self.searchHistoryButton setBackgroundImage:[UIImage imageNamed:@"HistoryUp.png"] forState:UIControlStateNormal];
	[self.searchHistoryButton setBackgroundImage:[UIImage imageNamed:@"HistoryDown.png"] forState:UIControlStateHighlighted];
	if (addressMode) {
		self.searchTermTextField.placeholder = [LocalizationHandler getString:@"[street_name_and_number]"];
		self.searchHistoryButton.hidden = YES;
		CGRect frame = [self.searchTermTextField frame]; 
		frame.size.width = 300;
		self.searchTermTextField.frame = frame;
		self.locationTextField.placeholder = [LocalizationHandler getString:@"[city_or_zip]"];
	}
	else {
		self.searchTermTextField.placeholder = [LocalizationHandler getString:@"iPh_street_ph_no_comp_txt"];
		self.locationTextField.placeholder = [LocalizationHandler getString:@"iPh_location_txt"];
	}
	self.aroundMeLabel.text = [LocalizationHandler getString:@"iPh_around_me_txt"];
	self.locationTextField.clearButtonMode = UITextFieldViewModeAlways;

	[self.searchButton setTitle:[LocalizationHandler getString:@"iPh_search_tk"] forState:UIControlStateNormal];
	
	if ([APP_SESSION.searchHistoryDataSource.searchHistory count] > 0) {
		SearchDetail *latest = [APP_SESSION.searchHistoryDataSource.searchHistory objectAtIndex:0];
		self.currentSearch.country = latest.country;
	}

	aroundMeSwitchOn = NO;
	if (!addressMode) {
		[self aroundMeSwitchChanged:nil];
	}
    [super viewDidLoad];
}

- (void)initializeSearch {
	[self refreshCurrentLocation];
	SearchDetail *newSearch = [[SearchDetail alloc] init];
	self.currentSearch = newSearch;
	[newSearch release];
}

- (void)refreshCurrentLocation {
	if(!APP_SESSION.locationManager.receivedFirstGoodPosition) {
		// TODO(Fabian): This line is a possible crash cause: 'self' object might get dealloced in 0.5 seconds
		[self performSelector:@selector(refreshCurrentLocation) withObject:nil afterDelay:0.5f];
	}
	else {
		[APP_SESSION.locationManager.iPhoneLocationInterface requestLocationBasedReverseGeocodingAndSetGeocodingHandler:self];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	currentSearch.term = self.searchTermTextField.text;
	
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	// Dont call becomeFirstResponder before reloading the table. The table reload delegate also contains call to 'becomeFirstResponder'.
	// This can result in some racing between these commands and produce a hang + a message: "wait_fences: failed to receive a response".
//	[self.searchTermTextField becomeFirstResponder];
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.searchTermCell = nil;
	self.searchTermTextField = nil;
	self.searchHistoryButton = nil;
	self.categoriesCell = nil;
	
	self.whereSectionLabel = nil;
	self.whereSectionHeader = nil;
	self.aroundMeCell = nil;
	self.aroundMeLabel = nil;
	self.aroundMeSwitch = nil;
	self.locationCell = nil;
	self.locationTextField = nil;
	self.countryCell = nil;
	self.searchButton = nil;
	self.searchButtonCell = nil;
	
	self.currentSearch = nil;
	
	// Deregister data source and make it be dealloced
	[APP_SESSION.searchInterface removeRequestHandler:self.currentDataSource];
	[self.searchResultViewController registerPlaceDataSource:nil];

	self.currentDataSource = nil;

	self.countryTableViewController = nil;
	self.categoryTableViewController = nil;
	self.searchResultViewController = nil;
	self.searchHistoryTableViewController = nil;
	self.searchTermHistoryTableViewController = nil;
	
	self.currentAddress = nil;
	
    [super dealloc];
}

- (void)historyClicked:(id)sender {
	if (self.searchHistoryTableViewController == nil) {
		SearchHistoryTableViewController *tblViewController = [[SearchHistoryTableViewController alloc] initWithNibName:@"SimpleTableView" bundle:[NSBundle mainBundle]];
		self.searchHistoryTableViewController = tblViewController;
		
		[tblViewController release];
	}
	UITableView *tblView = (UITableView *)searchHistoryTableViewController.view;
	[tblView reloadData];
	
	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *navCtrl = delegat.navController;
	[navCtrl pushViewController:searchHistoryTableViewController animated:YES];
	searchHistoryTableViewController.searchResultViewController = searchResultViewController;
}


- (void)termHistoryClicked:(id)sender {
	if (self.searchHistoryTableViewController == nil) {
		SearchTermsTableViewController *tblViewController = [[SearchTermsTableViewController alloc] initWithNibName:@"SimpleTableView" bundle:[NSBundle mainBundle]];
		tblViewController.title = [LocalizationHandler getString:@"[prev_search_terms]"];
		self.searchTermHistoryTableViewController = tblViewController;
		
		[tblViewController release];
	}
	UITableView *tblView = (UITableView *)self.searchTermHistoryTableViewController.view;
	[tblView reloadData];
	
	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *navCtrl = delegat.navController;
	[navCtrl pushViewController:self.searchTermHistoryTableViewController animated:YES];
	self.searchTermHistoryTableViewController.currentSearch = self.currentSearch;
}

- (void)aroundMeSwitchChanged:(id)sender {
	if (aroundMeSwitch.enabled) {
		aroundMeSwitchOn = !aroundMeSwitchOn;
		aroundMeSwitch.on = aroundMeSwitchOn;
		self.aroundMeSwitch.enabled = NO;
		static NSUInteger hat[2] = {1, 2};
		NSIndexPath *ip = [[NSIndexPath alloc] initWithIndexes:hat length:2];
		
		[self.tableView beginUpdates];
		if (aroundMeSwitchOn) {
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
			[self.locationTextField setEnabled:NO];
			[self.locationTextField setTextColor:[UIColor grayColor]];
			self.locationTextField.clearButtonMode = UITextFieldViewModeNever;
			self.locationTextField.text = self.currentAddress;
		}
		else {
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
			[self.locationTextField setEnabled:YES];
			[self.locationTextField setTextColor:[UIColor blackColor]];
			[self.locationTextField becomeFirstResponder];
			self.locationTextField.clearButtonMode = UITextFieldViewModeAlways;
			self.locationTextField.text = @"";		
		}
		[self.tableView endUpdates];
		[ip release];
//		if (!categorySearch) {
//			[self.searchTermTextField becomeFirstResponder];
//		}
		if (sender) {
//			[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
			[self.tableView reloadData];
		}
	}
}

- (void)searchButtonClicked:(id)sender {
	[self textFieldShouldReturn:nil];
}

- (void)reverseGeocodingReady:(GeocodingInformation *)geocodingInformation {
	self.currentAddress = [Formatter formatGeocodingInformationToOneLine:geocodingInformation];
	if (aroundMeSwitchOn) {
		self.locationTextField.text = self.currentAddress;
	}
	TopRegionArray regions;
	[APP_SESSION.searchInterface getTopRegions:regions];
	for (TopRegionArray::iterator it = regions.begin(); it < regions.end(); it++) {
		TopRegion tr = *it;
		CountryDetail *cd = [[CountryDetail alloc] initWithTopRegion:&tr];
		if ([[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding] isEqualToString:cd.name]) {
			currentSearch.country = cd;
		}
		[cd release];
	}
	[self.tableView reloadData];
	
	// Fix for #10732. The parent controller extracts data from the table view of SearchViewController child object. That's why the parent controller should also be reloaded.
	[parentController.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return categorySearch? 3 : 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return section == 1 ? whereSectionHeader : nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return nil;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 ? (aroundMeSwitch.on ? 2 : 3) : 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static bool searchTermTextFieldBecameFirstResponder = false;
	static bool locationTextFieldBecameFirstResponder = false;
    
    UITableViewCell *cell = nil;

	switch (indexPath.section) {
		case 0: {
			searchTermTextFieldBecameFirstResponder = false;
			locationTextFieldBecameFirstResponder = false;
			switch(indexPath.row) {
				case 0: {
					if (categorySearch) {
						cell = self.categoriesCell;
						self.categoriesCell.textLabel.text = self.currentSearch.category.name;
//						[cell.imageView setImage:[[ImageFactory sharedInstance] getImageNamed:currentSearch.category.image]];
					}
					else {
						self.searchTermTextField.text = self.currentSearch.term;
						cell = self.searchTermCell;
					}
					break;
				}
			}
			break;
		}
		case 1: {
			switch(indexPath.row) {
				case 0: {
					cell = self.aroundMeCell;
					break;
				}
				case 1: {
					cell = self.locationCell;
					if (aroundMeSwitchOn) {
						if (!self.categorySearch) {
//							[self.searchTermTextField becomeFirstResponder];
							searchTermTextFieldBecameFirstResponder = true;
						}
						self.aroundMeSwitch.enabled = YES;
					}
					break;
				}
				case 2: {
					cell = self.countryCell;
					if (self.currentSearch.country.name == nil || self.currentSearch.country.name == @"") {
						countryCell.textLabel.textColor = [UIColor lightGrayColor];
						countryCell.textLabel.text = [LocalizationHandler getString:@"iPh_country_txt"];
					}
					else {
						countryCell.textLabel.textColor = [UIColor blackColor];
						self.countryCell.textLabel.text = self.currentSearch.country.name;
					}						
					if (!self.categorySearch) {
						if ([self.searchTermTextField.text length] == 0) {
//							[self.searchTermTextField becomeFirstResponder];
							searchTermTextFieldBecameFirstResponder = true;
						}
						else {
							locationTextFieldBecameFirstResponder = true;
//							[self.locationTextField becomeFirstResponder];
						}
					}
					self.aroundMeSwitch.enabled = YES;
					break;
				}
			}
			break;
		}
		case 2: {
			cell = self.searchButtonCell;
			break;
		}
	}
		
	// Are we at the last row in the last section?
	// the first responder textfield looses it's status of first responder when calling reloadData on the table view. That's why we set here again the first responder.
	if ((indexPath.row == [self tableView:tableView numberOfRowsInSection:1]-1) && (indexPath.section == [self numberOfSectionsInTableView:tableView]-1)) {
		// If yes then call only once the 'becomeFirstResponder' method.
		if (searchTermTextFieldBecameFirstResponder) {
			// Call with a delay because if called directly it causes a hang in the loop.
			[self.searchTermTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
		} else {
			if (locationTextFieldBecameFirstResponder) {
				[self.locationTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
			}
		}
	}
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row == 2 || indexPath.row == 0 ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch(indexPath.row) {
		case 0: {
			if (indexPath.section == 0) {
				if (self.categorySearch) {
					Position *currentPosition = [[Position alloc] initWithWGS84Coordinate:APP_SESSION.locationManager->currentPosition];
					[APP_SESSION.searchInterface getSearchCategoriesByPosition:currentPosition andSetSearchHandler:self.categoryTableViewController];
					[currentPosition release];
					self.categoryTableViewController.currentSearch = self.currentSearch;
					[self.navigationController pushViewController:self.categoryTableViewController animated:YES];
				}
				else {
					[self termHistoryClicked:nil];
				}
			}
			else {
				if (self.aroundMeSwitch.enabled) {
					self.aroundMeSwitch.on = !self.aroundMeSwitch.on;
					[self aroundMeSwitchChanged:self.aroundMeSwitch];
				}
			}
			break;
		}
		case 1: {
			break;
		}
		case 2: {
			self.countryTableViewController.currentSearch = self.currentSearch;
			[self.navigationController pushViewController:self.countryTableViewController animated:YES];
			break;
		}
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (void)typingCancelled:(id)sender {
	if ([self.searchTermTextField isFirstResponder]) {
		[self.searchTermTextField resignFirstResponder];	
	}
	else if ([self.locationTextField isFirstResponder]) {
		[self.locationTextField resignFirstResponder];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(typingCancelled:)];

	UIApplication *app = [UIApplication sharedApplication];
	WFNavigationAppDelegate *delegate = (WFNavigationAppDelegate *) app.delegate;
	UINavigationController *navcntrl = delegate.navController;
	UINavigationBar *navBar = navcntrl.navigationBar;
	NSArray *items = navBar.items;
	UINavigationItem *navItem = (UINavigationItem *) [items objectAtIndex:0]; 
	[navItem setRightBarButtonItem:cancelButton animated:YES];	
	
	[cancelButton release];		
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	UIApplication *app = [UIApplication sharedApplication];
	WFNavigationAppDelegate *delegate = (WFNavigationAppDelegate *) app.delegate;
	UINavigationController *navcntrl = delegate.navController;
	UINavigationBar *navBar = navcntrl.navigationBar;
	NSArray *items = navBar.items;
	UINavigationItem *navItem = (UINavigationItem *) [items objectAtIndex:0]; 
	[navItem setRightBarButtonItem:nil animated:YES];	
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (!self.categorySearch) {
		self.currentSearch.term = self.searchTermTextField.text;
	}
	if (!aroundMeSwitchOn) {
		self.currentSearch.location = self.locationTextField.text;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	wf_uint32 catID = WF_MAX_UINT32;
	NSString *what;
	
	self.currentSearch.term = self.searchTermTextField.text;
		
	// small hack to send log files through email
	if (ENABLE_LOGFILE_SYSTEM && ([self.searchTermTextField.text isEqualToString:[UIApplication secretWord]])) {
		[UIApplication sendLogsFileWithDelegate:self];
		return YES;
	}
	
	self.currentSearch.location = self.locationTextField.text;


	if (!aroundMeSwitchOn && (self.currentSearch.country.name == nil || self.currentSearch.country.name == @"")) {
		NSString *title = [LocalizationHandler getString:@"iPh_error_txt"];
		NSString *message = [LocalizationHandler getString:@"[no-country-selected]"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:[LocalizationHandler getString:@"iPh_ok_tk"] otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	if (categorySearch) {
		catID = [self.currentSearch.category.categoryIDAsInt unsignedIntValue];
		if (catID == WF_MAX_UINT32) {
			NSString *title = [LocalizationHandler getString:@"iPh_error_txt"];
			NSString *message = [LocalizationHandler getString:@"[no-category-selected]"];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:[LocalizationHandler getString:@"iPh_ok_tk"] otherButtonTitles:nil];
			[alert show];
			[alert release];
			return NO;
		}
	}
	else {
		what = self.currentSearch.term;
		if (!addressMode) {
			[APP_SESSION.searchTermsDataSource addSearchTerm:what];
		}
	}

	Search *searchQuery;
	
	if (aroundMeSwitchOn) {
		searchQuery = [[Search alloc] initWithWhat:what categoryID:catID position:APP_SESSION.locationManager->currentPosition];
	}
	else {
		if (!categorySearch && !addressMode) {
			[APP_SESSION.searchHistoryDataSource addSearch:self.currentSearch];
		}
		searchQuery = [[Search alloc] initWithWhat:what categoryID:catID topRegionID:[self.currentSearch.country.countryID unsignedIntValue]];

		NSString *where = self.currentSearch.location;
		if ([where length] > 0) {
			searchQuery.where = where;
		}
	}		
	
	if (addressMode) {
		searchQuery.headingID = 1;
	}
	
	[self.searchResultViewController.results removeAllObjects];
	
	// Deregister old data source
	[APP_SESSION.searchInterface removeRequestHandler:self.currentDataSource];
	
	// Register new data source and make the old one be dealloced
	SearchResultPlaceDataSource *dataSource = [[SearchResultPlaceDataSource alloc] init];
	self.currentDataSource = dataSource;
	[self.searchResultViewController registerPlaceDataSource:self.currentDataSource];
	[APP_SESSION.searchInterface searchWithQuery:searchQuery andSetSearchHandler:self.currentDataSource];
	
	[dataSource release];

	[searchQuery release];
	
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *ctrl = appDelegate.navController;
	self.searchResultViewController.firstTime = YES;
	// BOOL viewVisible;	
	[ctrl pushViewController:self.searchResultViewController animated:YES];
	[self.searchResultViewController setUseAroundMeStyle:aroundMeSwitchOn];
	[self.searchResultViewController loadingStarted];
	return NO;
}

- (void)errorWithStatus:(AsynchronousStatus *)status{
	NSLog(@"Unexpected callback to errorWithStatus (this should not happen on a GeocodingHandler): (%d) %s", status->getStatusCode(), status->getStatusMessage().c_str());
}

- (void)messageSent:(SKPSMTPMessage *)message {
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
	// we need to reset the key to default
	[UIApplication resetSecretWord];
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
