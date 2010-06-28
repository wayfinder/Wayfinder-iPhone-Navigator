/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PlaceDetailViewController.h"
#import "PlaceDetailEditViewController.h"
#import "PlaceDetailTableViewCell.h"
#import "AppSession.h"
#import "WFNavigationAppDelegate.h"
#import "LocalizationHandler.h"
#import "RouteOverviewViewController.h"
#import "PlaceInfoEntry.h"
#import "TransportationType.h"
#import "EAGLView.h"
#import "MapDrawingInterface.h"
#import "Route.h"
#import "FavouritePlace.h"
#import "IPhoneFavouriteInterface.h"
#import "ErrorHandler.h"
#import "MapOperationInterface.h"
#import "OverlayItemMapViewController.h"
#import "FavouriteStatusCode.h"
#import "SearchStatusCode.h"
#import "BusyTableViewCell.h"

#define CHECK_FOR_GPS_SIGNAL_INTERVAL 1.0

typedef enum PlaceDetailActions {
	NavigateTo = 0,
	NearBy = 1,
	ShowOnMap = 2,
	AddRemovePlaces = 3
} PlaceDetailActions;

@implementation PlaceDetailViewController

@synthesize editButton;
@synthesize headerTableView;
@synthesize headerTableViewCell;
@synthesize footerTableView;
@synthesize footerTableViewCell;
@synthesize headerView;
@synthesize footerView;
@synthesize detailsTableView;
@synthesize tabs;
@synthesize altTabs;
@synthesize placeImageView;
@synthesize placeName;
@synthesize placeDistance;
@synthesize placeDescription;
@synthesize placeDescriptionEdit;

@synthesize place;
@synthesize detailsFetched;

@synthesize gpsSignalAlertView;
@synthesize waitingForGpsSignal;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = [LocalizationHandler getString:@"iPh_details_txt"];
	
	editingName = YES;
	self.detailsTableView.tableHeaderView = headerView;
	self.detailsTableView.tableFooterView = footerView;

	UITableViewCell *headerCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44)]; 
	headerCell.textLabel.font = self.placeName.font;
	headerCell.textLabel.text = self.placeName.text;
	headerCell.textLabel.minimumFontSize = self.placeName.minimumFontSize;
	headerCell.textLabel.baselineAdjustment = self.placeName.baselineAdjustment;
	headerCell.textLabel.adjustsFontSizeToFitWidth = self.placeName.adjustsFontSizeToFitWidth;
	headerCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.headerTableViewCell = headerCell;
	[headerCell release];
	self.placeDescriptionEdit.text = self.placeDescription.text;
	
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHandler getString:@"iPh_edit_tk"] style:UIBarButtonItemStylePlain target:self action:@selector(editClicked:)];
	self.editButton = rightBarButtonItem;
	[rightBarButtonItem release];
	
#if 0 // Tab bar element shouldn't have labels	
	NSArray* tabItems = [self.tabs items];
	UITabBarItem *hat = [tabItems objectAtIndex:0];
	hat.title = [LocalizationHandler getString:@"iPh_navigate_to_tk"];
	hat = [tabItems objectAtIndex:1];
	hat.title = [LocalizationHandler getString:@"iPh_show_on_map_tk"];
	hat = [tabItems objectAtIndex:2];
	if ([place isKindOfClass:[SearchResult class]]) {
		hat.title = [LocalizationHandler getString:@"iPh_add_to_tk"];
	}
	else {
		[self navigationItem].rightBarButtonItem = self.editButton;
		hat.title = [LocalizationHandler getString:@"iPh_remove_tk"];
	}
#endif	

