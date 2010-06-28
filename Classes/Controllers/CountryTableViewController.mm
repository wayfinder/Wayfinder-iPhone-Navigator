/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "CountryTableViewController.h"
#import "TopRegionArray.h"
#import "CountryDetail.h"
#import "AppSession.h"
#import "LocalizationHandler.h"

@implementation CountryTableViewController

@synthesize currentSearch;

- (void)viewDidLoad {
	self.title = [LocalizationHandler getString:@"iPh_countries_txt"];
	
	[self.tableView reloadData];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSArray *recentCountries = APP_SESSION.searchHistoryDataSource.recentCountries;
	NSString *key = @" ";
	
	if ([recentCountries count] > 0) {
		if (![APP_SESSION.countryTitles containsObject:key]) {
			NSMutableArray *letters = [[NSMutableArray alloc] initWithArray:APP_SESSION.countryTitles];
			[letters insertObject:key atIndex:0];
			APP_SESSION.countryTitles = letters;
			[letters release];
		}
		NSMutableArray *countryArray = [APP_SESSION.countries objectForKey:key];
		if (countryArray == nil) {
			countryArray = [[NSMutableArray alloc] init];
			[APP_SESSION.countries setObject:countryArray forKey:key];
			[countryArray release];
		}
		[countryArray removeAllObjects];
		for (CountryDetail *cd in recentCountries) {
			[countryArray addObject:cd];
		}
	}
	
	[self.tableView reloadData];
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
    return [APP_SESSION.countryTitles count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return APP_SESSION.countryTitles;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = [APP_SESSION.countryTitles objectAtIndex:section];
	// if the section is the blank section at the top (and not a letter), replace the title
	if ([title isEqualToString:@" "]) {
		title = [LocalizationHandler getString:@"iPh_most_recent_txt"];
	}
	return title;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[APP_SESSION.countries objectForKey:[APP_SESSION.countryTitles objectAtIndex:section]] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlainOldBoringCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    CountryDetail *cd = [[APP_SESSION.countries objectForKey:[APP_SESSION.countryTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	cell.textLabel.text = cd.name;
	cell.accessoryType = ([cd.name isEqualToString:currentSearch.country.name]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	currentSearch.country = [[APP_SESSION.countries objectForKey:[APP_SESSION.countryTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	[self.navigationController popViewControllerAnimated:YES];
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
//	self.countries = nil;
	self.currentSearch = nil;
//	self.titles = nil;
    [super dealloc];
}


@end

