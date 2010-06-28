/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "MainMenuTableViewController.h"
#import "MainMenuTableViewCell.h"
#import "NavigationSelectionViewController.h"
#import "WFNavigationAppDelegate.h"
#import "SearchViewController.h"
#import "PlaceListViewController.h"
#import "MapViewController.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "PlaceDataSource.h"
#import "FavouritePlaceDataSource.h"

@implementation MainMenuTableViewController

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)pushMenuItem:(NSInteger)menuItem {
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)	[UIApplication sharedApplication].delegate;
	UINavigationController *navigationController = appDelegate.navController;
	NSLog(@"Menu item selected: %d", menuItem);
	switch(menuItem) {
#if 0			
		case MENU_ITEM_TAKE_ME_HOME: {
		}
#endif			
			
		case MENU_ITEM_MY_PLACES: {
			PlaceListViewController *placeListViewController =
			[[PlaceListViewController alloc] initWithNibName:@"PlaceListView" bundle:[NSBundle mainBundle]];
			
			PlaceDataSource *placeDataSource = [[FavouritePlaceDataSource alloc] init]; 
			
			[placeListViewController registerPlaceDataSource:placeDataSource];
			
			[placeListViewController setUseAroundMeStyle:NO];
			[navigationController pushViewController:placeListViewController animated:YES];
			[placeListViewController loadingStarted];
			[placeListViewController release];
			[placeDataSource release];
			
			break;			
		}
		case MENU_ITEM_SEARCH: {
			SearchViewController *searchViewController = 
			[[SearchViewController alloc] initWithNibName:@"SearchView" bundle:[NSBundle mainBundle]];
			PlaceListViewController *searchResultViewController =
			[[PlaceListViewController alloc] initWithNibName:@"PlaceListView" bundle:[NSBundle mainBundle]];
			
			// Force the controller to enter in 'viewDidLoad'
			searchResultViewController.view;
			
			searchViewController.searchResultViewController = searchResultViewController;
			
			[searchResultViewController release];
			searchViewController.categorySearch = NO;
			
			[searchViewController initializeSearch];
			
			[navigationController pushViewController:searchViewController animated:YES];
			[searchViewController release];	
			
			break;			
		}
	}
}	

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;}

- (NSString *)getMenuItemIdentifier:(NSInteger) row {
	switch(row) {
#if 0			
		case MENU_ITEM_TAKE_ME_HOME:
			return [LocalizationHandler getString:@"[take_me_home_text]"];
			break;
#endif
		case MENU_ITEM_MY_PLACES:
			return [LocalizationHandler getString:@"[favourites_table_cell_text]"];
			break;			
		case MENU_ITEM_SEARCH:
			return [LocalizationHandler getString:@"[search_table_cell_text]"];
			break;
	}
	return @"Unknown menu item!";
}

- (MainMenuTableViewCell *)getMenuItemCell:(NSInteger)row {
	NSString *menuItemIdentifier = [self getMenuItemIdentifier:row];
	// TODO(Fabian) - needs optimization: loadNibNamed should be called once if possible
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MainMenuTableCell" owner:self options:nil];
	MainMenuTableViewCell *tableCell = (MainMenuTableViewCell *)[objects objectAtIndex:0];
	
	tableCell.menuItemDescriptorLabel.text = menuItemIdentifier;
	
	NSString *bitmapfile;
	switch(row) {
#if 0			
		case MENU_ITEM_TAKE_ME_HOME:
			bitmapfile = @"MainMenu_Navigate.png";
			break;
#endif			
		case MENU_ITEM_MY_PLACES:
			bitmapfile = @"MainMenu_My_Places.png";
			break;			
		case MENU_ITEM_SEARCH:
			bitmapfile = @"MainMenu_Search.png";
			break;
		default:
			break;
	}
	
	UIImage *menuItemIcon = [UIImage imageNamed:bitmapfile];	
	tableCell.menuItemImageView.image = menuItemIcon;

	return tableCell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    	    
	return [self getMenuItemCell:indexPath.row];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self pushMenuItem:indexPath.row];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end

