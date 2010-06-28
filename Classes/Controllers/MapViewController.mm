/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Nav2API.h"
#import "IPhoneSearchListener.h"
#import "LocationInterface.h"
#import "IPNavMainSettingsController.h"
#import "MapViewController.h"
#import "SearchViewController.h"
#import "WFNavigationAppDelegate.h"
#import "EAGLView.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "IPNavMainSettingsController.h"
#import "GeocodingListener.h"
#import "HudOverlayViewController.h"
#import "NavigationSelectionViewController.h"
#import "Formatter.h"
#import "ErrorHandler.h"
#import "MapDrawingInterface.h"

using namespace WFAPI;

@implementation MapViewController

@synthesize myPositionBarButtonItem;

- (void)dealloc {
	self.myPositionBarButtonItem = nil;
    [super dealloc];	
}

- (void)viewDidLoad {
	[super viewDidLoad];	
	self.title = [LocalizationHandler getString:@"iPh_map_txt"];
	self.myPositionBarButtonItem.title = [LocalizationHandler getString:@"iPh_my_position_txt"];
}

- (void)viewDidUnload {
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	UIView *searchBarView = [self.view viewWithTag:110];
	[searchBarView setNeedsLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIView *mapContentView = [self.view viewWithTag:100];
	CGRect rect1 = self.view.frame;
	CGRect rect2 = mapContentView.frame;
	[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:NO shouldSetMapDrawing:NO];		
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)myPositionButtonPressed:(id)sender {
	APP_SESSION.glView.centerUserPosition = YES;
	[APP_SESSION.locationManager.iPhoneLocationInterface requestLocationBasedReverseGeocodingAndSetGeocodingHandler:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	UIView *contentView = [self.view viewWithTag:EAGLVIEW_TAG];

	[APP_SESSION moveMapViewToNewParent:contentView use3DMode:NO shouldSetMapDrawing:YES];

	APP_SESSION.glView.needsToSetWorldBox = NO;
	APP_SESSION.glView.needsToSetUsersPosition = NO;
	APP_SESSION.glView.usersPosition = APP_SESSION.locationManager->currentPosition;
	APP_SESSION.glView.panningEnabled = YES;
	APP_SESSION.glView.zoomingEnabled = YES;
	APP_SESSION.glView.centerUserPosition = YES;
	APP_SESSION.glView.use3DMap = NO;
	APP_SESSION.glView.zoomLevel = 10;
	APP_SESSION.glView.indicatorType = currentPositionNonGPS;	
	
	[APP_SESSION.locationManager.iPhoneLocationInterface setLocationHandler:self];	
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(false);
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[APP_SESSION.locationManager.iPhoneLocationInterface removeLocationHandler:self];
	
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
}

#pragma mark -
#pragma mark GeocodingHandler Methods

- (void)reverseGeocodingReady:(GeocodingInformation *)geocodingInformation {
	NSArray *formatted = [Formatter formatGeocodingInformationToTwoLines:geocodingInformation];
	
	HudOverlayViewController *cntrl = [[HudOverlayViewController alloc] initWithNibName:@"HudOverlayView" bundle:[NSBundle mainBundle]];

	[self performSelector:@selector(timeOutOnHudView:) withObject:cntrl afterDelay:HUD_DISPLAY_TIME];

	[self.view.superview addSubview:cntrl.view];
	
	cntrl.AddressLinie1Label.text = [formatted objectAtIndex:0];
	cntrl.AddressLinie2Label.text = [formatted objectAtIndex:1];
	
	[cntrl release];
}

- (void)timeOutOnHudView:(id)object
{
	HudOverlayViewController *cntrl = (HudOverlayViewController *)object;
	UIView *hudView = cntrl.view;
	
	[hudView removeFromSuperview];
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

	APP_SESSION.glView.usersPosition = APP_SESSION.locationManager->currentPosition; 
	
	if ([APP_SESSION.locationManager isCurrentPositionAnUpdateRefreshFromDefaultPosition]) {
		APP_SESSION.glView.centerUserPosition = YES;
	} else {
		APP_SESSION.glView.centerUserPosition = NO;
	}
	
	MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();			
	mapDrawingInterface->requestRepaint();
}

- (void)locationBasedServiceStarted {

}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
