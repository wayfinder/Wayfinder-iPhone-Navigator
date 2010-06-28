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
#import "IPNavSettingsTableViewController.h"
#import "IPNavSwitchTableViewCell.h"
#import "IPNavSelectValueTableViewCell.h"
#import "IPNavMultiValuesTableViewController.h"
#import "IPNavSettingsAccountViewController.h"
#import "IPNavCategoriesTableViewController.h"
#import "IPNavInputTableViewCell.h"
#import "IPNavNumericInputTableViewCell.h"
#import "IPNavSettingsManager.h"

#import "IPNavSettingsManager.h"

@implementation IPNavSettingsTableViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (!self) return nil;
	
	// load settings
	_settingsManager = [IPNavSettingsManager sharedInstance];
	
	// register to notifications posted by settings manager
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView 
											 selector:@selector(reloadData) 
												 name:@"settingsChanged" 
											   object:_settingsManager];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadSection:) 
												 name:@"settingsChangedInSection" 
											   object:_settingsManager];
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// set controller title
	self.title = [LocalizationHandler getString:@"iPh_settings_txt"];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

// Override to allow orientations other than the default portrait orientation.
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

- (void)latitudeUpdated:(UITextField *)field {
	NSString *value = field.text;
	[_settingsManager setLatitude:[value floatValue]];
}

