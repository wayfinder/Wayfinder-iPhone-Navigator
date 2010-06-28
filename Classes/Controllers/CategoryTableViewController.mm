/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "CategoryTableViewController.h"
#import "AppSession.h";
#import "LocalizationHandler.h"
#import "SearchCategoryArray.h"
#import "SearchCategoryDetail.h"
#import "ErrorHandler.h"

@implementation CategoryTableViewController

@synthesize currentSearch;
@synthesize searchCategories;

- (void)viewDidLoad {
	self.title = [LocalizationHandler getString:@"iPh_categories_txt"];
	searchCategories = [[NSMutableArray alloc] init];
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [self searchCategoriesUpdated];
    [super viewWillAppear:animated];
}

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
    return [searchCategories count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CategoryTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    SearchCategoryDetail *scd = [searchCategories objectAtIndex:indexPath.row];
	cell.textLabel.text = scd.name;
	[cell.imageView setImage:[ImageFactory getImageNamed:scd.image]];
	cell.accessoryType = ([scd.name isEqualToString:currentSearch.category.name]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	currentSearch.category = [searchCategories objectAtIndex:indexPath.row];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
	self.searchCategories = nil;
	self.currentSearch = nil;
    [super dealloc];
}

- (void)searchCategoriesUpdated {
	SearchCategoryArray categories;
	[APP_SESSION.searchInterface getSearchCategories:categories];

	[searchCategories removeAllObjects];
//	[searchCategories addObject:ALL_CATEGORIES];
	
	for (SearchCategoryArray::iterator it = categories.begin(); it < categories.end(); it++) {
		SearchCategory ctg = *it;
		SearchCategoryDetail *scd = [[SearchCategoryDetail alloc] initWithSearchCategory:&ctg];
		[searchCategories addObject:scd];
		[scd release];	
	}
	
	[self.tableView reloadData];
}

- (void)headingImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self.tableView reloadData];
	}
}

- (void)categoryImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self.tableView reloadData];
	}
}	

- (void)resultImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self.tableView reloadData];
	}
}


- (void)errorWithStatus:(AsynchronousStatus *)status {
	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end

