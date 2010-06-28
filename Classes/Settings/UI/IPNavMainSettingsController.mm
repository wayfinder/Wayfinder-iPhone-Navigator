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
#import "IPNavMainSettingsController.h"
#import "IPNavSettingsAccountViewController.h"
#import "IPNavSettingsTableViewController.h"
#import "IPNavSettingsAboutController.h"

@implementation IPNavMainSettingsController


- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
	
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [LocalizationHandler getString:@"iPh_settings_txt"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}


#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    NSString *cellText = nil;
	switch (indexPath.section) {
		case 0:
			cellText = [LocalizationHandler getString:@"[account_table_cell_text]"];
			break;
		case 1:
			cellText = [LocalizationHandler getString:@"[settings_table_cell_text]"];
			break;
		default:
			break;
	}
	
	[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	[cell.textLabel setText:cellText];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (0 == indexPath.section) {
		IPNavSettingsAccountViewController *accountSettingsController = [[IPNavSettingsAccountViewController alloc] init];
		[self.navigationController pushViewController:accountSettingsController animated:YES];
		[accountSettingsController release];
	} else if (1 == indexPath.section) {
		IPNavSettingsTableViewController *generalSettingsController = [[IPNavSettingsTableViewController alloc] init];
		[self.navigationController pushViewController:generalSettingsController animated:YES];
		[generalSettingsController release];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end

