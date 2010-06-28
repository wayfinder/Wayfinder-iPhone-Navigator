/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPNavSettingsTableViewController.h"
#import "RouteOverviewViewController.h"
#import "RouteInfoItemArray.h"
#import "MapLibAPI.h"
#import "Nav2API.h"
#import "IPNavSettingsManager.h"
#import "MapDrawingInterface.h"
#import "ConfigInterface.h"
#import "MapOperationInterface.h"
#import "RouteInterface.h"
#import "RouteInfoItem.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "NavigationViewController.h"
#import "IPNavMainSettingsController.h"
#import "WFNavigationAppDelegate.h"
#import "Formatter.h"
#import "Route.h"
#import "ErrorHandler.h"
#import "BillingInterface.h"
#import "RouteStatusCode.h"

@implementation RouteOverviewViewController

@synthesize homeTabBarItem;
@synthesize navigateStartTabBarItem;
@synthesize settingsTabBarItem;
@synthesize estimatedTimeLiteralLabel;
@synthesize estimatedTimeLabel;
@synthesize distanceLiteralLabel;
@synthesize distanceLabel;
@synthesize busyViewController;
@synthesize place;
@synthesize selectionStr;
@synthesize productId;
@synthesize newSubscriptionRequired;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
	self.title = [LocalizationHandler getString:@"iPh_route_overview_txt"];
	self.estimatedTimeLiteralLabel.text = [LocalizationHandler getString:@"iPh_total_time_txt"];
	self.estimatedTimeLabel.text = [LocalizationHandler getString:@"iPh_minutes_txt"];
	self.distanceLiteralLabel.text = [LocalizationHandler getString:@"iPh_distance_txt"];
	self.distanceLabel.text = [LocalizationHandler getString:@"iPh_kilometres_txt"];
	
	self.navigateStartTabBarItem.title = [LocalizationHandler getString:@"iPh_start_nav_tk"];	
	
	BusyViewController *busyView = [[BusyViewController alloc] initWithNibName:@"BusyView" bundle:nil];
	self.busyViewController = busyView;
	[busyView release];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationPortrait == interfaceOrientation;	
}

