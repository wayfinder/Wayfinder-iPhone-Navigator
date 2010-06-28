/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AppSession.h"
#import "LocalizationHandler.h"
#import "WFNavigationAppDelegate.h"
#import "PlaceListViewController.h"
#import "BusyViewController.h"
#import "PlaceTableViewCell.h"
#import "SplitMapViewController.h"
#import "PlaceDetailViewController.h"
#import "RouteOverviewViewController.h"
#import "IPhoneOverlayInterface.h"
#import "EAGLView.h"
#import "SearchQuery.h"
#import "FavouritePlace.h"
#import "MapDrawingInterface.h"

#import "OverlayItemZoomSpec.h"
#import "OverlayItemVisualSpec.h"
#import "IPhoneFactory.h"
#import "OverlayInterface.h"
#import "OverlayItem.h"

#import "ErrorHandler.h"
#import "FavouriteStatusCode.h"

#import "HudOverlayViewController.h"
#import "Formatter.h"

@implementation PlaceListViewController

@synthesize bottomBar;
@synthesize placeDataSource;
@synthesize resultDisplayType;
@synthesize contentViewController;
@synthesize busyViewController;
@synthesize placeTableViewController;
@synthesize categoryTableViewController;
@synthesize countryTableViewController;
@synthesize contentView;
@synthesize results;
@synthesize sortedResults;
@synthesize addressMode;
@synthesize viewVisible;
@synthesize firstTime;
//@synthesize mapLayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		aroundMeStyle = NO;
		addressMode = NO;
		firstTime = YES;
		viewVisible = NO;
	}
	
//	self.mapLayer = [APP_SESSION.overlayInterface newLayer];
	
	return self;
}

- (void)registerPlaceDataSource:(PlaceDataSource *)pdc {
	[placeDataSource removeDataChangeListener:self];
	self.placeDataSource = nil;
	self.placeDataSource = pdc;
	[self.placeDataSource addDataChangeListener:self];
	self.title = self.placeDataSource.dataSourceType;
}

- (void)dataRefreshed:(NSArray *)updatedPlaces {
	if (!resultsReady) {
		// If loading activity indicator is not shown or there are some updates
		if ([updatedPlaces count] > 0) {
			[self.busyViewController.view removeFromSuperview];
		}
		
		if (![self.busyViewController.view superview]) {
			self.placeTableViewController.tableView.bounds = self.contentView.bounds;
			self.placeTableViewController.tableView.frame = self.contentView.frame;
			[self.contentView addSubview:self.placeTableViewController.tableView];
			resultsReady = YES;
			// the default view is the list one
			[self.resultDisplayType setSelectedSegmentIndex:SEGMENT_LIST];
		}
	}
	
	self.results = [NSMutableArray arrayWithArray:updatedPlaces];

//	[self.mapLayer reset];
	
//	[self.mapLayer addItems:updatedPlaces aroundMe:aroundMeStyle showOnMap:YES];
	[self refreshResultsDisplays];

//	[self setMapProperties];
}

- (void)placeFetchingCompleted {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];	
	if (self.firstTime && self.viewVisible && self.addressMode && [self.results count] == 1) {
		self.firstTime = NO;
		self.viewVisible = NO;
		[self showRouteOverviewForPlace:[sortedResults objectAtIndex:0]];
	}
}

- (void)noPlacesAvailableTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:[LocalizationHandler getString:@"iPh_ok_tk"] otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)placeFetchingCancelled {
	NSLog(@"Place fetching cancelled...");
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navController popViewControllerAnimated:YES];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];	
}

- (void)coreErrorWithStatus:(AsynchronousStatus *)status {
	if (status->getStatusCode() == FAILED_ADD_FAVOURITE) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[LocalizationHandler getString:@"iPh_error_txt"]
														message:[LocalizationHandler getString:@"iPh_unable_2_add_2_my_places_txt"]
													   delegate:nil
											  cancelButtonTitle:[LocalizationHandler getString:@"iPh_ok_tk"]
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)refreshResultsDisplays {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:(aroundMeStyle ? @"distanceInMeters" : @"title") ascending:YES];
	self.sortedResults = [self.results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	[self.placeTableViewController.tableView reloadData];
}

- (void)loadingStarted {
	[self.contentView addSubview:self.busyViewController.view];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	resultsReady = NO;
}

