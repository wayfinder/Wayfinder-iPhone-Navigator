/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "LocalizationHandler.h"
#import "IPNavSettingsAccountViewController.h"
#import "IPNavInputTableViewCell.h"
#import "IPNavSwitchTableViewCell.h"

#import "IPNavSettingsManager.h"

@implementation IPNavSettingsAccountViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (!self) return nil;
	
	_settingsManager = [IPNavSettingsManager sharedInstance];
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [LocalizationHandler getString:@"iPh_account_sett_txt"];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (0 == section) ? 1 : 2; 
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (0 == indexPath.section) {
		cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
		NSDictionary *settingInfo = [_settingsManager infoForSettingType:IPNavAccountStatus];
		[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
	} else if (1 == indexPath.section) {
		if (0 == indexPath.row) {
			cell = [[[IPNavInputTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
			NSDictionary *settingInfo = [_settingsManager infoForSettingType:IPNavAccountUsername];
			[[(IPNavInputTableViewCell *)cell inputTextField] setPlaceholder:@"Enter username"];
			[(IPNavInputTableViewCell *)cell updateWithSettingInfo:settingInfo];
		} else {
			cell = [[[IPNavInputTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
			NSDictionary *settingInfo = [_settingsManager infoForSettingType:IPNavAccountPassword];
			[[(IPNavInputTableViewCell *)cell inputTextField] setPlaceholder:@"Enter password"];
			[[(IPNavInputTableViewCell *)cell inputTextField] setSecureTextEntry:YES];
			[(IPNavInputTableViewCell *)cell updateWithSettingInfo:settingInfo];
			
		}
	}
	
    return cell;
}

- (void)dealloc {
    [super dealloc];
}


@end