- (void)zoomToDisplayFullRoute {
	if([APP_SESSION.navigationManager hasRoute]) {
		WGS84Coordinate firstCorner = APP_SESSION.navigationManager.currentRoute->bbLeftBottomCorner;
		WGS84Coordinate secondCorner = APP_SESSION.navigationManager.currentRoute->bbRightTopCorner;		
		
		MapLibAPI *mapLib = APP_SESSION.mapLibAPI;	
		MapOperationInterface *mapOperationInterface = mapLib->getMapOperationInterface();
		mapOperationInterface->setWorldBox(firstCorner, secondCorner);
		mapOperationInterface->setZoomLevel(mapOperationInterface->getZoomLevel() * 1.5);	
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIView *mapContentView = [self.view viewWithTag:100];
	[self zoomToDisplayFullRoute];
	
	[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:NO shouldSetMapDrawing:NO];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	
	if ([_checkGPSSignalTimer isValid]) {
		[_checkGPSSignalTimer invalidate];
	}
	
	[_checkGPSSignalTimer release];
	[_waitForGPSAlert release];
	
	self.selectionStr = nil;															
	self.productId = nil;

	self.homeTabBarItem = nil;
	self.navigateStartTabBarItem = nil;
	self.settingsTabBarItem = nil;
	self.estimatedTimeLiteralLabel = nil;
	self.estimatedTimeLabel = nil;
	self.distanceLiteralLabel = nil;
	self.distanceLabel = nil;	
	self.busyViewController = nil;	
	self.place = nil;	

	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	NSString *msgs = [LocalizationHandler getString:@"[iPh_calc_route_txt]"];
	[self.busyViewController setBusyMessage:msgs];

	[self.view.superview addSubview:self.busyViewController.view];	
	
	UIView *mapContentView = [self.view viewWithTag:EAGLVIEW_TAG];
	[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:NO shouldSetMapDrawing:YES];
	
	[APP_SESSION.locationManager.iPhoneLocationInterface setLocationHandler:self];
	
	APP_SESSION.glView.needsToSetWorldBox = NO;
	APP_SESSION.glView.needsToSetUsersPosition = NO;
	APP_SESSION.glView.usersPosition = APP_SESSION.locationManager->currentPosition;
	APP_SESSION.glView.panningEnabled = NO;
	APP_SESSION.glView.zoomingEnabled = NO;
	APP_SESSION.glView.centerUserPosition = NO;
	APP_SESSION.glView.use3DMap = NO;
	APP_SESSION.glView.zoomLevel = 10;
	APP_SESSION.glView.indicatorType = currentPositionGPS;	
	
	[ErrorHandler sharedInstance].displayErrorMessage = NO;
	
	Position *position = [[Position alloc] initWithWGS84Coordinate:self.place->position];
	Transportation *transport = [[Transportation alloc] initWithType:CAR];
	[APP_SESSION.navigationManager.iPhoneNavigationInterface routeFromCurrentPositionTo:position withTransportation:transport andSetRouteHandler:self];			

	[transport release];
	
	BOOL hasGPSsignal = APP_SESSION.locationManager.iPhoneLocationInterface.gpsLocationIsAvailable;	
	if (!hasGPSsignal) {
		
		// inform the user that we need GPS Signal
		_waitForGPSAlert =[[UIAlertView alloc] initWithTitle:[LocalizationHandler getString:@"[iPh_waiting_for_gps_title]"]
													 message:@"\n"  
													delegate:self 
										   cancelButtonTitle:[LocalizationHandler getString:@"iPh_cancel_tk"]
										   otherButtonTitles:nil];
		
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(123, 45, 37, 37)];//ActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[spinner startAnimating];
		[_waitForGPSAlert addSubview:spinner];
		[spinner release];	
		[_waitForGPSAlert show];
		
		// setup a timer to check for gps signal
		_checkGPSSignalTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkGPSSignal) userInfo:nil repeats:YES];
	}
	
	[position release];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(false);
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[ErrorHandler sharedInstance].displayErrorMessage = YES;	
	
	[APP_SESSION.locationManager.iPhoneLocationInterface removeLocationHandler:self];
	[APP_SESSION.navigationManager.iPhoneNavigationInterface removeAllRequestsForRouteHandler:self];

	// Remove the busy indicator view	
	APP_SESSION.glView.mapsCenter = APP_SESSION.glView->usersPosition; 
	[self.busyViewController.view removeFromSuperview];
	
	[super viewDidDisappear:animated];
}

- (void)checkGPSSignal {
	BOOL hasGPSsignal = APP_SESSION.locationManager.iPhoneLocationInterface.gpsLocationIsAvailable;	
	if (hasGPSsignal) {
		[_checkGPSSignalTimer invalidate];
		if (_waitForGPSAlert && [_waitForGPSAlert isVisible]) {
			[_waitForGPSAlert dismissWithClickedButtonIndex:0 animated:YES];
		}
		[self.busyViewController.view removeFromSuperview];
	}
}

- (IBAction)homeButtonPressed:(id)sender {
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	[navController popToRootViewControllerAnimated:YES];
}


- (IBAction)startNavigationButtonPressed:(id)sender {

	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	NavigationViewController *navigationViewController = [[NavigationViewController alloc] initWithNibName:@"NavigationView" bundle:[NSBundle mainBundle]];
	
	UINavigationController *navCtrl = delegat.navController;	
	[navCtrl pushViewController:navigationViewController animated:YES];			
	navCtrl.navigationBarHidden = YES;
	
	UIView *mapContentView = [navigationViewController.view viewWithTag:EAGLVIEW_TAG];
	[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:YES shouldSetMapDrawing:YES];
	[APP_SESSION.glView setPanningEnabled:NO];
	APP_SESSION.glView.needsToSetWorldBox = NO;
	APP_SESSION.glView.needsToSetUsersPosition = NO;
		
	navigationViewController.resumedNavigation = NO;
	
	// Force yet another redraw 	
	MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();
	mapDrawingInterface->requestRepaint();	
		
	// We are now navigating
	APP_SESSION.navigationManager.currentRoute.isNavigating = YES;
	
	[navigationViewController release];	
}

