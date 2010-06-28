/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneLocationInterface.h"
#import "LocationInterface.h"
#import "AppSession.h"
#import "StatusCode.h"
#import "GeocodingHandler.h"
#import "ErrorHandler.h"
#import "IPNavSettingsManager.h"

@implementation IPhoneLocationInterface

@synthesize lastAreaUpdate;
@synthesize lastLocationUpdate;	
@synthesize locationHandlers;
@synthesize gpsLocationIsAvailable;
@synthesize inValidLocationCounts;

#define MAX_ULP 0.00000001
//#define UNDEFINED_LATITUDE 180
//#define UNDEFINED_LONGITUDE 180

- (id)init {
	if(self = [super init]) {						
		locationListener = new WFLocationListener();
		locationListener->setIPhoneLocationListener(self);		
		
		geocodingListener = new WFGeocodingListener();
		geocodingListener->setIPhoneGeocodingListener(self);
		
		LocationInterface &locationInterface = APP_SESSION.nav2API->getLocationInterface();
		locationInterface.addLocationListener(locationListener);
		locationInterface.addGeocodingListener(geocodingListener);
				
		self.locationHandlers = [[NSMutableArray alloc] init];		
		[locationHandlers release];
		
		self.gpsLocationIsAvailable = NO;
		self.inValidLocationCounts = 0;
	}
	
	return self;
}

- (void)dealloc {
	locationListener->setIPhoneLocationListener(nil);
	delete locationListener;
	
	geocodingListener->setIPhoneGeocodingListener(nil);
	delete geocodingListener;
	
	self.lastAreaUpdate = nil;
	self.lastLocationUpdate = nil;
	[locationHandlers release];
	
	[super dealloc];
}

- (void)setLocationHandler:(id<LocationHandler>)handler {
	[self.locationHandlers addObject:handler];
}

- (void)removeLocationHandler:(id<LocationHandler>)handler {
	// This method relies on isEqual (which in turn uses the hash method) so is it safe to use in this context?
	[self.locationHandlers removeObject:handler];
}

- (NSNumber *)requestAreaBasedReverseGeocoding:(AreaUpdateInfo *)locationArea andSetGeocodingHandler:(id<GeocodingHandler>)handler {
	LocationInterface &locationInterface = APP_SESSION.nav2API->getLocationInterface();

	AreaUpdateInformation *coreType = [locationArea newAreaUpdateInformationInstance];
	AsynchronousStatus status = locationInterface.requestReverseGeocoding(*coreType);
	NSNumber *requestID = [NSNumber numberWithUnsignedInt: status.getRequestID().getID()];
	delete coreType;
	
	if(status.getStatusCode() == OK) {
		InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(requestAreaBasedReverseGeocoding:andSetGeocodingHandler:) andParameters:[NSArray arrayWithObjects:locationArea, handler, nil]];
		[self setRequestHandler:handler andOutStandingRequest:req forRequestWithID:requestID];
		[req release];
	}
	return requestID;
}

- (NSNumber *)requestLocationBasedReverseGeocoding:(LocationUpdateInfo *)location andSetGeocodingHandler:(id<GeocodingHandler>)handler {
	LocationInterface &locationInterface = APP_SESSION.nav2API->getLocationInterface();
	
	LocationUpdateInformation *coreType = [location newLocationUpdateInformationInstance];
	AsynchronousStatus status = locationInterface.requestReverseGeocoding(*coreType);
	NSNumber *requestID = [NSNumber numberWithUnsignedInt: status.getRequestID().getID()];
	delete coreType;
	
	if(status.getStatusCode() == OK) {
		InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(requestLocationBasedReverseGeocoding:andSetGeocodingHandler:) andParameters:[NSArray arrayWithObjects:location, handler, nil]];
		[self setRequestHandler:handler andOutStandingRequest:req forRequestWithID:requestID];
		[req release];
	}
	return requestID;
}

- (NSNumber *)requestLocationBasedReverseGeocodingAndSetGeocodingHandler:(id<GeocodingHandler>)handler {
	NSNumber *reqID;
	if(self.gpsLocationIsAvailable) {
		reqID = [self requestLocationBasedReverseGeocoding:self.lastLocationUpdate andSetGeocodingHandler:handler];		
	}
	else {
		reqID = [self requestAreaBasedReverseGeocoding:self.lastAreaUpdate andSetGeocodingHandler:handler];	
	}
	return reqID;
}

