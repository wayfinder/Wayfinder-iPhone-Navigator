/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchHistoryTableViewController.h"

#import "WFNavigationAppDelegate.h"
#import "PlaceTableViewCell.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "SearchDetail.h"
#import "SearchResultPlaceDataSource.h"

@implementation SearchHistoryTableViewController

@synthesize searchResultViewController;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = [LocalizationHandler getString:@"iPh_prev_searches_txt"];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [APP_SESSION.searchHistoryDataSource.searchHistory count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SearchHistoryCellIdentifier = @"SearchHistoryCellIdentifier";
	
	PlaceTableViewCell *cell = (PlaceTableViewCell *)[tableView dequeueReusableCellWithIdentifier: SearchHistoryCellIdentifier];
	
	if (cell == nil) 
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchHistoryTableViewCell" owner:self options:nil];
		
		cell = [nib objectAtIndex:0];
	}
	
	NSUInteger row = indexPath.row;
	SearchDetail *current = [APP_SESSION.searchHistoryDataSource.searchHistory objectAtIndex:row];
	cell.title.text = current.term;
	NSString *tmp = [[NSString alloc] initWithFormat:([current.location length] > 0 ? @"%@, %@" : @"%@%@"), current.location, current.country.name];
	cell.subTitle.text = tmp;
	[tmp release];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SearchDetail *currentSearch = [APP_SESSION.searchHistoryDataSource.searchHistory objectAtIndex:indexPath.row];
	[currentSearch retain];
	NSLog(@"Searcherating...");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[APP_SESSION.searchHistoryDataSource addSearch:currentSearch];
	[tableView reloadData];
	
	Search *searchQuery = [[Search alloc] initWithWhat:currentSearch.term categoryID:[currentSearch.category.categoryIDAsInt unsignedIntValue] topRegionID:[currentSearch.country.countryID unsignedIntValue]];
	searchQuery.where = currentSearch.location;
	[currentSearch release];
	
	SearchResultPlaceDataSource *srpdc = [[SearchResultPlaceDataSource alloc] init];
	[self.searchResultViewController registerPlaceDataSource:srpdc];
	
	[APP_SESSION.searchInterface searchWithQuery:searchQuery andSetSearchHandler:srpdc];
	[srpdc release];
	[searchQuery release];
	
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *ctrl = appDelegate.navController;
	
	[searchResultViewController.results removeAllObjects];
	[searchResultViewController loadingStarted];
	[searchResultViewController setUseAroundMeStyle:NO];
	[ctrl pushViewController:searchResultViewController animated:YES];
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
	[searchResultViewController release];
    [super dealloc];
}


@end