- (void)setUseAroundMeStyle:(BOOL)useAroundMeStyle {
	aroundMeStyle = useAroundMeStyle;
}
- (void)viewDidLoad {
	self.bottomBar.hidden = YES;
	resultsReady = NO;
	self.title = self.placeDataSource.dataSourceType;
	if (self.results == nil) {
		NSMutableArray *res = [[NSMutableArray alloc] init];
		self.results = res;
		[res release];
	}
	UITableViewController *tblController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	self.placeTableViewController = tblController;
	[tblController release];
	BusyViewController *bc = [[BusyViewController alloc] initWithNibName:@"BusyView" bundle:nil];
	self.busyViewController = bc;
	[bc release];
	[self.placeTableViewController.tableView setDelegate:self];
	[self.placeTableViewController.tableView setDataSource:self];
	self.contentViewController = self.placeTableViewController;
	[self.resultDisplayType setTitle:[LocalizationHandler getString:@"iPh_map_tk"] forSegmentAtIndex:0];
	[self.resultDisplayType setTitle:[LocalizationHandler getString:@"iPh_list_tk"] forSegmentAtIndex:1];
	[self.contentView addSubview:self.busyViewController.view];
	[super viewDidLoad];
}
/*
- (void)setMapProperties
{
	// Reset values
	APP_SESSION.glView.needsToSetWorldBox = NO;
	APP_SESSION.glView.needsToSetUsersPosition = NO;
	
	APP_SESSION.glView.centerUserPosition = NO;
	//	APP_SESSION.glView.usersPosition = APP_SESSION.locationManager->currentPosition;
	[APP_SESSION.glView setNeedsSetUsersPosition:APP_SESSION.locationManager->currentPosition];
	APP_SESSION.glView.panningEnabled = YES;
	APP_SESSION.glView.zoomingEnabled = YES;
	APP_SESSION.glView.use3DMap = NO;
	APP_SESSION.glView.indicatorType = currentPositionNonGPS;	

	if (self.mapLayer.firstCorner.latDeg < 10000) {
		WGS84Coordinate mapCenter((self.mapLayer.firstCorner.latDeg+self.mapLayer.secondCorner.latDeg)/2, (self.mapLayer.firstCorner.lonDeg+self.mapLayer.secondCorner.lonDeg)/2);
		APP_SESSION.glView.mapsCenter = mapCenter;
		if ([self.results count] > 1) {
			[APP_SESSION.glView setNeedsSetWorldBoxToFirstCoord:self.mapLayer.firstCorner secondCoord:self.mapLayer.secondCorner];
			NSLog(@"setWorldBox:(%f, %f)-(%f,%f)", self.mapLayer.firstCorner.latDeg, self.mapLayer.firstCorner.lonDeg, self.mapLayer.secondCorner.latDeg, self.mapLayer.secondCorner.lonDeg);
		} else {
			APP_SESSION.glView.mapsCenter = self.mapLayer.firstCorner;
		}
	} else {
		APP_SESSION.glView.zoomLevel = 10;
	}
}
*/
- (void)viewWillAppear:(BOOL)animated {
//	[self.mapLayer setHidden:NO];
//	[self.mapLayer addItems:self.results aroundMe:aroundMeStyle showOnMap:YES];
	[self refreshResultsDisplays];

//	[self setMapProperties];
	
	[APP_SESSION.locationManager.iPhoneLocationInterface setLocationHandler:self];	

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// Suppose for starters that the controlled view dissap. to the left, meaning that 'Back' button wasn't hit
	_controllerDissapearedToTheLeft = NO;
	self.viewVisible = YES;

	[placeDataSource viewReadyForData];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.viewVisible = NO;

	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(false);

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if (!_controllerDissapearedToTheLeft) {
		// View dissapeared to the right, meaning that 'Back' was hit
		[placeDataSource removeDataChangeListener:self];
	}
	
//	[self.mapLayer setHidden:YES];
	[APP_SESSION.locationManager.iPhoneLocationInterface removeLocationHandler:self];

	[super viewDidDisappear:animated];
}

- (IBAction)segmentedControlHandler:(id)sender {
	NSInteger selectedSegmentIndex = resultDisplayType.selectedSegmentIndex;
	self.contentViewController = nil;
	
	if (selectedSegmentIndex == SEGMENT_MAP) {
		[self removeMyPositionButton];
		[self addMyPositionButton];
		
		SplitMapViewController *split = [[SplitMapViewController alloc] initWithNibName:@"SplitMapView" bundle:nil];
		self.contentViewController = split;
		[split release];

		[APP_SESSION moveMapViewToNewParent:self.contentView use3DMode:NO shouldSetMapDrawing:YES];

//		APP_SESSION.mapLibAPI->getMapOperationInterface()->zoom(1.1);		
//		ScreenPoint centerPt = ScreenPoint(CGRectGetHeight(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
//		WGS84Coordinate centerCoord = operationInterface->getCenter();
//		APP_SESSION.mapLibAPI->getMapOperationInterface()->zoom(1.1, centerCoord, centerPt);
	}
	else if (selectedSegmentIndex == SEGMENT_LIST) {
		[self removeMyPositionButton];
		
		self.contentViewController = self.placeTableViewController;
		[self.contentView addSubview:self.placeTableViewController.tableView];
		[self refreshResultsDisplays];
	}
}

- (void)addMyPositionButton {
	NSMutableArray *items = [bottomBar.items mutableCopy];
	[items insertObject:myPositionButton atIndex:0];
	bottomBar.items = items;
	[items release];
}

- (void)removeMyPositionButton {
	NSMutableArray *items = [bottomBar.items mutableCopy];
	[items removeObject: myPositionButton];
	bottomBar.items = items;
	[items release];
}

