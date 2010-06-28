/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFNavigationAppDelegate.h"
#import "AppSession.h"
#import "LocalizationHandler.h"
#import "MapViewController.h"
#import "RouteOverviewViewController.h"
#import "NavigationViewController.h"
#import "IPNavMainSettingsController.h"
#import "EAGLView.h"
#import "LoadingView.h"
#import "OverlayInterface.h"
#import "EULAController.h"
#import "UIApplication-Additions.h"


@implementation WFNavigationAppDelegate

@synthesize window;
@synthesize navController;
@synthesize rootController;

static BOOL applicationIsInterrupted = NO;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	if (ENABLE_LOGFILE_SYSTEM) {
		[UIApplication enableLogFileSystem];
	}
	
	[self showLoadingView];
	[self setupAudioSession];
	
	[navController.navigationBar setTintColor:[UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1.0]];
	
	// Set device to send notification about its orientation
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

	
	// register as an observer for session loading ended notification
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(hideLoadingView) 
												 name:@"sessionloadingFinished" 
											   object:nil];
	

	[window makeKeyAndVisible];		
	[self performSelector:@selector(loadSession) withObject:nil afterDelay:0.0];
}

- (void)loadSession {
	ALL_CATEGORIES = [[SearchCategoryDetail alloc] initWithAllCategories];
	APP_SESSION = [[AppSession alloc] init];
}

- (void)showLoadingView {
	if (!_loadingView) {
		_loadingView = [[LoadingView alloc] init];
	}
	
	[window addSubview:_loadingView];
}

- (void)hideLoadingView {
	if (_loadingView) {
		[_loadingView removeFromSuperview];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application{ 
	applicationIsInterrupted = YES;
}
	
- (void)applicationDidBecomeActive:(UIApplication *)application{ 
	applicationIsInterrupted = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// The user answered the call (or quit the app) so save the 
	// the app state as we are shutting down 	
	[APP_SESSION.locationManager saveLastPosition];
	
	// If we currently are navigating we should store the route for later
	// resumption.
	if([APP_SESSION.navigationManager isNavigating]) {
		
		// We should note if the termination is due to an interruption as this case
		// should be handled specially when we are doing 		
		[APP_SESSION.navigationManager.currentRoute storeRoute:applicationIsInterrupted];				

		applicationIsInterrupted = NO;
	}
			
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];			
}

- (void)setupAudioSession {
	// initialize audio session
/*	OSStatus initStatus =*/ AudioSessionInitialize (
												  NULL,
												  NULL,
												  AudioInterruptionListener,
												  self
	);
	
	// set audio session category
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	AudioSessionSetProperty ( 
							 kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory
	); 
	
	// enable bluetooth
	UInt32 allowBluetoothInput = 1;	
	AudioSessionSetProperty (
							 kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
							 sizeof (allowBluetoothInput),
							 &allowBluetoothInput
							 );

	// if no bluetooth default to speaker
	UInt32 defaultToSpeaker = 1;	
	AudioSessionSetProperty (
							 kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
							 sizeof (defaultToSpeaker),
							 &defaultToSpeaker
							 );
	
	// add listener for audio route change event
	AudioSessionPropertyID routeChangeID = kAudioSessionProperty_AudioRouteChange;
/*	OSStatus listenerStatus =*/ AudioSessionAddPropertyListener (
																 routeChangeID,
																 AudioPropertyListener,
																 self 
	); 
	
	// activate audio session
/*	OSStatus activeStatus =*/ AudioSessionSetActive(true);
	
}

- (void)dealloc {
    [window release];
	[navController release];
	[rootController release];
    [super dealloc];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHandler getString:@"iPh_back_tk"] style:UIBarButtonItemStylePlain target:nil action:nil];
	[viewController navigationItem].backBarButtonItem = backBarButtonItem;
	[backBarButtonItem release];	
	
	[viewController.view setNeedsLayout];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if([viewController isMemberOfClass:[RouteOverviewViewController class]] ||
	   [viewController isMemberOfClass:[NavigationViewController class]] ||
	   [viewController isMemberOfClass:[IPNavMainSettingsController class]]) 
		return;
	
	if([APP_SESSION.navigationManager hasRoute]) {
		[APP_SESSION.navigationManager cancelRoute];
	}
}

@end

void AudioInterruptionListener(void *inClientData, UInt32 inInterruptionState) {
	NSLog(@"Audio interruption occured");
}

void AudioPropertyListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
	NSLog(@"Audio Session Property changed");
	
	if (inID != kAudioSessionProperty_AudioRouteChange) return;
	
	CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inData;
	CFNumberRef routeChangeReasonRef = 
	(CFNumberRef)CFDictionaryGetValue ( 
						  routeChangeDictionary, 
						  CFSTR(kAudioSession_AudioRouteChangeKey_Reason) 
						  ); 
	SInt32 routeChangeReason = 0; 
	CFNumberGetValue ( 
					  routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason 
					  ); 
	if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
		UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
		AudioSessionSetProperty (
								 kAudioSessionProperty_OverrideAudioRoute,
								 sizeof(audioRouteOverride),
								 &audioRouteOverride
								 );
	}
}
