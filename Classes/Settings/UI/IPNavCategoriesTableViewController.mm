/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPNavCategoriesTableViewController.h"
#import "IPNavSwitchTableViewCell.h"

#import "IPNavSettingsManager.h"
#import "AppSession.h"
#import "SearchCategoryDetail.h"


@implementation IPNavCategoriesTableViewController

- (id)init {
	self = [super initWithStyle:UITableViewStylePlain];
	if (!self) return nil;
	
	_settingsManager = [IPNavSettingsManager sharedInstance];
	_categories = [[NSArray alloc] initWithArray:[APP_SESSION.searchInterface searchCategories]];
	
	return self;
}


- (void)dealloc {
	[_categories release];
    [_cachedCells release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
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



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_categories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	IPNavSwitchTableViewCell *cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:@"cell"] autorelease];
	SearchCategoryDetail *categoryDetail = [_categories objectAtIndex:indexPath.row];
	
	NSString *categoryName = [categoryDetail name];
	NSNumber *categoryValue = [NSNumber numberWithBool:[_settingsManager valueForCategory:[categoryDetail categoryID]]];
	
	NSDictionary *settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:categoryName, @"settingName",
								 categoryValue, @"settingValue",
								 nil];
	
	[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
	[[(IPNavSwitchTableViewCell *)cell valueSwitch] addTarget:self 
													   action:@selector(categoriesChanged:) 
											 forControlEvents:UIControlEventValueChanged];

	[[(IPNavSwitchTableViewCell *)cell valueSwitch] setTag:indexPath.row];
	
    return cell;
}

- (void)categoriesChanged:(id)selector {
	NSUInteger categoryIndex = [(UISwitch *)selector tag];
	SearchCategoryDetail *categoryDetail = [_categories objectAtIndex:categoryIndex];
	[_settingsManager setValue:[selector isOn] forCategory:[categoryDetail categoryID]];
	[_settingsManager saveSettings];
}

@end

