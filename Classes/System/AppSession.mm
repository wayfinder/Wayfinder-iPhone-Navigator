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
#import "StartupData.h"
#import "MapLibInitialConfig.h"
#import "MapLibAPI.h"
#import "IPhoneFactory.h"
#import "IPhoneNav2API.h"
#import "LocationInterface.h"
#import "WFNavigationAppDelegate.h"
#import "LocalizationHandler.h"
#import "NavigationViewController.h"
#import "MapDrawingInterface.h"
#import "MapObjectInterface.h"
#import "WFSelectedMapObjectListener.h"
#import "ConfigInterface.h"
#import "DetailedConfigInterface.h"
#import "ErrorHandler.h"
#import "SettingsInterface.h"
#import "WFSettingsListener.h"
#import "DrivingWarningAlertView.h"
#import "ScreenPoint.h"
#import "OverlayView.h"
#import "IPNavSettingsManager.h"
#import "BillingViewController.h"
#import "MainMenuViewController.h"

using namespace WFAPI;

AppSession *APP_SESSION;

@implementation AppSession

@synthesize glView;	
@synthesize locationManager;
@synthesize navigationManager;
//@synthesize billingManager;
@synthesize nav2API;
@synthesize mapLibAPI;
@synthesize favouriteInterface;
@synthesize networkInterface;
@synthesize searchInterface;
@synthesize overlayInterface;
@synthesize imageInterface;
@synthesize startupCompleted;

@synthesize searchTermsDataSource;
@synthesize searchHistoryDataSource;

@synthesize wrapperView;
@synthesize busyViewController;

@synthesize countryTitles;
@synthesize countries;

// set this to 0 if you want to be able to startup and debug stuff without initializing the maplib - beware that many things, that depends on the maplib won't work either...
#define ENABLE_MAP 1

/*
 * 1. Constructor...
 */
- (id)init {
	NSLog(@"--- Initializing AppSession ---");
	NSDate *startDate = [NSDate date];
	
	self = [super init];
	if (!self) return nil;

	startupCompleted = NO;
	
	// initialize gl view
#if ENABLE_MAP
	glView = [[EAGLView alloc] initWithFrame:CGRectMake(0, 0, RENDERBUFFER_MAX_X, RENDERBUFFER_MAX_Y)];
#endif	
	nav2API = nil;
	mapLibAPI = nil;

	wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, glView.frame.size.width, glView.frame.size.height)];
	wrapperView.opaque = YES;
	wrapperView.clipsToBounds = YES;
	wrapperView.backgroundColor = [UIColor clearColor];
	[wrapperView addSubview:glView];

	favouriteInterface = nil;
	networkInterface = nil;
	searchInterface = nil;	
	overlayInterface = nil;
	imageInterface = nil;

	drivingWarningWasShown = NO;

	self.busyViewController = nil;

	
	NSLog(@"##### STEP 1 #####: Initialization of APP_SESSION took %.4f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);	
	
	[self startupNav2API];

	return self;
}

- (void)dealloc {
	
	self.locationManager = nil;
	self.navigationManager = nil;
//	self.billingManager = nil;
	
	[searchTermsDataSource release];
	[searchHistoryDataSource release];
	
    [searchInterface release];
	[self.networkInterface release];
	[self.favouriteInterface release];
	[self.overlayInterface release];
	[self.imageInterface release];
	[wrapperView release];
	self.glView = nil;
	
	delete nav2API;
	[super dealloc];
}

/*
 * 2. Starting Nav2API...
 */
