/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Route.h"
#import "AppSession.h"

#define ROUTE_IS_STORED @"RouteIsStored"
#define APP_WAS_INTERRUPTED @"AppWasInterrupted"
#define SAVED_DEST_LATITUDE @"SavedDestLatitude"
#define SAVED_DEST_LONGITUDE @"SavedDestLongitude"

@implementation Route

@synthesize isNavigating;
@synthesize routeStart;
@synthesize routeEnd;
@synthesize bbLeftBottomCorner;
@synthesize bbRightTopCorner;
@synthesize timeToGoal;
@synthesize distanceToGoal;	
@synthesize distanceToNextTurn;	
@synthesize currentStreetName;
@synthesize nextStreetName;
@synthesize nextAction;	
@synthesize crossing;
@synthesize leftSideTraffic;
@synthesize isHighWay;

- (id)init {
	if(self = [super init]) {
		isNavigating = NO;
		routeStart = WGS84Coordinate();
		routeEnd = WGS84Coordinate();
		bbLeftBottomCorner = WGS84Coordinate();
		bbRightTopCorner = WGS84Coordinate();
		
		timeToGoal = 0;
		distanceToGoal = 0;	
		distanceToNextTurn = 0;	
		self.currentStreetName = @"";
		self.nextStreetName = @"";
		nextAction = AHEAD;		
		crossing = NOCROSSING;
		leftSideTraffic = NO;
		isHighWay = NO;			
	}
	return self;
}

- (void) dealloc {
	self.currentStreetName = nil;
	self.nextStreetName = nil;
	
	[super dealloc];
}

- (void)storeRoute:(BOOL)interrupted {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:YES forKey:ROUTE_IS_STORED];
	[prefs setBool:interrupted forKey:APP_WAS_INTERRUPTED];
	[prefs setDouble:routeEnd.latDeg forKey:SAVED_DEST_LATITUDE];
	[prefs setDouble:routeEnd.lonDeg forKey:SAVED_DEST_LONGITUDE];	
	[prefs synchronize];		
}

+ (void)clearStoredRoute {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:NO forKey:ROUTE_IS_STORED];
	[prefs setBool:NO forKey:APP_WAS_INTERRUPTED];
	[prefs synchronize];			
}

+ (BOOL)hasAStoredRoute {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return [prefs boolForKey:ROUTE_IS_STORED];
}

+ (BOOL)applicationWasInterrupted {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return [prefs boolForKey:APP_WAS_INTERRUPTED];
}

+ (BOOL)navigationWasInterrupted {
	return [Route hasAStoredRoute] && [Route applicationWasInterrupted];
}

+ (void)reloadRouteWithStartAt:(WGS84Coordinate)start usingHandler:(id<RouteHandler>)handler {
	
	if([Route hasAStoredRoute]) 
	{
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		double lat = [prefs doubleForKey:SAVED_DEST_LATITUDE];	
		double lng = [prefs doubleForKey:SAVED_DEST_LONGITUDE];

		Position *startPos = [[Position alloc] initWithWGS84Coordinate:start];
		Position *destPos = [[Position alloc] initWithLatitude:lat andLongitude:lng];
		Transportation *transport = [[Transportation alloc] initWithType:CAR]; 
				
		[APP_SESSION.navigationManager.iPhoneNavigationInterface routeFromOrigin:startPos to:destPos withTransportation:transport andSetRouteHandler:handler];
		
		[startPos release];
		[destPos release];
		[transport release];
	}
}

@end
