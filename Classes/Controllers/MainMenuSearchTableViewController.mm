/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFNavigationAppDelegate.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "MainMenuSearchTableViewController.h"
#import "PlaceListViewController.h"

@implementation MainMenuSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[APP_SESSION loadCountries];
	
	svc = [[SearchViewController alloc] initWithNibName:@"SearchView" bundle:[NSBundle mainBundle]];
	PlaceListViewController *searchResultViewController = [[PlaceListViewController alloc] initWithNibName:@"PlaceListView" bundle:[NSBundle mainBundle]];
	searchResultViewController.addressMode = YES;
	// Force the controller to enter in 'viewDidLoad'
	searchResultViewController.view;
	
	svc.searchResultViewController = searchResultViewController;
	svc.categorySearch = NO;
	svc.parentController = self;
	svc.addressMode = YES;
	svc.view;
	[searchResultViewController release];
		
	[svc initializeSearch];
	if ([APP_SESSION.searchHistoryDataSource.searchHistory count] > 0) {
		SearchDetail *latest = [APP_SESSION.searchHistoryDataSource.searchHistory objectAtIndex:0];
		svc.currentSearch.country = latest.country;
	}

}

- (void)typingCancelled:(id)sender {
	if ([svc.searchTermTextField isFirstResponder]) {
		[svc.searchTermTextField resignFirstResponder];	
	}
	else if ([svc.locationTextField isFirstResponder]) {
		[svc.locationTextField resignFirstResponder];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
	UITableViewCell *cell = nil;
    
	switch(indexPath.section) {
		case 0: 
			cell = svc.searchTermCell;
			break;
		case 1:
			cell = svc.locationCell;
			break;
		case 2:
			cell = svc.countryCell;
			if (svc.currentSearch.country.name == nil || svc.currentSearch.country.name == @"") {
				svc.countryCell.textLabel.textColor = [UIColor lightGrayColor];
				svc.countryCell.textLabel.text = [NSString stringWithFormat:@"- %@ -", [LocalizationHandler getString:@"[select_country]"]];
			}
			else {
				svc.countryCell.textLabel.textColor = [UIColor blackColor];
				svc.countryCell.textLabel.text = svc.currentSearch.country.name;
			}						
			break;
		default:
			cell = nil;
	}
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 2 ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		svc.countryTableViewController.currentSearch = svc.currentSearch;
		WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)	[UIApplication sharedApplication].delegate;
		UINavigationController *navigationController = appDelegate.navController;
		[navigationController pushViewController:svc.countryTableViewController animated:YES];
		
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}

@end