- (void)startupNav2API {
	NSLog(@"Creating Nav2API...");
	NSDate *startDate = [NSDate date];
	
	// initialize nav2API and set status listener
	nav2API = new IPhoneNav2API;
	nav2StatusListener = new WFNav2StatusListener(self);

	NSLog(@"Setting the client type to %s", CLIENT_TYPE);
	nav2API->setClientType(WFString(CLIENT_TYPE));
	NSLog(@"Validating Core's client type = %s", nav2API->getClientType().c_str());	
	
	// move (copy?) paramseed to a readable (writable?) path
	NSError *error = nil;
    NSString *paramSeedPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"paramseed.txt"];
    [[NSFileManager defaultManager] copyItemAtPath:paramSeedPath toPath:[[UIApplication getDocumentsPath] stringByAppendingPathComponent:@"paramseed.txt"] error:&error];
	
	if (error) {
		NSLog(@"Failed to move paramseed file with error : %@", [error localizedDescription]);
	}
	
	// Retrieve the location of our documents folder, this is where we will put our writable data.
	NSString *docsPath		= [UIApplication getDocumentsPath];
	NSString *soundsPath	= [UIApplication getSoundsPath];
	
	// get voice and text languages
	LocalizationHandler *loczHandler = [[LocalizationHandler alloc] init];
	WFAPI::TextLanguage					textLanguage	= [loczHandler getTextLanguage];
	WFAPI::VoiceLanguage::VoiceLanguage	voiceLanguage	= [loczHandler getVoiceLanguage];
	[loczHandler release];	
	
	// initialize startup data for nav2API
	StartupData startupData([docsPath UTF8String], 
							[soundsPath UTF8String], 
							textLanguage, 
							voiceLanguage,
							[docsPath UTF8String], 
							[docsPath UTF8String],
							[docsPath UTF8String]);	

	// set audio type 
	nav2API->setAudioTypeDirName("MP3");
	
	
	// start nav2API
   // this is an asynchronious call but we can't do anything until we receive the startupComplete callback
 
	NSLog(@"Starting Nav2API...");
	nav2API->start(nav2StatusListener, &startupData);
	
	NSLog(@"##### STEP 2 #####: Set Nav2API settings, Start Nav2API and Copy paramseed file took %.4f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
}


/*
 * 3. Callback (IPhoneNav2StatusListener) when Nav2API has started...
 */
- (void)startupComplete {
	NSLog(@"Nav2 startup complete.");
	
	// now that nav2API is started we can setup the listeners and test the server connection 
	[self initializeListeners];
	[self testServerCommunication];
	
	LocationManager *lm = [[LocationManager alloc] init];
	self.locationManager = lm;
	[lm release];
	
	searchTermsDataSource = [[SearchTermsDataSource alloc] init];
	searchHistoryDataSource = [[SearchHistoryDataSource alloc] init];
}

/*
 * 4. Nav listeners initialization...
 */
- (void)initializeListeners {
	NSLog(@"AppSession setting up Nav2 listeners...");

	NSLog(@"Setup AppSession listeners");
	NSDate *startDate = [NSDate date];
	
	NSLog(@"Setting up FavouriteInterface and attaching FavouriteListener...");
	favouriteInterface = [[IPhoneFavouriteInterface alloc] init];
	
	NSLog(@"Setting up NetworkInterface and attaching NetworkListener...");
	networkInterface = [[IPhoneNetworkInterface alloc] init];
	
	NSLog(@"Setting up SearchInterface and attaching SearchListener...");
	searchInterface = [[IPhoneSearchInterface alloc] init];
	imageInterface = [[IPhoneImageInterface alloc] init];
	
	NSLog(@"AppSession setting up Nav2 listeners done!");
	NSLog(@"Listeners initialization took %.4f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
}

/*
 * 5. Test server communication...
 */
- (void)testServerCommunication {
	
	NSLog(@"testing server connection");
	[self.networkInterface addNetworkStatusHandler:self];
	[self.networkInterface testServerConnection];
}

/*
 * 6. Callback (IPhoneNetworkStatusHandler) from server communication test...
 */
- (void)connectionStatusConnected:(BOOL)isConnected hasEverBeenConnected:(BOOL)hasEverBeenConnected {
	if (isConnected) {
		[self.networkInterface removeNetworkStatusHandler:self];
		NSLog(@"Connection test succeeded - server replied.");
		[self showMainMenu];
		[self startupMapLibAPI];
	} else {
		// handle connection error...
		NSLog(@"Connection test failed - now what?");
		
		[[ErrorHandler sharedInstance] handleNetworkConnectionErrorWithExit:!hasEverBeenConnected];
	}
}

- (void)showMainMenu {
	
	// Now that we have nav2API initialization completed we can show the main menu
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate hideLoadingView];

	[appDelegate.window addSubview:appDelegate.navController.view];			
#if ENABLE_MAP
	[APP_SESSION.glView addOverlayView];
#endif
	// We cannot begin routing before the system is fully initialized but we cheat by displaying the busy view now
	// so that the main menu isn't exposed to the user.	
	if([Route navigationWasInterrupted]) {
		[self displayRoutingBusyView];		
	}	
		
// Client EULA replaced with the billing one
// Check EULA and driving warning while testing the connection.
#if ENABLE_MAP
	WFAPI::SettingsInterface *settingsInterface = &APP_SESSION.nav2API->getSettingsInterface();
	settingsInterface->isEULAUpdated("eula_nav_iphone");
	WFSettingsListener *settingsListener = new WFSettingsListener();
	settingsInterface->addSettingsListener(settingsListener);	
#endif	
	[favouriteInterface syncFavourites];
}

