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

#import "Nav2API.h"
#import "MapLibAPI.h"
#import "EAGLView.h"
#import "IPhoneNavigationInterface.h"
#import "IPhoneSearchInterface.h"
#import "WGS84Coordinate.h"
#import "RouteAction.h"
#import "SearchHistoryDataSource.h"
#import "ImageFactory.h"
#import "RouteCrossing.h"
#import "RouteHandler.h"

@interface Route : NSObject {
@public
	BOOL isNavigating;
	WGS84Coordinate routeStart;
	WGS84Coordinate routeEnd;
	WGS84Coordinate bbLeftBottomCorner;
	WGS84Coordinate bbRightTopCorner;
	
	NSInteger timeToGoal;
	NSInteger distanceToGoal;	
	NSInteger distanceToNextTurn;	
	NSString *currentStreetName;
	NSString *nextStreetName;
	RouteAction nextAction;	
	RouteCrossing crossing;
	BOOL leftSideTraffic;
	BOOL isHighWay;
}

@property (nonatomic, assign) BOOL isNavigating;
@property (nonatomic, assign) WGS84Coordinate routeStart;
@property (nonatomic, assign) WGS84Coordinate routeEnd;
@property (nonatomic, assign) WGS84Coordinate bbLeftBottomCorner;
@property (nonatomic, assign) WGS84Coordinate bbRightTopCorner;
@property (nonatomic, assign) NSInteger timeToGoal;
@property (nonatomic, assign) NSInteger distanceToGoal;	
@property (nonatomic, assign) NSInteger distanceToNextTurn;	
@property (nonatomic, retain) NSString *currentStreetName;
@property (nonatomic, retain) NSString *nextStreetName;
@property (nonatomic, assign) RouteAction nextAction;		
@property (nonatomic, assign) RouteCrossing crossing;
@property (nonatomic, assign) BOOL leftSideTraffic;
@property (nonatomic, assign) BOOL isHighWay;

- (void)storeRoute:(BOOL)interrupted;

+ (void)clearStoredRoute;

+ (BOOL)hasAStoredRoute;

+ (BOOL)applicationWasInterrupted;

+ (BOOL)navigationWasInterrupted;

+ (void)reloadRouteWithStartAt:(WGS84Coordinate)start usingHandler:(id<RouteHandler>)handler;

@end
