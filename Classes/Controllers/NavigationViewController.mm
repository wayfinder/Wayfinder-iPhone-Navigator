/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "NavigationViewController.h"
#import "MapLibAPI.h"
#import "Nav2API.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "ConfigInterface.h"
#import "MapDrawingInterface.h"
#import "Formatter.h"
#import "RouteAction.h"
#import "WFNavigationAppDelegate.h"
#import "RouteOverviewViewController.h"
#import "ErrorHandler.h"
#import "IPNavSettingsManager.h"
#import "DetailedConfigInterface.h"
#import "ScreenPoint.h"

typedef struct {
	int minSpeed;
	int maxSpeed;
	int zoomLevel;
} speedToZoomLevelTranslation;

static speedToZoomLevelTranslation speedToZoomLevelTranslations[] = {{0, 20, 10}, {20, 40, 20}, {40, 100, 40}, {100, 500, 60}, {0, 0, 10}};

@implementation NavigationViewController

@synthesize resumedNavigation;
@synthesize portrait;

@synthesize portraitView;
@synthesize landscapeView;

@synthesize streetNameView;
@synthesize streetNameViewLandscape;

@synthesize nextTurnIndicatorImageView;
@synthesize nextTurnExitLabel;
@synthesize nextTurnDistanceLabel;
@synthesize nextTurnStreetNameLabel;
@synthesize currentStreetNameLabel;	
@synthesize timeLeftLable;
@synthesize distanceLeftLabel;
@synthesize toolbar;
@synthesize startStopToggleButton;	
@synthesize dayNightToggleButton;
@synthesize perspectiveToggleButton;

@synthesize nextTurnIndicatorImageViewLandscape;
@synthesize nextTurnExitLabelLandscape;
@synthesize nextTurnDistanceLabelLandscape;
@synthesize nextTurnStreetNameLabelLandscape;
@synthesize currentStreetNameLabelLandscape;	
@synthesize timeLeftLableLandscape;
@synthesize distanceLeftLabelLandscape;
@synthesize toolbarLandscape;
@synthesize startStopToggleButtonLandscape;	
@synthesize dayNightToggleButtonLandscape;
@synthesize perspectiveToggleButtonLandscape;

@synthesize timeLeftLiteralLabel;
@synthesize timeLeftLiteralLabelLandscape;
@synthesize distanceLeftLiteralLabel;
@synthesize distanceLeftLiteralLabelLandscape;
@synthesize cancelButton;
@synthesize cancelButtonLandscape;

@synthesize is3DEnabled;
@synthesize hasSimulationBeenStarted;
@synthesize isSimulationEnabled;
@synthesize isNightViewEnabled;

@synthesize lastAction;
@synthesize lastRouteCrossing;
@synthesize lastLeftSideTraffic;
@synthesize lastHighWay;
@synthesize destinationReached;

- (int)getZoomLevel {
	
	if (![[IPNavSettingsManager sharedInstance] speedZoomEnabled]) {
		return 10;
	}
	
	int speed = APP_SESSION.locationManager.currentSpeed;
	
	for(int index = 0; ; index ++) {
		if((speedToZoomLevelTranslations[index].minSpeed <= speed && speed < speedToZoomLevelTranslations[index].maxSpeed) ||
		   (speedToZoomLevelTranslations[index].minSpeed == 0 && speedToZoomLevelTranslations[index].maxSpeed == 0)) {
			return speedToZoomLevelTranslations[index].zoomLevel;
		}
	}
	
	return 10;
}

