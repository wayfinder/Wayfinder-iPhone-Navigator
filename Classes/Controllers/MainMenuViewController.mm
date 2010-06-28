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
#import "MainMenuViewController.h"
#import "WFNavigationAppDelegate.h"
#import "IPNavMainSettingsController.h"
#import "IPNavSettingsAboutController.h"
#import "BillingViewController.h"
#import "MainMenuSearchTableViewController.h"
#import "IPNavSettingsTableViewController.h"
#import "AppSession.h"
#import "ErrorHandler.h"
#import "Formatter.h"
#import "MapDrawingInterface.h"

@implementation MainMenuViewController

@synthesize mainMenuTableViewController;
@synthesize mainMenuSearchTableViewController;
@synthesize locationLabel;
@synthesize locationSourceIndicatorView;
@synthesize toolbar;
@synthesize mapHolder;
@synthesize reversedGeocodingEnabled;

- (void)reenableReversedGeocoding:(id)arg {
	self.reversedGeocodingEnabled = YES;
}
	
- (void)updateLocationSourceIndicator {

	if(!APP_SESSION.locationManager.receivedFirstGoodPosition) {
		self.locationLabel.text = [LocalizationHandler getString:@"[current_location_main_page]"];
		
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activityIndicator setFrame:self.locationSourceIndicatorView.bounds];
		[self.locationSourceIndicatorView addSubview:activityIndicator];
		[activityIndicator startAnimating];
		[activityIndicator release];		
	}
	else {
		if(self.reversedGeocodingEnabled) {
			self.reversedGeocodingEnabled = NO;
			NSLog(@"###### Requesting reversed geolocation ######");			
			[APP_SESSION.locationManager.iPhoneLocationInterface requestLocationBasedReverseGeocodingAndSetGeocodingHandler:self];		
			[self performSelector:@selector(reenableReversedGeocoding:) withObject:self afterDelay:60];
		}			
		// 	
	}
}

- (void)loadView {
	[super loadView];
	
	self.mapHolder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0,  480.0)];
	[mapHolder setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[mapHolder setTag:100];
	
	[self.view addSubview:mapHolder];
	[self.view sendSubviewToBack:mapHolder];
	[self.mapHolder release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	self.title = [LocalizationHandler getString:@"iPh_navigation_txt"];
	
	[self.mainMenuTableViewController.view setBackgroundColor:[UIColor clearColor]];
	[self.mainMenuSearchTableViewController.view setBackgroundColor:[UIColor clearColor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMapBackground:) name:@"mapAvailable" object:nil];
	
	self.reversedGeocodingEnabled = YES;
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
	[mainMenuSearchTableViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateLocationSourceIndicator];
	
	[APP_SESSION.locationManager->iPhoneLocationInterface setLocationHandler:self];	
	
	if (APP_SESSION.startupCompleted) {
		[self setMapBackground:nil];
	}
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(false);
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[APP_SESSION.locationManager->iPhoneLocationInterface removeLocationHandler:self];
	
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	[APP_SESSION.locationManager->iPhoneLocationInterface removeLocationHandler:self];	

	[super viewDidUnload];
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.mainMenuTableViewController = nil;
	self.mainMenuSearchTableViewController = nil;
	
	self.locationSourceIndicatorView = nil;
	self.locationLabel = nil;
	self.toolbar = nil;
	self.mapHolder = nil;

	[super dealloc];
}

- (void)settingButtonPressed:(id)sender {
	IPNavSettingsTableViewController *settingsController = [[IPNavSettingsTableViewController alloc] init];
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	[navController pushViewController:settingsController animated:YES];
	[settingsController release];
}

- (void)infoButtonPressed:(id)sender {
	IPNavSettingsAboutController *aboutController = [[IPNavSettingsAboutController alloc] init];
	[self.navigationController pushViewController:aboutController animated:YES];
	[aboutController release];
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	//	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
}

#pragma mark -
#pragma mark GeocodingHandler Methods

- (void)reverseGeocodingReady:(GeocodingInformation *)geocodingInformation {
	self.locationLabel.text = [Formatter formatGeocodingInformationToOneLine:geocodingInformation];
	NSArray *subviews =  [self.locationSourceIndicatorView subviews];
	if(subviews.count > 0) {
		UIView *indicatorView = [subviews objectAtIndex:0];
		
		// If we still have a spinning indicator wheel we should first stop it
		if([indicatorView isMemberOfClass:[UIActivityIndicatorView class]]) {
			[(UIActivityIndicatorView *) indicatorView stopAnimating];
		}
		
		// Remove the old indicator
		[indicatorView removeFromSuperview];
	}
		
	// ... and display the new instead!
	NSString *imageFileName;
	if(APP_SESSION.locationManager.iPhoneLocationInterface.gpsLocationIsAvailable) {
		imageFileName = @"LbsGPSIndicator.png"; 			
	}
	else {
		imageFileName = @"LbsCellTowerIndicator.png";
	}		
	
	UIImage *locatorImage = [UIImage imageNamed:imageFileName];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:locatorImage];
	[self.locationSourceIndicatorView addSubview:imageView];
	[imageView release];
}

#pragma mark -
#pragma mark LocationHandler Methods

- (void)positionUpdated {
	[self updateLocationSourceIndicator];
}

- (void)locationBasedServiceStarted {

}

- (void)setMapBackground:(id)sender {
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	
	if ([[navController viewControllers] count] == 1) {
		// Enable map drawing if the main manu is visible, otherwise leave it's current state
		[APP_SESSION moveMapViewToNewParent:self.view use3DMode:NO shouldSetMapDrawing:YES];
	}
	
	APP_SESSION.glView.centerUserPosition = YES;
	APP_SESSION.glView.mapsCenter = APP_SESSION.locationManager->currentPosition;
	APP_SESSION.glView.indicatorType = none;
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
