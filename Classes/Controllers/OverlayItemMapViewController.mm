/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "OverlayItemMapViewController.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "MapDrawingInterface.h"

@implementation OverlayItemMapViewController

- (id)initWithOverlayItem:(PlaceBase *)item {
	self = [super init];
	if (!self) return nil;
	
	_mapLayer = [[APP_SESSION.overlayInterface newLayer] retain];
	[_mapLayer addItems:[NSArray arrayWithObject:item] aroundMe:NO showOnMap:NO];
	
	_item = [item retain];
	[APP_SESSION.locationManager.iPhoneLocationInterface setLocationHandler:self];
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	self.title = [LocalizationHandler getString:@"iPh_map_txt"];
	UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 440.0)];
	[mapView setTag:100];
	
	[self.view addSubview:mapView];
	[mapView release];
	
	[APP_SESSION moveMapViewToNewParent:self.view use3DMode:NO shouldSetMapDrawing:YES];
	
	APP_SESSION.glView.needsToSetWorldBox = NO;
	[APP_SESSION.glView setNeedsSetUsersPosition:APP_SESSION.locationManager->currentPosition];
	APP_SESSION.glView.panningEnabled = YES;
	APP_SESSION.glView.zoomingEnabled = YES;
	APP_SESSION.glView.centerUserPosition = YES;
	APP_SESSION.glView.use3DMap = NO;
	APP_SESSION.glView.zoomLevel = 10;
	APP_SESSION.glView.indicatorType = currentPositionNonGPS;
	APP_SESSION.glView.mapsCenter = _mapLayer->_firstCorner;

	[APP_SESSION.glView showDescriptionForItem:_item withTarget:nil selector:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[_mapLayer setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[APP_SESSION.locationManager.iPhoneLocationInterface removeLocationHandler:self];

	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(false);

	[_mapLayer setHidden:YES];

	[super viewWillDisappear:animated];
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

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


- (void)dealloc {
	[_mapLayer release];
	[_item release];
	
    [super dealloc];
}

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

- (void)errorWithStatus:(AsynchronousStatus *)status{
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