- (void)dealloc {
//	self.mapLayer = nil;
	self.resultDisplayType = nil;
	self.placeTableViewController = nil;
	self.contentViewController = nil;
	self.busyViewController = nil;
	self.categoryTableViewController = nil;
	self.countryTableViewController = nil;
	self.contentView = nil;
	self.results = nil;
	self.sortedResults = nil;
	self.bottomBar = nil;
	self.placeDataSource = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark Table Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SearchResultCellIdentifier = @"PlaceCellIdentifier";
	PlaceTableViewCell *cell = (PlaceTableViewCell *)[tableView dequeueReusableCellWithIdentifier: SearchResultCellIdentifier];
	
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaceTableViewCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	NSUInteger row = indexPath.row;
	PlaceBase *current = [sortedResults objectAtIndex:row];
	cell.title.text = current.title;
	cell.subTitle.text = current.subTitle;

	// Dynamically format the distance based on the distance in meter in order to be up to date with the currently set unit
	cell.distance.text = (aroundMeStyle ? [Formatter formatDistance:current.distanceInMeters] : @"");
	if (current.image != nil) {
//		if ([current isKindOfClass:FavouritePlace.class]) {
			[cell.imageView setImage:[ImageFactory getOrFetchImageNamed:current.image andSetImageHandler:self]];
//		}
//		else {
//			[cell.imageView setImage:[ImageFactory getImageNamed:current.image]];
//		}
	}
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (sortedResults == nil ? 0 : [sortedResults count]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = indexPath.row;
	PlaceBase *res = [sortedResults objectAtIndex:row];

	if (self.addressMode) {
		[self showRouteOverviewForPlace:res];
	}
	else {
		PlaceDetailViewController *pdc = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
		[res prepareDetailsForViewController:pdc];
		
		WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
		UINavigationController *ctrl = appDelegate.navController;
		
		_controllerDissapearedToTheLeft = YES;
		
		[ctrl pushViewController:pdc animated:YES];
		[pdc release];
	}
}

- (void)showRouteOverviewForPlace:(PlaceBase *)place {
	RouteOverviewViewController *routeOverviewViewController = 
	[[RouteOverviewViewController alloc] initWithNibName:@"RouteOverview" bundle:[NSBundle mainBundle]];
	
	routeOverviewViewController.place = place;
	
	_controllerDissapearedToTheLeft = YES;
	
	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *navCtrl = delegat.navController;
	
	[navCtrl pushViewController:routeOverviewViewController animated:YES];			
	[routeOverviewViewController release];										
}	
	

#pragma mark -
#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark LocationHandler Methods

- (void)positionUpdated {
	if(APP_SESSION.locationManager.iPhoneLocationInterface.gpsLocationIsAvailable) {
		APP_SESSION.glView.indicatorType = currentPositionGPS;
	}
	else {
		APP_SESSION.glView.indicatorType = currentPositionNonGPS;	
	}
}

- (void)locationBasedServiceStarted {
	
}

// NOTE: errorWithStatus is never invoked on ImageHandlers - errors go directly to ErrorHandler::handleErrorWithStatus...
- (void)errorWithStatus:(AsynchronousStatus *)status {
	NSLog(@"his should not be invoked...");
//	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
}

- (IBAction)myPositionButtonPressed:(id)sender
{
	APP_SESSION.glView.centerUserPosition = YES;
	[APP_SESSION.locationManager.iPhoneLocationInterface requestLocationBasedReverseGeocodingAndSetGeocodingHandler:self];
}
	
#pragma mark -
#pragma mark GeocodingHandler Methods

- (void)reverseGeocodingReady:(GeocodingInformation *)geocodingInformation {
	NSArray *formatted = [Formatter formatGeocodingInformationToTwoLines:geocodingInformation];
	
	HudOverlayViewController *cntrl = [[HudOverlayViewController alloc] initWithNibName:@"HudOverlayView" bundle:[NSBundle mainBundle]];

	// TODO(Fabian): This line is a possible crash cause: 'self' object might get dealloced in HUD_DISPLAY_TIME seconds
	[self performSelector:@selector(timeOutOnHudView:) withObject:cntrl afterDelay:HUD_DISPLAY_TIME];
	[self.view.superview addSubview:cntrl.view];
	
	cntrl.AddressLinie1Label.text = [formatted objectAtIndex:0];
	cntrl.AddressLinie2Label.text = [formatted objectAtIndex:1];		
	[cntrl release];
}

#pragma mark -
#pragma mark ImageHandler Methods
- (void)imageReplyForImageNamed:(NSString *)imageName {
	[placeDataSource refreshData];
}

- (void)imageReplyForImageNamed:(NSString *)imageName imageData:(ImageReplyData *)imageReplyData {
	[placeDataSource refreshData];
}

- (void)timeOutOnHudView:(id)object
{
	HudOverlayViewController *cntrl = (HudOverlayViewController *)object;
	UIView *hudView = cntrl.view;
	
	[hudView removeFromSuperview];
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
