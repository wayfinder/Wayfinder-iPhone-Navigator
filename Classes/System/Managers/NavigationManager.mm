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
#import "NavigationManager.h"
#import "UpdateNavigationDistanceInfo.h"
#import "UpdateNavigationInfo.h"
#import "ErrorHandler.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

@implementation NavigationManager

@synthesize iPhoneNavigationInterface;
@synthesize transportationType;
@synthesize start;
@synthesize destination;
@synthesize currentRoute;

- (id)init {
	if(self = [super init]) {
		
		iPhoneNavigationInterface = [[IPhoneNavigationInterface alloc] init];
		[iPhoneNavigationInterface retain];
		
		[self.iPhoneNavigationInterface setPersistentRouteHandler:self];		
		[self.iPhoneNavigationInterface setNavigationHandler:self];		
	}
	return self;
}

- (void)dealloc {
	[iPhoneNavigationInterface release];
	[super dealloc];
}

- (BOOL)hasRoute {
	return self.currentRoute != nil;
}

- (void)cancelRoute {
	if(APP_SESSION.mapLibAPI != nil) {
		[self.iPhoneNavigationInterface stopRouting];
		self.currentRoute = nil;
		// Location manager should now use the actual measured location
		APP_SESSION.locationManager.useRoutingInformation = NO;
	}
}

- (BOOL)isNavigating {
	if(APP_SESSION.navigationManager.currentRoute != nil) {
		return APP_SESSION.navigationManager.currentRoute.isNavigating;
	}
	
	return NO;
}

- (void)calculateRouteBoundingBox:(RouteInfoItemArray *) routeInfos {
	WGS84Coordinate firstCorner;
	WGS84Coordinate secondCorner;
	
	// First we normalize the coordinates so that the first coordinate encompases the bottom
	// left corner of the initial bounding box and the second the upper right corner.	
	firstCorner.latDeg = min(self.start.latDeg, self.destination.latDeg);
	firstCorner.lonDeg = min(self.start.lonDeg, self.destination.lonDeg);

	secondCorner.latDeg = max(self.start.latDeg, self.destination.latDeg);
	secondCorner.lonDeg = max(self.start.lonDeg, self.destination.lonDeg);
		
	// Now we iterate over the remaining route elements (if any) and for each
	// we determine if it lies outside the current bounding box. If it does
	// we extend the bounding box so that is exactly includes the next position.
	for(int r = 0; r < routeInfos->size(); r++) {
		WGS84Coordinate coord = routeInfos->at(r).getCoordinate();
		if(coord.latDeg < firstCorner.latDeg) firstCorner.latDeg = coord.latDeg;
		if(coord.latDeg > secondCorner.latDeg) secondCorner.latDeg = coord.latDeg;
		if(coord.lonDeg < firstCorner.lonDeg) firstCorner.lonDeg = coord.lonDeg;
		if(coord.lonDeg > secondCorner.lonDeg) secondCorner.lonDeg = coord.lonDeg;			
	}
	
	// Now we have a bounding box covering the complete route.
	// TODO: We need to handle the two extreme cases where the start and destination
	// location either are very far from or close to each other.
	self.currentRoute.bbLeftBottomCorner = firstCorner;
	self.currentRoute.bbRightTopCorner = secondCorner;
}

#pragma mark -
#pragma mark BaseHandler Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
//	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];	
}

#pragma mark -
#pragma mark RouteHandler Methods

- (void)requestedRouteFromOrigin:(WGS84Coordinate)startCoord to:(WGS84Coordinate)destinationCoord withTransportation:(TransportationType) transportType {

	self.transportationType = transportType;
	self.start = startCoord;
	self.destination = destinationCoord;
	
	self.currentRoute = nil;
}

- (void)routeReply {	
	self.currentRoute = [[Route alloc] init];
	[self.currentRoute release];
	
	RouteInterface &routeInterface = APP_SESSION.nav2API->getRouteInterface();	
	RouteInfoItemArray routeInfos;
	routeInterface.getRouteList(routeInfos);
	
	if(routeInfos.size() > 0) {
		[self calculateRouteBoundingBox:&routeInfos];
		
		RouteInfoItem &routeInfo = routeInfos.front();
		RouteInfoItem &lastRouteInfo = routeInfos.back();
				
		self.currentRoute.timeToGoal = routeInfo.getTimeToGoal();
		self.currentRoute.distanceToGoal = routeInfo.getDistanceToGoal();	
		self.currentRoute.distanceToNextTurn = routeInfo.getDistanceToNextTurn();
		self.currentRoute.nextAction = routeInfo.getAction();

		self.currentRoute.crossing = routeInfo.getCrossing();
		self.currentRoute.leftSideTraffic = routeInfo.getIfLeftSideTraffic();
		self.currentRoute.isHighWay = routeInfo.getIfHighWay();
		self.currentRoute.routeStart = routeInfo.getCoordinate();
		self.currentRoute.routeEnd = lastRouteInfo.getCoordinate();;		
		
		const WFString &currentStreetName = routeInfo.getStreetName();	
		self.currentRoute.currentStreetName = [NSString stringWithCString:currentStreetName.c_str() encoding:NSUTF8StringEncoding];
 		
		if(routeInfos.size() > 1) {
			RouteInfoItem &routeInfo = routeInfos.at(1);
			const WFString &nextStreetName =  routeInfo.getStreetName();	
			self.currentRoute.nextStreetName = [NSString stringWithCString:nextStreetName.c_str() encoding:NSUTF8StringEncoding];			
		}
		
		// We are now navigating
		self.currentRoute.isNavigating = YES;				
		// Location update should use route adjusted positions
		APP_SESSION.locationManager.useRoutingInformation = YES;
	}
}

- (void)reachedEndOfRouteReply {

}

- (void)purchaseRequired:(NSString *)productId {

}

#pragma mark -
#pragma mark NavigationHandler Methods


- (void)distanceUpdate:(UpdateNavigationDistanceInfo *)updateNavigationDistanceInfo {
	self.currentRoute.distanceToGoal = updateNavigationDistanceInfo->getDistanceToGoal();	
	self.currentRoute.distanceToNextTurn = updateNavigationDistanceInfo->getDistanceToNextTurn();
}

- (void)infoUpdate:(UpdateNavigationInfo *)updateNavigationInfo {
	self.currentRoute.timeToGoal = updateNavigationInfo->getTimeToGoal();
	self.currentRoute.distanceToGoal = updateNavigationInfo->getDistanceToGoal();	
	self.currentRoute.distanceToNextTurn = updateNavigationInfo->getDistanceToNextTurn();
	const WFString &currentStreetName = updateNavigationInfo->getCurrentStreetName();	
	self.currentRoute.currentStreetName = [NSString stringWithCString:currentStreetName.c_str() encoding:NSUTF8StringEncoding];
	const WFString &nextStreetName = updateNavigationInfo->getNextStreetName();
	self.currentRoute.nextStreetName = [NSString stringWithCString:nextStreetName.c_str() encoding:NSUTF8StringEncoding];
	self.currentRoute.nextAction = updateNavigationInfo->getNextAction();
	self.currentRoute.crossing = updateNavigationInfo->getNextCrossing();
	self.currentRoute.leftSideTraffic = updateNavigationInfo->getIfLeftSideTraffic();
	self.currentRoute.isHighWay = updateNavigationInfo->getNextHighway();		
	
}

- (void)playSound {

}

- (void)prepareSound:(WFStringArray *)soundNames {

}

- (void)requestCancelled:(NSNumber *)requestID {
	// we don't care
}

@end