- (void)setActionIcon:(RouteAction)action 
		 withCrossing:(RouteCrossing)routeCrossing 
	  leftSideTraffic:(BOOL)leftSideTraffic
			isHighWay:(BOOL)highWay{
	
	self.lastAction = action;
	self.lastRouteCrossing = routeCrossing;
	self.lastLeftSideTraffic = leftSideTraffic;
	self.lastHighWay = highWay;	
	
	NSString *bitmapfile = @"invalid_action";
	
	switch(action) {
		case INVALIDACTION:
			bitmapfile = @"invalid_action";
			break;
		case AHEAD: // Go straight ahead.	
		case FOLLOW_ROAD: // Follow the current road.			
			if(routeCrossing == CROSSING_4_WAYS) {
				bitmapfile = @"4way_straight";
			} 
			else {			
				if(highWay) {
					if(leftSideTraffic) {
						bitmapfile = @"highway_straight";
					}
					else {
						bitmapfile = @"highway_straight_left";
					}
				}
				else {	
					bitmapfile = @"straight_ahead";						
				}
			}
			break;
		case LEFT: // Turn left.
		case OFF_RAMP_LEFT: // Turn left at the end of the road.
		case END_OF_ROAD_LEFT: // Turn left at the end of the road.			
			if(routeCrossing == CROSSING_4_WAYS) {
				bitmapfile = @"4way_left";
			} 
			else {				
				bitmapfile = @"left_arrow";						
			}
			break;
		case RIGHT: // Turn right.	
		case OFF_RAMP_RIGHT: // Turn right at the end of the road.			
		case END_OF_ROAD_RIGHT: // Turn right at the end of the road.			
			if(routeCrossing == CROSSING_4_WAYS) {
				bitmapfile = @"4way_right";
			} 
			else {				
				bitmapfile = @"right_arrow";						
			}
			break;
		case UTURN: // Make a U-Turn.
			if(leftSideTraffic) {
				bitmapfile = @"u_turn_left";
			}
			else {
				bitmapfile = @"u_turn";
			}
			break;
		case START: // Start of the route.
			bitmapfile = @"start";
			break;
		case FINALLY: // Approaching target.
			bitmapfile = @"finish_arrow";
			break;
		case ENTER_RDBT: // Enter a roundabout.
			if(leftSideTraffic) {
				bitmapfile = @"multiway_rdbt_left";				
			}
			else {
				bitmapfile = @"multiway_rdbt";				
			}							
			break;
		case EXIT_RDBT: // Exit from Roundabout.
			if(leftSideTraffic) {
				bitmapfile = @"multiway_rdbt_left";				
			}
			else {
				bitmapfile = @"multiway_rdbt";				
			}										
			break;
		case EXIT_AT: // Exit road by ramp.
			if(leftSideTraffic) {
				if(highWay) {
					bitmapfile = @"exit_highway_left";
				}
				else {
					bitmapfile = @"exit_main_road_left";
				}
			}
			else {
				if(highWay) {
					bitmapfile = @"exit_highway";
				}
				else {
					bitmapfile = @"exit_main_road";
				}			
			}
			break;
		case ON: // Enter road by ramp.	
			if(leftSideTraffic) {
				if(highWay) {
					bitmapfile = @"enter_highway_left";
				}
				else {
					bitmapfile = @"enter_main_road_left";
				}
			}
			else {
				if(highWay) {
					bitmapfile = @"enter_highway";
				}
				else {
					bitmapfile = @"enter_main_road";
				}			
			}			
			break;
		case PARK_CAR: // Park your car here.
			bitmapfile = @"park_car";
			break;
		case KEEP_LEFT: // Keep left when a road separates into two or more.
			bitmapfile = @"keep_left";
			break;
		case KEEP_RIGHT: // Keep right when a road separates into two or more.
			bitmapfile = @"keep_right";
			break;
		case START_WITH_U_TURN: // Start by makeing a u-turn.
			if(leftSideTraffic) {
				bitmapfile = @"u_turn_left";
			}
			else {
				bitmapfile = @"u_turn";
			}
			break;
		case U_TURN_RDBT: // Go back in the roundabout.
			if(leftSideTraffic) {
				bitmapfile = @"rdbt_uturn_left";
			}
			else {
				bitmapfile = @"rdbt_uturn";
			}
			break;
		case ENTER_FERRY: // Drive onto a ferry.
			bitmapfile = @"onto_ferry";
			break;
		case EXIT_FERRY: // Leave a ferry.
			bitmapfile = @"leave_ferry";			
			break;
		case CHANGE_FERRY: // Leave one ferry, enter another.
			bitmapfile = @"another_ferry";						
			break;
	}
	
	if(self.isNightViewEnabled) {
		bitmapfile = [NSString stringWithFormat:@"Direction_%@_night.png", bitmapfile];
	}
	else {
		bitmapfile = [NSString stringWithFormat:@"Direction_%@.png", bitmapfile];
	}
	
	NSLog(@"Setting direction bitmap: %@", bitmapfile);
	
	UIImage *actionIcon = [UIImage imageNamed:bitmapfile];
	[self.nextTurnIndicatorImageView setImage:actionIcon];
	[self.nextTurnIndicatorImageViewLandscape setImage:actionIcon];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.do
- (void)viewDidLoad {
	
#ifndef ENABLE_NAV_SIMULATION
	NSArray *items = self.toolbar.items;
	NSMutableArray *modifiedItems = [NSMutableArray arrayWithArray:items];
	[modifiedItems removeLastObject];
	self.toolbar.items = modifiedItems;
	
	items = self.toolbarLandscape.items;
	modifiedItems = [NSMutableArray arrayWithArray:items];
	[modifiedItems removeLastObject];
	self.toolbarLandscape.items = modifiedItems;	
#endif
	
	self.portrait = YES;
	self.hasSimulationBeenStarted = NO;
	self.isSimulationEnabled = NO;
	self.isNightViewEnabled = NO;

	APP_SESSION.glView.zoomLevel = [self getZoomLevel];
	[self setViewPerspective:YES];
	
	[APP_SESSION.navigationManager.iPhoneNavigationInterface startNavigationWithNavigationHandler:self];		
		
	[self.timeLeftLable setText:[Formatter formatTime:(APP_SESSION.navigationManager.currentRoute.timeToGoal)]];
	[self.distanceLeftLabel setText:[Formatter formatDistance:APP_SESSION.navigationManager.currentRoute.distanceToGoal]];	
	[self.nextTurnDistanceLabel setText:[Formatter formatDistance:APP_SESSION.navigationManager.currentRoute.distanceToNextTurn]];	
	
	NSString *currentStreetName = APP_SESSION.navigationManager.currentRoute.currentStreetName;
	if ((currentStreetName == nil) || ([currentStreetName isEqualToString:@""])) {
		[self.streetNameView setHidden:YES];
		[self.streetNameViewLandscape setHidden:YES];
	} else {
		[self.currentStreetNameLabel setText:currentStreetName];
		[self.currentStreetNameLabelLandscape setText:currentStreetName];
	}
	
	[self.nextTurnStreetNameLabel setText:APP_SESSION.navigationManager.currentRoute.nextStreetName];	
		
	[self.timeLeftLableLandscape setText:[Formatter formatTime:(APP_SESSION.navigationManager.currentRoute.timeToGoal)]];
	[self.distanceLeftLabelLandscape setText:[Formatter formatDistance:APP_SESSION.navigationManager.currentRoute.distanceToGoal]];	
	[self.nextTurnDistanceLabelLandscape setText:[Formatter formatDistance:APP_SESSION.navigationManager.currentRoute.distanceToNextTurn]];	
	
	[self.nextTurnStreetNameLabelLandscape setText:APP_SESSION.navigationManager.currentRoute.nextStreetName];	
	
	[self setActionIcon:APP_SESSION.navigationManager.currentRoute.nextAction
		   withCrossing:APP_SESSION.navigationManager.currentRoute.crossing
		leftSideTraffic:APP_SESSION.navigationManager.currentRoute.leftSideTraffic
			  isHighWay:APP_SESSION.navigationManager.currentRoute.isHighWay			 	 
	 ];	
	
	self.timeLeftLiteralLabel.text = [LocalizationHandler getString:@"iPh_time_left_txt"];
	self.timeLeftLiteralLabelLandscape.text = self.timeLeftLiteralLabel.text;
	self.distanceLeftLiteralLabel.text = [LocalizationHandler getString:@"iPh_distance_left_txt"];
	self.distanceLeftLiteralLabelLandscape.text = self.distanceLeftLiteralLabel.text;
	self.perspectiveToggleButton.title = [LocalizationHandler getString:@"[iPh_2D_perspective]"];
	self.perspectiveToggleButtonLandscape.title = self.perspectiveToggleButton.title;
	self.cancelButton.title = [LocalizationHandler getString:@"iPh_cancel_tk"];
	self.cancelButtonLandscape.title = self.cancelButton.title;
	self.dayNightToggleButton.title = [LocalizationHandler getString:@"iPh_night_tk"];
	self.dayNightToggleButtonLandscape.title = self.dayNightToggleButton.title;
	
    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// Restore the view's transform to identity. It could have been set manually in viewWillAppear
	self.landscapeView.transform = CGAffineTransformIdentity;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait) {		
		self.view = self.portraitView;
		self.portrait = YES;		
	}
	else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
			self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		self.view = self.landscapeView;
		self.portrait = NO;
	}

	UIView *mapContentView = [self.view viewWithTag:100];
	[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:self.is3DEnabled shouldSetMapDrawing:NO];			
	
	// Move the Copyright message to the bottom of the Map view order to avoid it being
	// obscured by the top info panel.
	[APP_SESSION.glView relocateCopyrightMessageAtTop:NO andOffset:-52];	
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
	self.portraitView = nil;
	self.landscapeView = nil;
	
	self.streetNameView = nil;
	self.streetNameViewLandscape = nil;
	
	self.nextTurnIndicatorImageView = nil;
	self.nextTurnExitLabel = nil;
	self.nextTurnDistanceLabel = nil;
	self.nextTurnStreetNameLabel = nil;
	self.currentStreetNameLabel = nil;	
	self.timeLeftLable = nil;
	self.distanceLeftLabel = nil;
	self.startStopToggleButton = nil;	
	self.perspectiveToggleButton = nil;	
	self.dayNightToggleButton = nil;
	
	self.nextTurnIndicatorImageViewLandscape = nil;
	self.nextTurnExitLabelLandscape = nil;	
	self.nextTurnDistanceLabelLandscape = nil;
	self.nextTurnStreetNameLabelLandscape = nil;
	self.currentStreetNameLabelLandscape = nil;	
	self.timeLeftLableLandscape = nil;
	self.distanceLeftLabelLandscape = nil;
	self.startStopToggleButtonLandscape = nil;	
	self.dayNightToggleButtonLandscape = nil;
	self.perspectiveToggleButtonLandscape = nil;
	
	self.timeLeftLiteralLabel = nil;
	self.timeLeftLiteralLabelLandscape = nil;
	self.distanceLeftLiteralLabel = nil;
	self.distanceLeftLiteralLabelLandscape = nil;
	self.cancelButton = nil;
	self.cancelButtonLandscape = nil;

    [super dealloc];
}

