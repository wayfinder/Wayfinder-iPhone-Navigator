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

#import "IPhoneBaseInterface.h"
#import "IPhoneLocationListener.h"
#import "IPhoneGeocodingListener.h"
#import "WFLocationListener.h"
#import "WFGeocodingListener.h"
#import "LocationHandler.h"
#import "GeocodingHandler.h"
#import "WGS84Coordinate.h"
#import "AreaUpdateInfo.h"
#import "LocationUpdateInfo.h"

// These two constants are used to center the map at the very first time when there is no info about the position. (They represent the coordinates of Tower Eiffel)
#define DEFAULT_LATITUDE 48.8583
#define DEFAULT_LONGITUDE 2.2945

#define LOST_GPS_SIGNAL_THRESHOLD 10

// Both of these structs mimic the corresponding CoreLib classes exactly, but as neither of these classes has any default or copy 
// constructure we cannot use them here here and consequently need something similar.

	
@interface IPhoneLocationInterface : IPhoneBaseInterface<IPhoneLocationListener, IPhoneGeocodingListener> {
	
	AreaUpdateInfo *lastAreaUpdate;
	LocationUpdateInfo *lastLocationUpdate;	

	BOOL gpsLocationIsAvailable;
	
@private
	NSMutableArray *locationHandlers;	
	
	WFLocationListener *locationListener;
	WFGeocodingListener *geocodingListener;	
	
	NSInteger inValidLocationCounts;
}

@property (nonatomic, retain) AreaUpdateInfo *lastAreaUpdate;
@property (nonatomic, retain) LocationUpdateInfo *lastLocationUpdate;
@property (nonatomic, assign) BOOL gpsLocationIsAvailable;
@property (nonatomic, retain) NSMutableArray *locationHandlers;
@property (nonatomic, assign) NSInteger inValidLocationCounts;

- (void)setLocationHandler:(id<LocationHandler>)handler;

- (void)removeLocationHandler:(id<LocationHandler>)handler;

- (NSNumber *)requestAreaBasedReverseGeocoding:(AreaUpdateInfo *)locationArea andSetGeocodingHandler:(id<GeocodingHandler>)handler;

- (NSNumber *)requestLocationBasedReverseGeocoding:(LocationUpdateInfo *)location andSetGeocodingHandler:(id<GeocodingHandler>)handler;

- (NSNumber *)requestLocationBasedReverseGeocodingAndSetGeocodingHandler:(id<GeocodingHandler>)handler;

- (void)removeGeocodingHandler:(id<GeocodingHandler>)handler;


@end