/*
 * 7. Starting MapLibAPI...
 */
- (void)startupMapLibAPI {
	
	NSDate *startDate = [NSDate date];
	
	MapLibInitialConfig initialConfig;
	const char *docPathStr = [[UIApplication getDocumentsPath] cStringUsingEncoding:NSASCIIStringEncoding];
	
	initialConfig.setDiskCacheSettings(docPathStr, 10*1024*1024);
#if ENABLE_MAP
	NSLog(@"Creating MapLibAPI...");
	mapLibAPI = IPhoneFactory::createMapLib(nav2API->getDBufConnection(), NULL, initialConfig);
	NSLog(@"Connecting Nav2API and MapLibAPI...");
	nav2API->connectMapLib(mapLibAPI);
	NSLog(@"##### STEP 3 #####: Initialize MAPLib and startup took %.4f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
#else
	[self mapLibStartupComplete];
#endif
}	

/*
 * 8. Callback (IPhoneNav2StatusListener) when MapLibAPI has started...
 */
- (void)mapLibStartupComplete {
	
	// Show driving warning if necessary
	// However if we were interrupted by an incoming call while navigating we continue without
	// displaying the driving warning	
	if(![Route navigationWasInterrupted]) {
		//show driving warning if necessary
		if (([UIApplication firstStart] || ![UIApplication drivingWarningDisabled]) && !drivingWarningWasShown) {
			
			DrivingWarningAlertView *warningView = [[DrivingWarningAlertView alloc] init];
			[warningView setDelegate:self];
			[warningView show];
			[warningView release];
			drivingWarningWasShown = YES;
		}
	}

#if ENABLE_MAP
	NSLog(@"Setting up OverlayInterface and Listeners ... ");
	overlayInterface = [[IPhoneOverlayInterface alloc] init];
		
	// We only set the drawer after we've successfully started MapLib 
	if(self.glView.glDrawer) {
		NSLog(@"Setting drawing context...");
		self.mapLibAPI->setDrawingContext(self.glView.glDrawer->getDrawingContext());
	}
	
	WFAPI::MapObjectInterface *mapObjectInterface = self.mapLibAPI->getMapObjectInterface();
	WFSelectedMapObjectListener *objectListener = new WFSelectedMapObjectListener();
	
	mapObjectInterface->addSelectedMapObjectListener(objectListener);
	
	DetailedConfigInterface *detailedConfigInterface = APP_SESSION.mapLibAPI->getConfigInterface()->getDetailedConfigInterface();
	detailedConfigInterface->enableAutomaticHighlight(true);
#endif
	self.navigationManager = [[NavigationManager alloc] init];	
	[self.navigationManager release];	

//  removed old billing system	
//	self.billingManager = [[BillingManager alloc] init];	
//	[self.billingManager release];
	
	// hide pois

#if ENABLE_MAP
	[[IPNavSettingsManager sharedInstance] hidePOIs:YES];
#endif
	
	// post notification that map is available
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mapAvailable" object:nil];
	
	// Let see if we are going to continue an interrupted navigation session... (unless we are
	// showing a driving warning in which case the continuation is handled by the alert view's
	// button clicked dalagate method)
	if(!drivingWarningWasShown) {
		[self handleNavigationContinuation];
	}
	
	startupCompleted = YES;
}

/*
 * Callback (IPhoneNav2StatusListener) when the Nav2API has stopped...
 */
- (void)stopComplete {
	NSLog(@"Nav2 stop complete.");
}

#pragma mark -
#pragma mark Handling automatic navigation continuation Methods

- (void)resumeNavigation {	
	//	WGS84Coordinate currentPosition = self.locationManager->currentPosition;
	[Route reloadRouteWithStartAt:APP_SESSION.locationManager->currentPosition usingHandler:self];				
}

- (void)displayRoutingBusyView {
	self.busyViewController = [[BusyViewController alloc] initWithNibName:@"BusyView" bundle:nil];
	NSString *msgs = [LocalizationHandler getString:@"[iPh_calc_route_txt]"];
	[self.busyViewController setBusyMessage:msgs];
	// Hack! we should have a proper layouted subview for holding the busy view later on
	CGRect frame = busyViewController.view.frame;
	frame.origin.y += 20;
	busyViewController.view.frame = frame;	
	
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.window addSubview:busyViewController.view];	
		
	[self.busyViewController release];
}