- (IBAction)cancelNavigation:(id)sender {
	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *navigationViewController = delegat.navController;	
	
	if(self.destinationReached) {
		[navigationViewController popToRootViewControllerAnimated:YES];
	}
	else {
		[navigationViewController popViewControllerAnimated:YES];			
	}

	// We are not navigating any more
	APP_SESSION.navigationManager.currentRoute.isNavigating = NO;
	
	if(self.resumedNavigation) {
		[APP_SESSION.glView setIndicatorType:currentPositionGPS];
		navigationViewController.navigationBarHidden = YES;		
	}
	else {
		navigationViewController.navigationBarHidden = NO;	
	}
	
	[Route clearStoredRoute];
}

- (IBAction)toggleMapsPerspective:(id) sender {
	self.is3DEnabled = !self.is3DEnabled;
		
	[self setViewPerspective:self.is3DEnabled];
	
	if(self.is3DEnabled) {
		self.perspectiveToggleButton.title = [LocalizationHandler getString:@"[iPh_2D_perspective]"];
	}
	else {
		self.perspectiveToggleButton.title = [LocalizationHandler getString:@"[iPh_3D_perspective]"];
	}	
	self.perspectiveToggleButtonLandscape.title = self.perspectiveToggleButton.title;
}

- (IBAction)toggleNightDay:(id)sender {

	self.isNightViewEnabled = !self.isNightViewEnabled;
	ConfigInterface *ConfigInterface = APP_SESSION.mapLibAPI->getConfigInterface();
	ConfigInterface->setNightMode(self.isNightViewEnabled);	

	[self setActionIcon:self.lastAction
		   withCrossing:self.lastRouteCrossing
		leftSideTraffic:self.lastLeftSideTraffic
			  isHighWay:self.lastHighWay			 	 
	 ];		
	
	if(self.isNightViewEnabled) {
		self.dayNightToggleButton.title = [LocalizationHandler getString:@"iPh_day_tk"];
	}
	else {
		self.dayNightToggleButton.title = [LocalizationHandler getString:@"iPh_night_tk"];
	}
	self.dayNightToggleButtonLandscape.title = self.dayNightToggleButton.title;
}