- (void)removeGeocodingHandler:(id<GeocodingHandler>)handler {
	NSArray *keys = [requestHandlers allKeysForObject:handler];
	[requestHandlers removeObjectsForKeys:keys];
}

/** 
 * Helper function floatAlmostEqualULP version - fast and simple, but
 * some limitations. the maximum error is passed in terms of "Units in the Last Place".
 */
- (BOOL) is:(float)a almostEqualTo:(float)b {
    assert(sizeof(float) == sizeof(int));
    if(a == b)
        return true;
	
    int intDiff = abs(*(int*)&b - *(int*)&a);
    if (intDiff <= MAX_ULP)
        return true;
	
	return false;
}

#pragma mark -
#pragma mark IPhoneLocationListener Methods

- (void)areaUpdateReply:(AreaUpdateInformation *)areaUpdateInformation {
	WGS84Coordinate pos = areaUpdateInformation->getPosition();
	
	if([self is:pos.latDeg almostEqualTo:180.0] && [self is:pos.lonDeg almostEqualTo:180.0]) {
		return;
	}
	
	AreaUpdateInfo *ourType = [[AreaUpdateInfo alloc] initWithAreaUpdateInformation:areaUpdateInformation];
	self.lastAreaUpdate = ourType;
	[ourType release];
	self.gpsLocationIsAvailable = NO;
	
	for(id<LocationHandler> handler in self.locationHandlers) {
		[handler positionUpdated];
	}	
}

- (void)locationUpdate:(LocationUpdateInformation *)locationUpdate {
	WGS84Coordinate pos = locationUpdate->getPosition();
	
	if([self is:pos.latDeg almostEqualTo:180.0] && [self is:pos.lonDeg almostEqualTo:180.0]) {
		return;
	}
	
	LocationUpdateInfo *ourType = [[LocationUpdateInfo alloc] initWithLocationUpdateInformation:locationUpdate];

	IPNavSettingsManager *settingsManager = [IPNavSettingsManager sharedInstance];
	if([settingsManager useExplicitPosition] && self.lastLocationUpdate != nil) {
		WGS84Coordinate pos;
		pos.latDeg = [settingsManager getLatitude];
		pos.lonDeg = [settingsManager getLongitude];
		self.lastLocationUpdate->position = pos;
	}
	else {
		self.lastLocationUpdate = ourType;
	}
	[ourType release];
	
	if(self.lastLocationUpdate.position.isValid()) {
		self.gpsLocationIsAvailable = YES;	
		self.inValidLocationCounts = 0;
	}
	else {
		self.inValidLocationCounts++;
		if(self.inValidLocationCounts > LOST_GPS_SIGNAL_THRESHOLD) {
			self.inValidLocationCounts = LOST_GPS_SIGNAL_THRESHOLD;
			self.gpsLocationIsAvailable = NO;				
		}
	}
	
	for(id<LocationHandler> handler in self.locationHandlers) {
		[handler positionUpdated];
	}	
}

- (void)startedLbs {
	for(id<LocationHandler> handler in self.locationHandlers) {
		[handler locationBasedServiceStarted];
	}		
}

#pragma mark -
#pragma mark IPhoneGeocodingListener Methods

- (void)reverseGeocodingReply:(GeocodingInformation *)info {
	// Right now the request id assigned to the geocoding request is not returned by to the listener and
	// so we have no means to identify which handler should receive the response if case of multiple 
	// outstanding request. Consequently, we just return the response to each of the handlers and remove
	// them from the collection. This should be changed in the future when the request id is correctly
	// returned to the listener.
	
	for(id<GeocodingHandler> handler in [requestHandlers allValues]) {
		[handler reverseGeocodingReady:info];
	}
	
	[requestHandlers removeAllObjects];
}

#pragma mark -
#pragma mark IPhoneBaseListener Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	// LBS errors are not real errors, only status messages, and are not sent here
	// Rev. geocoding doesn't have it's own errors - so all errors occuring here must be general errors (including network errors)
	[[ErrorHandler sharedInstance] handleErrorWithStatus:status onInterface:self];
}

@end
