/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "NavigationSelectionViewController.h"
#import "MainMenuTableViewController.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "Formatter.h"
#import "SearchViewController.h"
#import "WFNavigationAppDelegate.h"
#import "FavouritePlaceDataSource.h"

@implementation NavigationSelectionViewController

@synthesize addressTitleLabel;
@synthesize addressLabel;
@synthesize addressTableCell;
@synthesize searchTableViewcell;
@synthesize myPlacesTableViewCell;	
@synthesize currentAddress;
@synthesize mainMenuTableViewController;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.addressTitleLabel.text = [LocalizationHandler getString:@"iPh_my_current_location_txt"];
	self.title = [LocalizationHandler getString:@"iPh_navigate_to_txt"];
	self.searchTableViewcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchTableViewcell"];
	self.myPlacesTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myPlacesTableViewCell"];
	self.searchTableViewcell.textLabel.text = [LocalizationHandler getString:@"[search_table_cell_text]"];
	self.searchTableViewcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.myPlacesTableViewCell.textLabel.text = [LocalizationHandler getString:@"[favourites_table_cell_text]"];
	self.myPlacesTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
	self.currentAddress = [LocalizationHandler getString:@"iPh_no_address_txt"];

	[self.searchTableViewcell release];
	[self.myPlacesTableViewCell release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated { 
    [super viewDidAppear:animated];
	
	[APP_SESSION.locationManager.iPhoneLocationInterface requestLocationBasedReverseGeocodingAndSetGeocodingHandler:self];	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[APP_SESSION.locationManager.iPhoneLocationInterface removeGeocodingHandler:self];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Moved the member variables clean-up code to method 'dealloc' because this method never wasn't entered
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
      	
	switch(indexPath.section) {
		case 0:
			return self.addressTableCell;
			break;			
		case 1:
			return self.searchTableViewcell;
			break;
		case 2:
			return self.myPlacesTableViewCell;
			break;
			
	}

    return nil;
}

- (void)dealloc {
	self.addressTitleLabel = nil;
	self.addressLabel = nil;
	self.addressTableCell = nil;
	self.searchTableViewcell = nil;
	self.myPlacesTableViewCell = nil;
	self.currentAddress = nil;
	
	self.mainMenuTableViewController = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return [LocalizationHandler getString:@"iPh_from_txt"];
		case 1:
			return [LocalizationHandler getString:@"iPh_to_txt"];
		default:
			return nil;
	}
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	
}

#pragma mark -
#pragma mark GeocodingHandler Methods

- (void)reverseGeocodingReady:(GeocodingInformation *)geocodingInformation {
	self.currentAddress = [Formatter formatGeocodingInformationToOneLine:geocodingInformation];
	self.addressLabel.text = self.currentAddress;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		return 64.0;
	}
	else {
		return 48.0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) {
		[mainMenuTableViewController pushMenuItem:MENU_ITEM_MY_PLACES];
	}
	else if(indexPath.section == 2) {
		[mainMenuTableViewController pushMenuItem:MENU_ITEM_SEARCH];
	}
	
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end