- (IBAction)increaseSpeed:(id)sender {
	APP_SESSION.nav2API->getRouteInterface().routeSimulationIncreaseSpeed();
}

- (NSArray *)updateSimulationToolbarButton:(NSArray *)toolbarItems withPlayStyle:(BOOL)playStyle{

	NSMutableArray *modifiedItems = [NSMutableArray arrayWithArray:toolbarItems];
	
	if(playStyle) {
		[modifiedItems removeLastObject];	
	}

	UIBarButtonItem *item = (UIBarButtonItem *) [modifiedItems lastObject];		
	[item retain];
	[modifiedItems removeLastObject];
	
	UIBarButtonSystemItem buttonStyle = playStyle ? UIBarButtonSystemItemPlay : UIBarButtonSystemItemPause;
	UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:buttonStyle target:item.target action:item.action];
	newItem.style = UIBarButtonItemStyleBordered;
	[modifiedItems addObject:newItem];
	[newItem release];
	
	if(!playStyle) {
		UIBarButtonItem *speedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(increaseSpeed:)];
		speedItem.style = UIBarButtonItemStyleBordered;
		[modifiedItems addObject:speedItem];
		[speedItem release];		
	}
	else {
	
	}
	
	[item release];	
	
	return modifiedItems;
}

- (IBAction)toggleStartStopSimulation:(id)sender {
	self.isSimulationEnabled = !self.isSimulationEnabled;	
	RouteInterface &routeInterface = APP_SESSION.nav2API->getRouteInterface();	
		
	if(self.isSimulationEnabled) {
		
		if(self.hasSimulationBeenStarted) {
			routeInterface.routeSimulationResume();					
		}
		else {
			routeInterface.routeSimulationStart();	
		}
		self.hasSimulationBeenStarted = YES;
	}
	else {
		routeInterface.routeSimulationPause();		
	}

	self.toolbar.items = [self updateSimulationToolbarButton:self.toolbar.items withPlayStyle:!self.isSimulationEnabled];
	self.toolbarLandscape.items = [self updateSimulationToolbarButton:self.toolbarLandscape.items withPlayStyle:!self.isSimulationEnabled];
}

