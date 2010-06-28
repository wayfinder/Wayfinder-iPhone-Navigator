/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneNavigationInterface.h"
#import "RouteInterface.h"
#import "NavigationInterface.h"
#import "AppSession.h"
#import "MapLibAPI.h"
#import "MapDrawingInterface.h"
#import "RouteOverviewViewController.h"
#import "WFNavigationAppDelegate.h"
#import "BillingViewController.h"
#import "ErrorHandler.h"
#import "IPNavSettingsManager.h"
#import "RouteStatusCode.h"

@implementation IPhoneNavigationInterface

@synthesize navigationHandlers;

- (id)init {
	if(self = [super init]) {						
		routeListener = new WFRouteListener();
		routeListener->setIPhoneRouteListener(self);		
		RouteInterface &routeInterface = APP_SESSION.nav2API->getRouteInterface();
		routeInterface.addRouteListener(routeListener);
		
		navigationInfoUpdateListener = new WFNavigationInfoUpdateListener();
		navigationInfoUpdateListener->setIPhoneNavigationInfoUpdateListener(self);
		NavigationInterface &navigationInterface = APP_SESSION.nav2API->getNavigationInterface();
		navigationInterface.addNavigationInfoUpdateListener(navigationInfoUpdateListener);
				
		NSMutableArray *navigationhandlers = [[NSMutableArray alloc] init];		
		self.navigationHandlers = navigationhandlers;
		
		[navigationhandlers release];
	}
	
	return self;
}

- (void)dealloc {
	delete routeListener;
	delete navigationInfoUpdateListener;
	self.navigationHandlers = nil;
	[super dealloc];
}

- (void)removeAllRequestsForRouteHandler:(id<RouteHandler>)routeHandler {
	NSNumber *num = [NSNumber numberWithUnsignedInt:(unsigned int)PERSISTENT_HANDLER_FOR_ALL_REQUESTS];	
	id<RouteHandler> handler = [requestHandlers objectForKey:num];
	[((NSObject *)handler) retain];
	// ehm - is this right?
	[requestHandlers removeAllObjects];	
	[requestHandlers setObject:handler forKey:num];
	[((NSObject *)handler) release];
}

- (void)setPersistentRouteHandler:(id<RouteHandler>)routeHandler {
	[self setRequestHandler:routeHandler forRequestWithID:[NSNumber numberWithUnsignedInt:(unsigned int)PERSISTENT_HANDLER_FOR_ALL_REQUESTS]];
}

- (void)setRequestTemporaryRouteHandler:(id<RouteHandler>)routeHandler {
	[self setRequestHandler:routeHandler forRequestWithID:[NSNumber numberWithUnsignedInt:(unsigned int)DUMMY_REQUEST_ID]];
}

- (void)setNavigationHandler:(id<NavigationHandler>)navigationHandler {
	[self.navigationHandlers addObject:navigationHandler];
}

- (void)removeNavigationHandler:(id<NavigationHandler>)navigationHandler {
	[self.navigationHandlers removeObject:navigationHandler];
}

- (void)routeFromCurrentPositionTo:(Position *)destination withTransportation:(Transportation *)transportationType andSetRouteHandler:(id<RouteHandler>)routeHandler {
	Position *currentPosition = [[Position alloc] initWithWGS84Coordinate:APP_SESSION.locationManager->currentPosition];
	[self routeFromOrigin:currentPosition to:destination withTransportation:transportationType andSetRouteHandler:routeHandler];
	[currentPosition release];
}

- (NSNumber *)routeFromOrigin:(Position *)start to:(Position *)destination withTransportation:(Transportation *) transportationType andSetRouteHandler:(id<RouteHandler>)routeHandler {
	InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(routeFromOrigin:to:withTransportation:andSetRouteHandler:) andParameters:[NSArray arrayWithObjects:start, destination, transportationType, routeHandler, nil]];
	RouteInterface &routeInterface = APP_SESSION.nav2API->getRouteInterface();				
	
// Note: Used by JZU for simulating navigation in the inner city of London	
#if 0	
	start.latDeg = 51.507410; 
	start.lonDeg = -0.127662;
	
	destination.latDeg = 52.208711; 
	destination.lonDeg = 0.122051;	
#endif
	
	IPNavSettingsManager *settingsManager = [IPNavSettingsManager sharedInstance];
	if([settingsManager useExplicitPosition]) {
		start.latitude = [settingsManager getLatitude];
		start.longitude = [settingsManager getLongitude];
	}	
	
	AsynchronousStatus status = routeInterface.routeBetweenCoordinates(start->coord, destination->coord, transportationType.tt);
	RequestID reqID = status.getRequestID();
	[self setRequestHandler:routeHandler andOutStandingRequest:req forRequestWithID:[NSNumber numberWithUnsignedInt:reqID.getID()]];
	[req release];
	// tell all handlers about the new route...
	for(id<RouteHandler> handler in [requestHandlers allValues]) {
		[handler requestedRouteFromOrigin:start->coord to:destination->coord withTransportation:transportationType.tt]; 		
	}
	return [NSNumber numberWithUnsignedInt:reqID.getID()];
}

