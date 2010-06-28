/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>

#import "WFNavigationAppDelegate.h"
#import "Nav2API.h"
#import "MapLibAPI.h"
#import "EAGLView.h"
#import "IPhoneNav2StatusListener.h"
#import "WFNav2StatusListener.h"
#import "IPhoneFavouriteInterface.h"
#import "IPhoneOverlayInterface.h"
#import "IPhoneNavigationInterface.h"
#import "IPhoneNetworkInterface.h"
#import "IPhoneSearchInterface.h"
#import "IPhoneImageInterface.h"
#import "WGS84Coordinate.h"
#import "RouteAction.h"
#import "SearchTermsDataSource.h"
#import "SearchHistoryDataSource.h"
#import "ImageFactory.h"
#import "Route.h"
#import "LocationManager.h"
#import "NavigationManager.h"
#import "RouteHandler.h"
//#import "BillingManager.h"
#import "BusyViewController.h"

#define HUD_DISPLAY_TIME 2.0f
#define EAGLVIEW_TAG 100
#define MAX_NUMBER_OF_RETRIES (4)
#define RENDERBUFFER_MAX_X 480
#define RENDERBUFFER_MAX_Y 480 // Should use a single constant RENDERBUFFER_MAX_SIZE

@class AppSession;

extern AppSession *APP_SESSION;

@interface AppSession : NSObject<IPhoneNav2StatusListener, NetworkStatusHandler, UIAlertViewDelegate, RouteHandler> {
@public
	EAGLView *glView;		// Normally, should be a member variable of wrapperView.
	UIView *wrapperView;
	
	LocationManager *locationManager;
	NavigationManager *navigationManager;
//	BillingManager *billingManager;
	
	Nav2API *nav2API;
	MapLibAPI *mapLibAPI;
	
	SearchTermsDataSource *searchTermsDataSource;
	SearchHistoryDataSource *searchHistoryDataSource;
	
	BOOL startupCompleted;
	
@private
	
	WFNav2StatusListener *nav2StatusListener;
	IPhoneFavouriteInterface *favouriteInterface;
	IPhoneNetworkInterface *networkInterface;
	IPhoneSearchInterface *searchInterface;
	IPhoneOverlayInterface *overlayInterface;
	IPhoneImageInterface *imageInterface;
		
	BOOL drivingWarningWasShown;
	BusyViewController *busyViewController;
	NSArray *countryTitles;
	NSMutableDictionary *countries;
}

@property (nonatomic, retain) EAGLView *glView;

@property (nonatomic, retain) LocationManager *locationManager;
@property (nonatomic, retain) NavigationManager *navigationManager;
//@property (nonatomic, retain) BillingManager *billingManager;

@property (readonly) Nav2API *nav2API;
@property (readonly) MapLibAPI *mapLibAPI;

@property (readonly) IPhoneFavouriteInterface *favouriteInterface;
@property (readonly) IPhoneNetworkInterface *networkInterface;
@property (readonly) IPhoneSearchInterface *searchInterface;
@property (readonly) IPhoneOverlayInterface *overlayInterface;
@property (readonly) IPhoneImageInterface *imageInterface;

@property (readonly) SearchTermsDataSource *searchTermsDataSource;
@property (readonly) SearchHistoryDataSource *searchHistoryDataSource;
@property (readonly) BOOL startupCompleted;

@property (nonatomic, readonly) UIView *wrapperView;

@property (nonatomic, retain) BusyViewController *busyViewController;

@property (nonatomic, retain) NSArray *countryTitles;
@property (nonatomic, retain) NSMutableDictionary *countries;


- (void)initializeListeners;
- (void)startupNav2API;
- (void)testServerCommunication;

- (void)showMainMenu;
- (void)startupMapLibAPI;

- (void)resumeNavigation;
- (void)displayRoutingBusyView;
- (void)removeRoutingBusyView;
- (void)handleNavigationContinuation;

- (void)moveMapViewToNewParent:(UIView *)newParent use3DMode:(BOOL)use3DMode shouldSetMapDrawing:(BOOL)shouldSetMapDrawing;
- (void)startNewAccountProcessWithURL:(NSURL *)url;

- (void)loadCountries;

@end