- (void)setViewPerspective:(BOOL)used3D {
	self.is3DEnabled = used3D;
	
	if(self.is3DEnabled) {
		APP_SESSION.glView.use3DMap = YES;
		APP_SESSION.glView.indicatorType = driving3D;
	}
	else {
		APP_SESSION.glView.use3DMap = NO;
		APP_SESSION.glView.indicatorType = driving2D;
	}
}

- (void)toggleViewPerspective {
	[self setViewPerspective:!self.is3DEnabled];
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	NSLog(@"If this is invoked, we should seriously consider doing something more meaningful than just popping the view...");
	UINavigationController *navController = [(WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
	[navController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark NavigationHandler Methods

- (void)distanceUpdate:(UpdateNavigationDistanceInfo *)updateNavigationDistanceInfo {
	MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();
	mapDrawingInterface->requestRepaint();	
	
	[self.timeLeftLable setText:[Formatter formatTime:(updateNavigationDistanceInfo->getTimeToGoal())]];	
	[self.distanceLeftLabel setText:[Formatter formatDistance:updateNavigationDistanceInfo->getDistanceToGoal()]];	
	[self.nextTurnDistanceLabel setText:[Formatter formatDistance:updateNavigationDistanceInfo->getDistanceToNextTurn()]];	
	
	[self.timeLeftLableLandscape setText:[Formatter formatTime:(updateNavigationDistanceInfo->getTimeToGoal())]];	
	[self.distanceLeftLabelLandscape setText:[Formatter formatDistance:updateNavigationDistanceInfo->getDistanceToGoal()]];		
	[self.nextTurnDistanceLabelLandscape setText:[Formatter formatDistance:updateNavigationDistanceInfo->getDistanceToNextTurn()]];		
}

- (void)infoUpdate:(UpdateNavigationInfo *)updateNavigationInfo {
	MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();
	mapDrawingInterface->requestRepaint();	
	
	[self.timeLeftLable setText:[Formatter formatTime:(updateNavigationInfo->getTimeToGoal())]];
	
	[self.distanceLeftLabel setText:[Formatter formatDistance:updateNavigationInfo->getDistanceToGoal()]];	
	[self.nextTurnDistanceLabel setText:[Formatter formatDistance:updateNavigationInfo->getDistanceToNextTurn()]];	
	

	const WFString &currentWStreetName = updateNavigationInfo->getCurrentStreetName();
	NSString *currentStreetName = [NSString stringWithCString:currentWStreetName.c_str() encoding:NSUTF8StringEncoding];

	if ((currentStreetName == nil) || ([currentStreetName isEqualToString:@""])) {
		[self.streetNameView setHidden:YES];
		[self.streetNameViewLandscape setHidden:YES];
	} else {
		[self.streetNameView setHidden:NO];
		[self.streetNameViewLandscape setHidden:NO];

		[self.currentStreetNameLabel setText:currentStreetName];
		[self.currentStreetNameLabelLandscape setText:currentStreetName];
	}

	const WFString &nextStreetName = updateNavigationInfo->getNextStreetName();
	[self.nextTurnStreetNameLabel setText:[NSString stringWithCString:nextStreetName.c_str() encoding:NSUTF8StringEncoding]];
	 	
	[self.timeLeftLableLandscape setText:[Formatter formatTime:(updateNavigationInfo->getTimeToGoal())]];
	[self.distanceLeftLabelLandscape setText:[Formatter formatDistance:updateNavigationInfo->getDistanceToGoal()]];	
	[self.nextTurnDistanceLabelLandscape setText:[Formatter formatDistance:updateNavigationInfo->getDistanceToNextTurn()]];	
	
	const WFString &nextStreetNameLandscape = updateNavigationInfo->getNextStreetName();
	[self.nextTurnStreetNameLabelLandscape setText:[NSString stringWithCString:nextStreetNameLandscape.c_str() encoding:NSUTF8StringEncoding]];
	
	[self setActionIcon:updateNavigationInfo->getNextAction()
		   withCrossing:updateNavigationInfo->getNextCrossing()
		leftSideTraffic:updateNavigationInfo->getIfLeftSideTraffic()
			  isHighWay:updateNavigationInfo->getNextHighway()			 	 
	];	
	
	if(updateNavigationInfo->getNextAction() == EXIT_RDBT) {
		[self.nextTurnExitLabel setText:[NSString stringWithFormat:@"%d", updateNavigationInfo->getExitCount()]];
		[self.nextTurnExitLabelLandscape setText:[NSString stringWithFormat:@"%d", updateNavigationInfo->getExitCount()]];		
	}
	else {
		[self.nextTurnExitLabel setText:@""];
		[self.nextTurnExitLabelLandscape setText:@""];		
	}
}

- (void)playSound {

}

- (void)prepareSound:(WFStringArray *)soundNames {

}

#pragma mark -
#pragma mark RouteHandler Methods

- (void)requestedRouteFromOrigin:(WGS84Coordinate)start 
							  to:(WGS84Coordinate)destination 
			  withTransportation:(TransportationType) transportationType {

}

- (void)routeReply {

}

- (void)reachedEndOfRouteReply {
	self.cancelButton.title = [LocalizationHandler getString:@"iPh_done_tk"];
	self.cancelButtonLandscape.title = self.cancelButton.title;
	self.destinationReached = YES;	
	
	[self.timeLeftLable setText:[Formatter formatTime:0]];	
	[self.distanceLeftLabel setText:[Formatter formatDistance:0]];	
	[self.nextTurnDistanceLabel setText:[Formatter formatDistance:0]];	
	
	[self.timeLeftLableLandscape setText:[Formatter formatTime:0]];	
	[self.distanceLeftLabelLandscape setText:[Formatter formatDistance:0]];		
	[self.nextTurnDistanceLabelLandscape setText:[Formatter formatDistance:0]];			
}

- (void)viewWillAppear:(BOOL)animated {
	
	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(true);
	
	_viewPosCorrectionHackOffset = CGPointMake(0,0);
	
	UIDevice *device = [UIDevice currentDevice];
	
	if((!self.portrait && (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown)) ||
	   (self.portrait && (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight))) {
		
		if(device.orientation == UIDeviceOrientationLandscapeLeft || 
		   device.orientation == UIDeviceOrientationLandscapeRight) {
			self.portrait = NO;
			self.view = self.landscapeView;

			CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
			float statusHeight = statusBarFrame.size.height;
			
			if (device.orientation == UIDeviceOrientationLandscapeRight) {
				[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
				self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
				_viewPosCorrectionHackOffset = CGPointMake(statusHeight, 0);
			} else {
				[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
				self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
				_viewPosCorrectionHackOffset = CGPointMake(-statusHeight, -statusHeight);
			}
		}
		else {
			self.portrait = YES;
			self.view = self.portraitView;	
		}
		
		UIView *mapContentView = [self.view viewWithTag:100];
		[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:self.is3DEnabled shouldSetMapDrawing:YES];			
	}	
	
	// Turn on constant backlight
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// TODO: This a quick fix. The location handling should be refactored out of the EAGLView and into the respective controller classes.
	// MapLibAPI *mapLib = APP_SESSION.mapLibAPI;
	// MapOperationInterface* operationInterface = mapLib->getMapOperationInterface();			
	// operationInterface->setAngle(APP_SESSION.locationManager.currentHeading);
	
	APP_SESSION.glView.needsToSetWorldBox = NO;
	APP_SESSION.glView.needsToSetUsersPosition = NO;
	APP_SESSION.glView.usersPosition = APP_SESSION.navigationManager->start;
	// Note: Setting the zoom level must be done before setting the angle as setting the zoom level resets the angle to 0!
	APP_SESSION.glView.zoomLevel = [self getZoomLevel];	
	APP_SESSION.glView.angle = APP_SESSION.locationManager.currentHeading;	
	APP_SESSION.glView.panningEnabled = NO;
	APP_SESSION.glView.zoomingEnabled = NO;
	APP_SESSION.glView.centerUserPosition = YES;
	APP_SESSION.glView.use3DMap = YES;
	APP_SESSION.glView.indicatorType = driving3D;	
	
	[APP_SESSION.locationManager.iPhoneLocationInterface setLocationHandler:self];		
	[APP_SESSION.navigationManager.iPhoneNavigationInterface setRequestTemporaryRouteHandler:self];
	
	// Move the Copyright message to the bottom of the Map view order to avoid it being
	// obscured by the top info panel.
	[APP_SESSION.glView relocateCopyrightMessageAtTop:NO andOffset:-52];

	self.destinationReached = NO;
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// Adjust the view's offset after the rotation which took place in viewWillAppear
	// This hack should be made because for some reason the translation transformation doesn't have effect in viewDidAppear, nor settings the center, nor setting the view's frame.
	self.view.transform = CGAffineTransformConcat(self.view.transform, CGAffineTransformMakeTranslation(_viewPosCorrectionHackOffset.x, _viewPosCorrectionHackOffset.y));
}

- (void)viewWillDisappear:(BOOL)animated {
	// Turn off a possible night mode
	// Note: We do it here rather than in viewDidDisappear as turning night mode on/off 
	// has a latency that might causes the 2D route overview to be momentarily in
	// night mode but long enough for the user to notice.
	ConfigInterface *configInterface = APP_SESSION.mapLibAPI->getConfigInterface();
	configInterface->setNightMode(false);	
	
	// Move the Copyright message to the bottom of the Map view order to avoid it being
	// obscured by the top info panel.
	[APP_SESSION.glView relocateCopyrightMessageAtTop:YES andOffset:0];		
	
	[APP_SESSION.navigationManager.iPhoneNavigationInterface stopNavigationAndReleaseHandler:self];
	[APP_SESSION.navigationManager.iPhoneNavigationInterface removeAllRequestsForRouteHandler:self];	
	
	// Restore status bar to portrait, and transform to the default one
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
	self.view.transform = CGAffineTransformIdentity;
	
	APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(false);

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	// Turn off constant backlight
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
		
	// Unregister  as a location handler 
	[APP_SESSION.locationManager.iPhoneLocationInterface removeLocationHandler:self];	

	// Set the maps angle point north so subsequent use of the map has the right direction.
	APP_SESSION.glView.angle = 0.0;	
	
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark LocationHandler Methods

- (void)positionUpdated {
	
	APP_SESSION.glView.usersPosition = APP_SESSION.locationManager->currentPosition; 
	// Note: Setting the zoom level must be done before setting the angle as setting the zoom level resets the angle to 0!	
	APP_SESSION.glView.zoomLevel = [self getZoomLevel];	
	APP_SESSION.glView.angle = APP_SESSION.locationManager.currentHeading;
	
	NSLog(@"[NavigationView positionUpdated] : pos = (%f, %f) speed = %d zoom = %f", 
		  APP_SESSION.locationManager->currentPosition.latDeg,
		  APP_SESSION.locationManager->currentPosition.lonDeg,
		  APP_SESSION.locationManager.currentSpeed,
		  APP_SESSION.glView.zoomLevel);
}

- (void)locationBasedServiceStarted {
	
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