- (void)stopRouting {
	RouteInterface &routeInterface = APP_SESSION.nav2API->getRouteInterface();				
	routeInterface.removeRoute();	
}

- (void)startNavigationWithNavigationHandler:(id<NavigationHandler>)navHandler  {
	[self setNavigationHandler:navHandler];
}

- (void)stopNavigationAndReleaseHandler:(id<NavigationHandler>)navHandler  {
	[self removeNavigationHandler:navHandler];
}

#pragma mark -
#pragma mark IPhoneBaseListener Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	// First we determine if the return status indicates that either the trial periode is over or that
	// a subscription has expired.
	// Note: This code is related to the AppStore billing solution which at this point has been superceeded
	// by a Vodafone billing solution.
/*
	if(status->getStatusCode() == UNAUTHORIZED_ERROR || status->getStatusCode() == EXPIRED_ERROR) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:status->getStatusURL().c_str()]];
		
		WFNavigationAppDelegate *delegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
		BillingViewController *billingController = [[BillingViewController alloc] initWithURL:url];
		[delegate.navController pushViewController:billingController animated:YES];
		[billingController release];
		
		return;
	}
*/
	// if this is a routing error...
	if (START_ROUTE_STATUS_CODE <= status->getStatusCode() && START_IMAGE_STATUS_CODE > status->getStatusCode()) {
		// if we're already downloading a route, we simply try again...
		if (ALREADY_DOWNLOADING_ROUTE == status->getStatusCode()) {
			InvocationRequest *req = [self getInvocationRequestForRequestWithID:[NSNumber numberWithUnsignedInt:status->getRequestID().getID()]];
			if (req != nil) {
				req.retries = 0;
				[req retry];
			}
		}
		else {
			// ...otherwise we simply pass on the error to any handler listening
			for(id<RouteHandler> handler in [requestHandlers allValues]) {
				[handler errorWithStatus:status]; 		
			}
		}
	}
	// if not, then pass it on to the error handler
	else {
		[[ErrorHandler sharedInstance] handleErrorWithStatus:status onInterface:self];
	}
}

#pragma mark -
#pragma mark IPhoneRouteListener Methods


- (void)delegateRouteReply:(NSNumber *)key {
	id<RouteHandler> theHandler = [requestHandlers objectForKey:key];
	if(theHandler != nil) {
		[theHandler routeReply];
	}	
}

- (void)routeReply:(RequestID *)requestID {	
		
	[self delegateRouteReply:[NSNumber numberWithUnsignedInt:PERSISTENT_HANDLER_FOR_ALL_REQUESTS]];
	[self delegateRouteReply:[NSNumber numberWithUnsignedInt:DUMMY_REQUEST_ID]];
	[self delegateRouteReply:[NSNumber numberWithUnsignedInt:requestID->getID()]];
}

- (void)delegateReachedEndOfRouteReply:(NSNumber *)key {
	id<RouteHandler> theHandler = [requestHandlers objectForKey:key];
	if(theHandler != nil) {
		[theHandler reachedEndOfRouteReply];
	}	
}

- (void)reachedEndOfRouteReply:(RequestID *)requestID {
	[self delegateReachedEndOfRouteReply:[NSNumber numberWithUnsignedInt:PERSISTENT_HANDLER_FOR_ALL_REQUESTS]];
	[self delegateReachedEndOfRouteReply:[NSNumber numberWithUnsignedInt:DUMMY_REQUEST_ID]];
	[self delegateReachedEndOfRouteReply:[NSNumber numberWithUnsignedInt:requestID->getID()]];	
}

#pragma mark -
#pragma mark IPhoneNavigationListener Methods

- (void)distanceUpdate:(UpdateNavigationDistanceInfo *)updateNavigationDistanceInfo {
	for(id<NavigationHandler> navigationHandler in self.navigationHandlers) {
		[navigationHandler distanceUpdate:updateNavigationDistanceInfo];
	}
}

- (void)infoUpdate:(UpdateNavigationInfo *)updateNavigationInfo {
	for(id<NavigationHandler> navigationHandler in self.navigationHandlers) {
		[navigationHandler infoUpdate:updateNavigationInfo];
	}	
}

- (void)playSound {
	for(id<NavigationHandler> navigationHandler in self.navigationHandlers) {
		[navigationHandler playSound];
	}		
}

- (void)prepareSound:(WFStringArray *)soundNames {
	for(id<NavigationHandler> navigationHandler in self.navigationHandlers) {
		[navigationHandler prepareSound:soundNames];
	}		
}

@end