- (IBAction)settingButtonPressed:(id)sender {
	IPNavSettingsTableViewController *settingsController = [[IPNavSettingsTableViewController alloc] init];
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	[navController pushViewController:settingsController animated:YES];
	[settingsController release];	
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	// NOTE: non-routing errors are handled in the RouteInterface where they are redirected to the ErrorHandler.
	
	if (_waitForGPSAlert && [_waitForGPSAlert isVisible]) {
		return;
	}
	
	NSString *errorMsg = @"";
	if (TOO_FAR_FOR_VEHICLE == status->getStatusCode() || PROBLEM_WITH_DEST == status->getStatusCode()) {
		errorMsg = [LocalizationHandler getString:@"iPh_route_cant_b_calc_2_req_pos_txt"];		
	}
	else if (PROBLEM_WITH_ORIGIN == status->getStatusCode()) {
		errorMsg = [LocalizationHandler getString:@"iPh_route_cant_b_calc_from_ur_pos_txt"];
	}
	else if (ROUTE_INVALID == status->getStatusCode()) {
		errorMsg = [LocalizationHandler getString:@"iPh_route_invalid_txt"];
	}
	else if (NO_GPS_WARN == status->getStatusCode()) {
		errorMsg = [LocalizationHandler getString:@"[no_gps_signal]"];
	}
	else if (NO_ROUTE_FOUND == status->getStatusCode()) {
		errorMsg = [LocalizationHandler getString:@"[no_route_found]"];
	}
	else {
		errorMsg = [LocalizationHandler getString:@"[route_unknown_fail]"];
	}
	UIAlertView *routeAlertView = [[UIAlertView alloc] initWithTitle:[LocalizationHandler getString:@"[iPh_routing_failed_tk]"]
															 message:errorMsg
															delegate:self 
												   cancelButtonTitle:[LocalizationHandler getString:@"iPh_ok_tk"]
												   otherButtonTitles:nil];
	[routeAlertView setCancelButtonIndex:0];	
	[routeAlertView show];	
	[routeAlertView release];		
}

#pragma mark -
#pragma mark RouteHandler Methods

- (void)requestedRouteFromOrigin:(WGS84Coordinate)start to:(WGS84Coordinate)destination withTransportation:(TransportationType) transportationType {

}

- (void)routeReply {
	[ErrorHandler sharedInstance].displayErrorMessage = YES;	

	MapLibAPI *mapLib = APP_SESSION.mapLibAPI;
	
	// And zoom the map to view both staring point end finishing point
	[self zoomToDisplayFullRoute];
	
	RouteInterface &routeInterface = APP_SESSION.nav2API->getRouteInterface();
	
	// And the we need to opdate the distance and estimated time
	RouteInfoItemArray routeInfos;
	routeInterface.getRouteList(routeInfos);
	if(routeInfos.size() > 0) {
		RouteInfoItem &routeInfo = routeInfos.front();
		unsigned int distance = routeInfo.getDistanceToGoal();
		[self.distanceLabel setText:[Formatter formatDistance:distance]];	
		unsigned int time = routeInfo.getTimeToGoal();
		[self.estimatedTimeLabel setText:[Formatter formatTime:time]];			
	}

	[self zoomToDisplayFullRoute];
	
	// Remove the busy view anyway
	[self.busyViewController.view removeFromSuperview];

	// (Fix for #10702) Commented the GPS signal test because in the case when the signal has been lost while the route was coming back from the server the busy view would remain on screen
	BOOL hasGPSsignal = APP_SESSION.locationManager.iPhoneLocationInterface.gpsLocationIsAvailable;	
	
	if (hasGPSsignal) {
		// Remove the "waiting for gps" alert only if we have signal
		if (_waitForGPSAlert && [_waitForGPSAlert isVisible]) {
			[_waitForGPSAlert dismissWithClickedButtonIndex:0 animated:YES];
		}
	}
	
	// Force a redraw now that we have a route
	MapDrawingInterface *mapDrawingInterface = mapLib->getMapDrawingInterface();
	mapDrawingInterface->requestRepaint();	
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

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
#ifndef REQUIRE_GPS_FIX_FOR_ROUTING
	if (_waitForGPSAlert == alertView) {
		[self.busyViewController.view removeFromSuperview];
		return;
	}
#endif
	
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	[navController popViewControllerAnimated:YES];	

}

- (void)requestCancelled:(NSNumber *)requestID {
	// (Fix for #10702). In case the request to reconnect the network connection was "Cancel" (instead of Retry") we should not let the busy view with the spinner to remain on screen
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	[navController popViewControllerAnimated:YES];	
}

@end