//	NSArray* tabItems = [self.tabs items];
//	UITabBarItem *hat = [tabItems objectAtIndex:2];
	if ([place isKindOfClass:[SearchResult class]]) {
//		hat.image = [UIImage imageNamed:@"ToolBar_Add.png"];
	}
	else {
		[self navigationItem].rightBarButtonItem = self.editButton;
		tabs.hidden = YES;
		altTabs.hidden = NO;
//		hat.image = [UIImage imageNamed:@"ToolBar_Remove.png"];
	}
	
	self.headerTableView.delegate = self;
	self.headerTableView.dataSource = self;
	self.headerTableView.hidden = YES;
	self.footerTableView.delegate = self;
	self.footerTableView.dataSource = self;
	self.footerTableView.hidden = YES;
	
	self.waitingForGpsSignal = NO;
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
*/

- (void)viewWillAppear:(BOOL)animated {
	_controllerDissapearedToTheLeft = NO;
	[self refreshView]; 
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (!_controllerDissapearedToTheLeft) {
		// The view will not be dealloced because it dissapeared because another view appeared on top of it.
		[APP_SESSION.searchInterface removeRequestHandler:self];
	}
	[super viewWillDisappear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {

	if (self.place != nil && [self.place isKindOfClass:[FavouritePlace class]]) {
		FavouritePlace *favPlace = (FavouritePlace *)place;
		if (favPlace.placeID == Favourite::INVALID_FAVOURITE_ID) {
			[APP_SESSION.favouriteInterface addFavourite:[favPlace createFavourite]];
		}
	}
	[super viewWillDisappear:animated];
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


- (void)dealloc {
	
	self.editButton = nil;
	self.headerTableView = nil;
	self.headerTableViewCell = nil;
	self.footerTableView = nil;
	self.footerTableViewCell = nil;
	self.headerView = nil;
	self.footerView = nil;
	self.detailsTableView = nil;
	self.tabs = nil;
	self.altTabs = nil;
	self.placeImageView = nil;
	self.placeName = nil;
	self.placeDistance = nil;
	self.placeDescription = nil;
	self.placeDescriptionEdit = nil;
	
	[place release];
    [super dealloc];
}

- (void)refreshView {
	self.placeName.text = self.place.title;
	self.headerTableViewCell.textLabel.text = self.place.title;
	self.placeDistance.text = self.place.supplier;
	UIImage *image = [ImageFactory getImageNamed:self.place.image];
	[self.placeImageView setImage:image];
	CGSize imgSize = image.size;
	CGRect parent = placeImageView.superview.bounds;
	if (imgSize.height <= parent.size.height && imgSize.width <= parent.size.width) {
		self.placeImageView.bounds = CGRectMake((parent.size.height - imgSize.height) / 2, (parent.size.width - imgSize.width) / 2, imgSize.width, imgSize.height);
	}
	else {
		self.placeImageView.bounds = parent;
	}
	
	self.placeDescription.text = self.place.description != nil ? self.place.description : [LocalizationHandler getString:@"iPh_no_descr_avail_txt"];
	self.placeDescriptionEdit.text = self.placeDescription.text;
	self.tabs.selectedItem = nil;
	self.altTabs.selectedItem = nil;
	[self.detailsTableView reloadData];
}
	
- (void)editClicked:(id)sender {
	self.headerTableView.hidden = !self.headerTableView.hidden;
	self.placeName.hidden = !self.headerTableView.hidden;
	self.footerTableView.hidden = self.headerTableView.hidden;
	self.placeDescription.hidden = !self.headerTableView.hidden;
	if (self.headerTableView.hidden) {
		self.editButton.title = [LocalizationHandler getString:@"iPh_edit_tk"];
		self.title = [LocalizationHandler getString:@"iPh_details_txt"];
		[self navigationItem].hidesBackButton = NO;
		self.altTabs.hidden = NO;
		self.detailsTableView.frame = CGRectMake(0, 0, 320, detailsTableView.superview.bounds.size.height - self.tabs.bounds.size.height);
		FavouritePlace *favPlace = (FavouritePlace *)self.place;
		NSInteger favID = [favPlace.placeID intValue];
		if (favID != Favourite::INVALID_FAVOURITE_ID) {
			[APP_SESSION.favouriteInterface deleteFavouriteWithID:favID];
		}
		[APP_SESSION.favouriteInterface addFavourite:favPlace];
		[APP_SESSION.favouriteInterface syncFavouritesAndSetFavouriteHandler:self];
	}
	else {
		self.title = [LocalizationHandler getString:@"iPh_edit_place_txt"];
		self.editButton.title = [LocalizationHandler getString:@"[done_nav_button]"];
		self.detailsTableView.frame = CGRectMake(0, 0, 320, detailsTableView.superview.bounds.size.height);
		[self navigationItem].hidesBackButton = YES;
		self.altTabs.hidden = YES;
	}
	[detailsTableView reloadData];
}

#pragma mark -
#pragma mark Table Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (tableView == headerTableView) {
		cell = headerTableViewCell;
	}
	else if (tableView == footerTableView) {
		cell = footerTableViewCell;
	}
	else if (!detailsFetched) {
		static NSString *BusyTableViewCellIdentifier = @"BusyTableViewCellIdentifier";
		
		cell = [tableView dequeueReusableCellWithIdentifier:BusyTableViewCellIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusyTableViewCell" owner:self options:nil];
			cell = [nib objectAtIndex:0];
			if ([cell isKindOfClass:BusyTableViewCell.class]) {
				BusyTableViewCell *bCell = (BusyTableViewCell *)cell;
				bCell.busyMessage.text = [LocalizationHandler getString:@"iPh_fetching_data_txt"];
			}
		}
		tableView.separatorColor = self.headerTableView.hidden ? [UIColor lightGrayColor] : [UIColor whiteColor];
		cell.backgroundColor = self.headerTableView.hidden ? [UIColor whiteColor] : [UIColor lightGrayColor];
	}
	else {
		if ([self.place.details count] > 0) {
			static NSString *PlaceDetailsTableIdentifier = @"PlaceDetailsTableIdentifier";
	
			cell = [tableView dequeueReusableCellWithIdentifier:PlaceDetailsTableIdentifier];
			PlaceDetailTableViewCell *pdtCell = (PlaceDetailTableViewCell *)cell;
			if (pdtCell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaceDetailTableViewCell" owner:self options:nil];
				pdtCell = [nib objectAtIndex:0];
			}
			PlaceInfoEntry *pie = [self.place.details objectAtIndex:indexPath.row];
			pdtCell.title.text = pie.key;
			pdtCell.value.text = pie.value;
			cell = pdtCell;
		}
		else {
			static NSString *NoDetailsTableIdentifier = @"NoDetailsTableIdentifier";
			
			cell = [tableView dequeueReusableCellWithIdentifier:NoDetailsTableIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: NoDetailsTableIdentifier] autorelease];
			}
			cell.textLabel.text = [LocalizationHandler getString:@"iPh_no_details_avail_txt"];
		}
		tableView.separatorColor = self.headerTableView.hidden ? [UIColor lightGrayColor] : [UIColor whiteColor];
		cell.backgroundColor = self.headerTableView.hidden ? [UIColor whiteColor] : [UIColor lightGrayColor];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == detailsTableView && self.headerTableView.hidden) {
		if ([self.place.details count] > 0) {
			PlaceInfoEntry *pie = [place.details objectAtIndex:indexPath.row];
			if (pie.infoType == URL) {
				NSURL *url = [NSURL URLWithString:pie.value];
				[[UIApplication sharedApplication] openURL:url];
			}
			else if (pie.infoType == PHONE_NUMBER) {
				NSMutableString *phone = [pie.value mutableCopy];
				[phone replaceOccurrencesOfString:@" " 
									   withString:@"" 
										  options:NSLiteralSearch 
											range:NSMakeRange(0, [phone length])];
				[phone replaceOccurrencesOfString:@"(" 
									   withString:@"" 
										  options:NSLiteralSearch 
											range:NSMakeRange(0, [phone length])];
				[phone replaceOccurrencesOfString:@")" 
									   withString:@"" 
										  options:NSLiteralSearch 
											range:NSMakeRange(0, [phone length])];
				[phone replaceOccurrencesOfString:@"-" 
									   withString:@"" 
										  options:NSLiteralSearch 
											range:NSMakeRange(0, [phone length])];
				NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
				[[UIApplication sharedApplication] openURL:url];
				[phone release];
			}		
		}
	}
	else {
		PlaceDetailEditViewController *pdeViewController = nil;
		if (tableView == self.headerTableView) {
			editingName = YES;
			pdeViewController = [[PlaceDetailEditViewController alloc] initWithOwner:self];
		}
		else if (tableView == self.footerTableView) {
			editingName = NO;
			pdeViewController = [[PlaceDetailEditViewController alloc] initWithOwner:self];
		}
		
		_controllerDissapearedToTheLeft = YES;
		
		WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
		UINavigationController *navCtrl = delegat.navController;
		[navCtrl pushViewController:pdeViewController animated:YES];			
		[pdeViewController release];
		
		[tableView deselectRowAtIndexPath:indexPath animated:true];
	}	
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == detailsTableView && self.headerTableView.hidden) {
		if ([self.place.details count] > 0) {
			PlaceInfoEntry *pie = [self.place.details objectAtIndex:indexPath.row];
			return pie.infoType == URL || pie.infoType == PHONE_NUMBER ? indexPath : nil;
		}
		return nil;
	}
	return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return tableView != detailsTableView ? 1 : detailsFetched ? ([place.details count] == 0 ? 1 : [place.details count]) : 1;
}

