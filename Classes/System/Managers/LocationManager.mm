/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "LocationManager.h"

#import "AppSession.h"
#import "LocationInterface.h"
#import "AsynchronousStatus.h"
#import "ErrorHandler.h"
#import "IPhoneLocationInterface.h"

@implementation LocationManager

@synthesize receivedFirstGoodPosition;
@synthesize useRoutingInformation;
@synthesize currentPosition;
@synthesize currentHeading;
@synthesize currentSpeed;
@synthesize iPhoneLocationInterface;

- (id)init {
	if(self = [super init]) {
		positionUpdateCounter = 0;
		
		self.receivedFirstGoodPosition = NO;
		self.useRoutingInformation = NO;
		self.currentHeading = 0;

		// At startup, load the last saved user position coordinates and use them to center the map until the updated positions arrive. If there is no last position saved, just use the Eiffel Tower's position
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if (![userDefaults objectForKey:LAST_SAVED_LONGITUDE]) {
			[userDefaults setFloat:DEFAULT_LATITUDE forKey:LAST_SAVED_LATITUDE];
			[userDefaults setFloat:DEFAULT_LONGITUDE forKey:LAST_SAVED_LONGITUDE];
			[userDefaults synchronize];
		}
			
		float lastLon = [userDefaults floatForKey:LAST_SAVED_LONGITUDE];
		float lastLat = [userDefaults floatForKey:LAST_SAVED_LATITUDE];
		
		self.currentPosition = WGS84Coordinate(lastLat, lastLon);

		iPhoneLocationInterface = [[IPhoneLocationInterface alloc] init];
		[iPhoneLocationInterface retain];
		
		[self.iPhoneLocationInterface setLocationHandler:self];		
		
		LocationInterface &locationInterface = APP_SESSION.nav2API->getLocationInterface();
		AsynchronousStatus startLbsStatus = locationInterface.startLbs();
		if(startLbsStatus.getStatusCode() != WFAPI::OK) {
			NSLog(@"Error: Starting the Location Based Service failed with reason code == %d", startLbsStatus.getStatusCode());
		}
	}
	return self;
}

- (void)dealloc {
	[iPhoneLocationInterface release];
	[super dealloc];
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
}

#pragma mark -
#pragma mark LocationHandler Methods

- (void)positionUpdated {
	self.receivedFirstGoodPosition = YES;
	NSString *loctype;
	
	if(!self.useRoutingInformation) {
		if(self.iPhoneLocationInterface.gpsLocationIsAvailable) {
			self.currentPosition = self.iPhoneLocationInterface.lastLocationUpdate->position;
			self.currentHeading = self.iPhoneLocationInterface.lastLocationUpdate.heading;
			self.currentSpeed = self.iPhoneLocationInterface.lastLocationUpdate.speed;			
			loctype = @"GPS";
		}
		else {
			self.currentPosition = self.iPhoneLocationInterface.lastAreaUpdate->position;
			self.currentHeading = 0;
			self.currentSpeed = 0;						
			loctype = @"Area";
		}		
	}
	else {
		self.currentPosition = self.iPhoneLocationInterface.lastLocationUpdate->routePosition; 
		self.currentHeading = self.iPhoneLocationInterface.lastLocationUpdate.routeHeading;
		self.currentSpeed = self.iPhoneLocationInterface.lastLocationUpdate.speed;					
		loctype = @"Route";
	}	
	
	NSLog(@"Location Update (%@): La=%f Lo=%f Hd=%d", loctype, currentPosition.latDeg, currentPosition.lonDeg, self.currentHeading);	
}

- (void)locationBasedServiceStarted {
	NSLog(@"Location based services has been started.");
}

#pragma mark - 

- (BOOL)isCurrentPositionAnUpdateRefreshFromDefaultPosition
{
	positionUpdateCounter++;
	
	return (1 == positionUpdateCounter);
}

- (void)saveLastPosition
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setFloat:currentPosition.latDeg forKey:LAST_SAVED_LATITUDE];
	[userDefaults setFloat:currentPosition.lonDeg forKey:LAST_SAVED_LONGITUDE];
	[userDefaults synchronize];
	//NSLog(@"----- Saved last position: (%f., %f)", currentPosition.latDeg, currentPosition.lonDeg);
}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