- (void)removeRoutingBusyView {
	
	if(self.busyViewController != nil) {
		[self.busyViewController.view removeFromSuperview];
		self.busyViewController = nil;
	}	
}

- (void)handleNavigationContinuation {
	if([Route hasAStoredRoute]) {			
		// If we were terminated by a incoming call we just continue to Navigation
		// otherwise we prompt the use for continuation.
		if([Route navigationWasInterrupted]) {		
			[self resumeNavigation];
		}
		else {
			UIAlertView *msgs = [[UIAlertView alloc] init];
			msgs.title = [LocalizationHandler getString:@"iPh_resume_txt"];
			msgs.message = [LocalizationHandler getString:@"iPh_resume_navigation_txt"];
			msgs.delegate = self;
			[msgs addButtonWithTitle:[LocalizationHandler getString:@"iPh_yes_tk"]];
			[msgs addButtonWithTitle:[LocalizationHandler getString:@"iPh_no_tk"]];
			[msgs show];
			[msgs release];
		}
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// DrivingWArningAlertView feedback
	if ([alertView isKindOfClass:DrivingWarningAlertView.class]) {
		[self handleNavigationContinuation];
	}
	// navigation continuation feedback
	else {
		// If the user chose to continue an interrupted navigation we have to re-route according to the
		// user's current position.
		if(buttonIndex == 0) {
			[self displayRoutingBusyView];
			[self resumeNavigation];
		}
		// Otherwise we delete the stored route (in order to avoid the same prompt next time the app
		// is started) and continue just as planned.
		else {
			[Route clearStoredRoute];
		}
	}
}

#pragma mark -
#pragma mark BaseHandler Methods

/*
 * Callback (IPhoneNav2StatusListener, RouteHandler) in case any error occurs during startup...
 */
- (void)errorWithStatus:(AsynchronousStatus *)status {
	// apparently we assume that the error had something to do with routing...
	[self removeRoutingBusyView];

	NSLog(@"Nav2Status (or Routing) error (%d): %s", status->getStatusCode(), status->getStatusMessage().c_str());
}

#pragma mark -
#pragma mark RouteHandler Methods

- (void)requestedRouteFromOrigin:(WGS84Coordinate)start to:(WGS84Coordinate)destination withTransportation:(TransportationType) transportationType {
	
}

- (void)routeReply {

	NSLog(@"Enter routeReply");
	
	NavigationViewController *navigationViewController = [[NavigationViewController alloc] initWithNibName:@"NavigationView" bundle:[NSBundle mainBundle]];
	
	UIView *mapContentView = [navigationViewController.view viewWithTag:EAGLVIEW_TAG];
	[APP_SESSION moveMapViewToNewParent:mapContentView use3DMode:YES shouldSetMapDrawing:YES];
	[APP_SESSION.glView setPanningEnabled:NO];
	
	WFNavigationAppDelegate *delegat = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	navigationViewController.resumedNavigation = NO;
		
	UINavigationController *navCtrl = delegat.navController;	
	[navCtrl pushViewController:navigationViewController animated:NO];			
	navCtrl.navigationBarHidden = YES;

	// Configure the view to have the starting point in the center and set the zoom level "correctly"
	MapLibAPI *mapLib = APP_SESSION.mapLibAPI;
	
	// Force yet another redraw 	
	MapDrawingInterface *mapDrawingInterface = mapLib->getMapDrawingInterface();
	mapDrawingInterface->requestRepaint();	
	
	// We are now navigating
	APP_SESSION.navigationManager.currentRoute.isNavigating = YES;
	
	// And we deleted the stored route so we are not resuming this particular navigation the next time
	[Route clearStoredRoute];	
	
	[navigationViewController release];			
	
	[self removeRoutingBusyView];
	
	NSLog(@"Leaving routeReply");
}

- (void)moveMapViewToNewParent:(UIView *)newParent use3DMode:(BOOL)use3DMode shouldSetMapDrawing:(BOOL)shouldSetMapDrawing {
#if ENABLE_MAP
	if (shouldSetMapDrawing) {
		APP_SESSION.mapLibAPI->getMapDrawingInterface()->setMapDrawingEnabled(true);
	}
#endif	
	
	UIView *mapContentView = [newParent viewWithTag:100];
	CGRect frame = [mapContentView frame];
	CGRect glViewFrame = CGRectMake(0, -(RENDERBUFFER_MAX_Y-frame.size.height), RENDERBUFFER_MAX_X, RENDERBUFFER_MAX_Y);
	
	[wrapperView removeFromSuperview];
	[mapContentView addSubview:wrapperView];
	
	[glView setFrame:glViewFrame];

	glView.backingWidth = frame.size.width;
	glView.backingHeight = frame.size.height;
	
	// The parent will have the real(required) size, the child(which is the opengl view) will remain with unchanged size but changed origins in order to 
	[wrapperView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	
	if (glView.descriptionView) {
		[glView.descriptionView removeFromSuperview];
	}
	
	if(APP_SESSION.mapLibAPI != nil) {
		ConfigInterface *configInterface = APP_SESSION.mapLibAPI->getConfigInterface();
		configInterface->set3dMode(use3DMode);	
		
		MapOperationInterface* operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();		
		MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();
		operationInterface->setCenter(glView->mapsCenter);
		operationInterface->setAngle(0);
		operationInterface->move(0,0);
		
//		mapDrawingInterface->requestRepaint();		
	}
}

- (void)startNewAccountProcessWithURL:(NSURL *)url {
	WFNavigationAppDelegate *delegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// if there is no controller loaded load main menu
	if (nil == [delegate.navController topViewController]) {
		[APP_SESSION showMainMenu];
	}
	
	BillingViewController *billingController = [[BillingViewController alloc] initWithURL:url];
	[delegate.navController pushViewController:billingController animated:YES];
	[billingController release];
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

- (void)loadCountries
{
	NSMutableArray *letters = [[NSMutableArray alloc] init];
	countries = [[NSMutableDictionary alloc] init];
	
	TopRegionArray regions;
	[APP_SESSION.searchInterface getTopRegions:regions];
	
	for (TopRegionArray::iterator it = regions.begin(); it < regions.end(); it++) {
		TopRegion tr = *it;
		CountryDetail *cd = [[CountryDetail alloc] initWithTopRegion:&tr];
		NSLog(@"TopRegion [%d]: %@ (%d)", cd.countryID, cd.name, tr.getType());
		if (tr.getType() == COUNTRY) {
			NSString *key = [cd.name substringToIndex:1];
			NSMutableArray *countryArray = [countries objectForKey:key];
			if (countryArray == nil) {
				[letters addObject:key];
				countryArray = [[NSMutableArray alloc] init];
				[countries setObject:countryArray forKey:key];
				[countryArray release];
			}
			[countryArray addObject:cd];
		}
		[cd release];	
	}
	
	self.countryTitles = [letters sortedArrayUsingSelector:@selector(compare:)];
	
	[letters release];
}

@end