- (void)navigateTo {
	RouteOverviewViewController *routeOverviewViewController = 
		[[RouteOverviewViewController alloc] initWithNibName:@"RouteOverview" bundle:[NSBundle mainBundle]];
	
	routeOverviewViewController.place = self.place;
	
	_controllerDissapearedToTheLeft = YES;
	
	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *navCtrl = delegat.navController;
	
	[navCtrl pushViewController:routeOverviewViewController animated:YES];			
	[routeOverviewViewController release];										
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

	switch(item.tag) {
		case NavigateTo: {	
			 [self navigateTo];						
			break;
		}
		case ShowOnMap: {
			_controllerDissapearedToTheLeft = YES;
			
			OverlayItemMapViewController *mapViewController = [[OverlayItemMapViewController alloc] initWithOverlayItem:self.place];
			[self.navigationController pushViewController:mapViewController animated:YES];
			[mapViewController release];
			
			MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();
			operationInterface->setCenter([place position]);
			break;
		}			
		case AddRemovePlaces: {
			if ([self navigationItem].rightBarButtonItem == nil) {
				tabs.hidden = YES;
				altTabs.hidden = NO;
				SearchResult *res = (SearchResult *)place;
				Favourite fav = [res createFavourite];
				FavouritePlace *newFav = [[FavouritePlace alloc] initWithFavourite:&fav];
				self.place = newFav;
				[self refreshView];
				[self navigationItem].rightBarButtonItem = self.editButton;
				[APP_SESSION.favouriteInterface addFavourite:newFav];
				[newFav release];
				[APP_SESSION.favouriteInterface syncFavouritesAndSetFavouriteHandler:self];
				tabBar.selectedItem = nil;
			}
			else {
				if (self.place != nil && [self.place isKindOfClass:[FavouritePlace class]]) {
					FavouritePlace *favPlace = (FavouritePlace *)place;
					if (![favPlace.placeID isEqualToString:[NSString stringWithFormat:@"%d", Favourite::INVALID_FAVOURITE_ID]]) {
						[APP_SESSION.favouriteInterface deleteFavouriteWithID:[favPlace.placeID intValue]];
						// The fav. synching is also called in the viewWillAppear method form the PlaceListViewController. That's why the following line is commented out. It seems to fix bug #10675 which might be caused by the fact that two synch requests are sent to the server too close to each other.
//						[APP_SESSION.favouriteInterface syncFavourites];
					}
				}
				
				[self.navigationController popViewControllerAnimated:YES];
			}
			break;
		}
	}
}

