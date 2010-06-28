/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "LocationUpdateInfo.h"

@implementation LocationUpdateInfo

@synthesize altitude;
@synthesize heading;
@synthesize gpsQuality;
@synthesize position;
@synthesize speed;
@synthesize routePosition;
@synthesize routeHeading;

- (id)initWithLocationUpdateInformation:(LocationUpdateInformation *)locationUpdateInformation {
	if (self = [super init]) {
		self.altitude = locationUpdateInformation->getAltitude();
		self.heading = locationUpdateInformation->getHeading();
		self.gpsQuality = locationUpdateInformation->getGpsQuality();
		self.position = locationUpdateInformation->getPosition();
		self.speed = locationUpdateInformation->getSpeed();
		self.routePosition = locationUpdateInformation->getRoutePosition();
		self.routeHeading = locationUpdateInformation->getRouteHeading();
	}
	return self;
}

- (LocationUpdateInformation *)newLocationUpdateInformationInstance {
	return new LocationUpdateInformation(position, altitude, heading, gpsQuality, speed, routePosition, routeHeading);
}

@end