- (void)longitudeUpdated:(UITextField *)field {
	NSString *value = field.text;
	[_settingsManager setLongitude:[value floatValue]];	
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(ENABLE_DEBUG_SETTINGS) {
		return 4; // there are 4 settings sections (General, Route, Map and Debug)
	}
	else {
		return 3;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numberOfRows = 0;
	
	switch (section) {
		case IPNavSettingsSectionGeneral:
			// if GPS connection is off we do not need to show other related settings
			numberOfRows = 2;
			break;
		case IPNavSettingsSectionRoute:
			numberOfRows = 4;
			break;
		case IPNavSettingsSectionMap:
			numberOfRows = 2;
			break;	
		case IPNavSettingsSectionDebug: {
			IPNavSettingsManager *manager = [IPNavSettingsManager sharedInstance];
			if([manager useExplicitPosition]) {
				numberOfRows = 5;
			}
			else {
				numberOfRows = 3;
			}
			break;
		}
		default:
			break;
	}
	
	return numberOfRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"cellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// get info for cell
	NSDictionary *settingInfo = nil;
	
	if (IPNavSettingsSectionGeneral == indexPath.section) {
		switch (indexPath.row) {
			case 0:
				settingInfo = [_settingsManager infoForSettingType:IPNavDistanceUnits];
				cell = [[[IPNavSelectValueTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSelectValueTableViewCell *)cell updateWithSettingInfo:settingInfo];
				break;
			case 1:
				settingInfo = [_settingsManager infoForSettingType:IPNavSpeedZoom];
				cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
				[[(IPNavSwitchTableViewCell *)cell valueSwitch] addTarget:_settingsManager 
																   action:@selector(enableSpeedZoomChanged:) 
														 forControlEvents:UIControlEventValueChanged];
				break;
			default:
				break;
		}
	} else if (IPNavSettingsSectionRoute == indexPath.section) {
		switch (indexPath.row) {
			case 0:
				settingInfo = [_settingsManager infoForSettingType:IPNavRouteOptimisation];
				cell = [[[IPNavSelectValueTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSelectValueTableViewCell *)cell updateWithSettingInfo:settingInfo];
				break;
			case 1:
				settingInfo = [_settingsManager infoForSettingType:IPNavVoicePrompts];
				cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
				[[(IPNavSwitchTableViewCell *)cell valueSwitch] addTarget:_settingsManager 
																   action:@selector(voicePromptsChanged:) 
														 forControlEvents:UIControlEventValueChanged];
				break;
			case 2:
				settingInfo = [_settingsManager infoForSettingType:IPNavUseTollRoads];
				cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
				[[(IPNavSwitchTableViewCell *)cell valueSwitch] addTarget:_settingsManager 
																   action:@selector(useTollRoadsChanged:) 
														 forControlEvents:UIControlEventValueChanged];
				break;
			case 3:
				settingInfo = [_settingsManager infoForSettingType:IPNavUseMotorway];
				cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
				[[(IPNavSwitchTableViewCell *)cell valueSwitch] addTarget:_settingsManager 
																   action:@selector(useMotorwayChanged:) 
														 forControlEvents:UIControlEventValueChanged];
				break;
			case 4:
			default:
				break;
		}
	} else if (IPNavSettingsSectionMap == indexPath.section) {
		switch (indexPath.row) {
			case 0:
				settingInfo = [_settingsManager infoForSettingType:IPNavPOIDownloads];
				cell = [[[IPNavSelectValueTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSelectValueTableViewCell *)cell updateWithSettingInfo:settingInfo];
				break;
			case 1:
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
				[cell.textLabel setText:[LocalizationHandler getString:@"iPh_show_categ_sett_txt"]];
				break;				
			default:
				break;
		}
	}
	else if (IPNavSettingsSectionDebug == indexPath.section) {
		switch (indexPath.row) {
			case 0:
				settingInfo = [_settingsManager infoForSettingType:IPNavDebugExplicitPosition];				
				cell = [[[IPNavSwitchTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSwitchTableViewCell *)cell updateWithSettingInfo:settingInfo];
				[[(IPNavSwitchTableViewCell *)cell valueSwitch] addTarget:_settingsManager 
																   action:@selector(useExplicitUserPosition:) 
														 forControlEvents:UIControlEventValueChanged];
				break;
			case 1:					
				if(![_settingsManager useExplicitPosition]) { 
					settingInfo = [_settingsManager infoForSettingType:IPNavDebugClientType];
					cell = [[[IPNavSelectValueTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
					[(IPNavSelectValueTableViewCell *)cell updateWithSettingInfo:settingInfo];
				}
				else {
					settingInfo = [_settingsManager infoForSettingType:IPNavDebugPositionLatitude];
					cell = [[[IPNavNumericInputTableViewCell alloc] initWithIdentifier:CellIdentifier 
																				target:self 
																				action:@selector(latitudeUpdated:)] autorelease];
					[(IPNavNumericInputTableViewCell *)cell updateWithSettingInfo:settingInfo];									
				}
				break;
			case 2:
				if(![_settingsManager useExplicitPosition]) { 
					UITableViewCell *simpleCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"USERNAME_CELL"] autorelease];
					cell = simpleCell;
					cell.textLabel.text = [NSString stringWithFormat:@"Username: %@", [[IPNavSettingsManager sharedInstance] getUsername]];
				}
				else {
					settingInfo = [_settingsManager infoForSettingType:IPNavDebugPositionLongitude];
					cell = [[[IPNavNumericInputTableViewCell alloc] initWithIdentifier:CellIdentifier 
																				target:self 
																				action:@selector(longitudeUpdated:)] autorelease];
					[(IPNavNumericInputTableViewCell *)cell updateWithSettingInfo:settingInfo];													
				}
				break;
			case 3:	
				settingInfo = [_settingsManager infoForSettingType:IPNavDebugClientType];
				cell = [[[IPNavSelectValueTableViewCell alloc] initWithIdentifier:CellIdentifier] autorelease];
				[(IPNavSelectValueTableViewCell *)cell updateWithSettingInfo:settingInfo];
				break;
			case 4:
				UITableViewCell *simpleCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"USERNAME_CELL"] autorelease];
				cell = simpleCell;
				cell.textLabel.text = [NSString stringWithFormat:@"Username: %@", [[IPNavSettingsManager sharedInstance] getUsername]];
				break;
		}
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	switch (indexPath.section) {
		case IPNavSettingsSectionGeneral:

			if (0 == indexPath.row) {
				IPNavMultiValuesTableViewController *valuesController = [[IPNavMultiValuesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[valuesController  addSettingInfo:[_settingsManager infoForSettingType:IPNavDistanceUnits]
										  target:_settingsManager 
										selector:@selector(setDistanceUnitType:)];
				[valuesController setTitle:[LocalizationHandler getString:@"iPh_distance_units_sett_txt"]];
				[[self navigationController] pushViewController:valuesController animated:YES];
				[valuesController release];				
			}
			break;
		case IPNavSettingsSectionRoute:
			if (0 == indexPath.row) {
				IPNavMultiValuesTableViewController *valuesController = [[IPNavMultiValuesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[valuesController addSettingInfo:[_settingsManager infoForSettingType:IPNavRouteOptimisation] 
										 target:_settingsManager 
									   selector:@selector(setRouteOptimisationType:)];
				[valuesController setTitle:[LocalizationHandler getString:@"iPh_route_optimisation_txt"]];
				[[self navigationController] pushViewController:valuesController animated:YES];
				[valuesController release];
			} else if (4 == indexPath.row) {
//				IPNavMultiValuesTableViewController *valuesController = [[IPNavMultiValuesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
//				[valuesController addSettingInfo:[_settingsManager infoForSettingType:IPNavTrafficUpdate] 
//										 target:_settingsManager 
//									   selector:@selector(setTrafficUpdatesIntervalType:)];
//				[valuesController setTitle:[LocalizationHandler getString:@"iPh_traffic_updates_txt"]];
//				[[self navigationController] pushViewController:valuesController animated:YES];
//				[valuesController release];
			}
			break;
		case IPNavSettingsSectionMap:
			if (0 == indexPath.row) {
				IPNavMultiValuesTableViewController *valuesController = [[IPNavMultiValuesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[valuesController addSettingInfo:[_settingsManager infoForSettingType:IPNavPOIDownloads] 
										 target:_settingsManager 
									   selector:@selector(setPOIDownloadsType:)];
				[valuesController setTitle:[LocalizationHandler getString:@"iPh_poi_downloads_txt"]];
				[[self navigationController] pushViewController:valuesController animated:YES];
				[valuesController release];
			} else if (1 == indexPath.row) {
				IPNavCategoriesTableViewController *categoriesController = [[IPNavCategoriesTableViewController alloc] init];
				[[self navigationController] pushViewController:categoriesController animated:YES];
				[categoriesController release];
			}
			break;
		case IPNavSettingsSectionDebug:				
			if(((![_settingsManager useExplicitPosition]) && (1 == indexPath.row)) || 
   			   (([_settingsManager useExplicitPosition]) && (3 == indexPath.row))) { 	
				IPNavMultiValuesTableViewController *valuesController = [[IPNavMultiValuesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[valuesController  addSettingInfo:[_settingsManager infoForSettingType:IPNavDebugClientType]
										   target:_settingsManager 
										 selector:@selector(setClientType:)];
				[valuesController setTitle:[LocalizationHandler getString:@"iPh_client_type_sett_txt"]];
				[[self navigationController] pushViewController:valuesController animated:YES];
				[valuesController release];				
			}
			
			break;
		default:
			break;
	}
}

- (void)reloadSection:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSUInteger sectionIndex = [[userInfo objectForKey:@"section"] intValue];

	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
}

@end