#pragma mark -
#pragma mark SearchHandler Methods
- (void)favouritesChanged {
	NSLog(@"Favourites changed...");
}

- (void)favouritesSynced {
	NSLog(@"Favourites synced...");
	NSArray *favs = [APP_SESSION.favouriteInterface getAllFavourites];
	if (self.place != nil && [self.place isKindOfClass:[FavouritePlace class]]) {
		NSString *favID = [NSString stringWithFormat:@"%@", ((FavouritePlace *)self.place).internalFavID];
		for (FavouritePlace *fav in favs) {
			if ([favID isEqualToString:fav.internalFavID]) {
				NSLog(@"Replacing old favourite with updated one!");
				self.place = fav;
				[self refreshView];
			}
		}
	}
}

#pragma mark -
#pragma mark SearchHandler Methods
- (void)searchDetailsReply:(SearchItemArray *)searchItemArray {
	SearchItemArray::iterator it;
	
	NSLog(@"PDC: Item results: %d", searchItemArray->size());
	detailsFetched = true;
	for (it = searchItemArray->begin(); it < searchItemArray->end(); it++) {
		SearchItem item = *it;
		[self logSearchItem:&item];
		SearchResult *newResult = [[SearchResult alloc] initWithSearchItem:&item];
		self.place = newResult;
		[newResult release];
	}
	[self refreshView];
	
	//TODO(Fabian): analyze if we can use 'removeRequestHandler' here. code would be simpler
}

- (void)searchHeadingsSummary:(SearchHeadingArray *)searchHeadingArray {
	
}

- (void)searchHeadingsReply:(SearchHeadingArray *)searchHeadings isFinal:(BOOL)final {
	
}

- (void)searchCategoriesUpdated {
	
}

- (void)topRegionsUpdated {
	
}

- (void)headingImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self refreshView];
	}
}

- (void)categoryImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self refreshView];
	}
}	

- (void)resultImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self refreshView];
	}
}

- (void)errorWithStatus:(AsynchronousStatus *)status {
	if (FAILED_ADD_FAVOURITE == status->getStatusCode()) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[LocalizationHandler getString:@"iPh_error_txt"]
														message:[LocalizationHandler getString:@"iPh_unable_2_add_2_my_places_txt"]
														delegate:nil
											  cancelButtonTitle:[LocalizationHandler getString:@"iPh_ok_tk"]
												otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	// treat as "no details available"
	else if (status->getStatusCode() == UNABLE_TO_RETRIEVE_SEARCH_DETAILS) {
		detailsFetched = true;
		[self refreshView];
	}
	else {
		[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
	}
}

- (void)requestCancelled:(NSNumber *)requestID {
	NSLog(@"Request cancelled - anything we can do here?");
}

- (void)logSearchItem:(SearchItem *)item {
	NSLog(@"PDC:   - (%s)[%d-%d]  @ %s (%s) [%s]", (&item->getID())->c_str(), item->getType(), item->getSubType(), (&item->getLocationName())->c_str(), (item->getDistanceFromSearchPos(WFAPI::KM)).c_str(), (&item->getImageName())->c_str());
}

#pragma mark -
#pragma mark PlaceDetailOwner Methods

- (NSString *)getFieldTitle {
	if (editingName) {
		return [LocalizationHandler getString:@"iPh_name_txt"];
	}
	return [LocalizationHandler getString:@"iPh_description_txt"];
}

- (NSString *)getOriginalValue {
	return editingName ? self.place.title : self.place.description;
}

- (FieldTypes)getFieldType {
	return editingName ? PlainTextField : MultilineTextField;
}

- (void)editCanceled {
	NSLog(@"YAY!");
}

- (void)editDoneWithNewValue:(NSString *)newValue {
	if (editingName) {
		self.place.title = newValue;
	}
	else {
		self.place.description = newValue;
	}
	[self refreshView];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	self.waitingForGpsSignal = NO;
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	self.gpsSignalAlertView = nil;
	
#ifndef REQUIRE_GPS_FIX_FOR_ROUTING
	[self navigateTo];	// Just for testing !!!!!!!!!!
#endif
}
@end
