/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PlaceBase.h"
#import "PlaceInfoEntry.h"
#import "PlaceDetailViewController.h"

@implementation PlaceBase

@synthesize placeID;
@synthesize title;
@synthesize subTitle;
@synthesize supplier;
@synthesize position;
//@synthesize distance;
@synthesize distanceInMeters;
@synthesize image;
@synthesize description;
@synthesize details;

- (id)initWithID:(NSString *)thePlaceID
		   title:(NSString *)theTitle
		subTitle:(NSString *)theSubTitle
		position:(WGS84Coordinate)thePosition
		distance:(NSString *)theDistance
distanceInMeters:(NSUInteger)theDistanceInMeters
		   image:(NSString *)theImage
	 description:(NSString *)theDescription
		 details:(ItemInfoArray)theDetails {
	if (self = [super init]) {
		self.placeID = thePlaceID;
		self.title = theTitle;
		self.subTitle = theSubTitle;
		self.position = thePosition;
//		self.distance = theDistance;
		self.distanceInMeters = theDistanceInMeters;
		self.image = theImage;
		self.description = theDescription;
		NSMutableArray *baseDetails = [[NSMutableArray alloc] init];
		for (ItemInfoArray::iterator it = theDetails.begin(); it < theDetails.end(); it++) {
			ItemInfoEntry entry = *it;
			PlaceInfoEntry *pie = [[PlaceInfoEntry alloc] initWithItemInfoEntry:&entry];
//			NSLog(@"[%d] %@ -> %@", pie.infoType, pie.key, pie.value);
			if ([pie.key isEqualToString:@"favimage"] && self.image == nil) {
				self.image = pie.value;
			}
			else if (pie.infoType == LONG_DESCRIPTION && (self.description == nil || [self.description length] == 0)) {
				self.description = pie.value;
			}
			else if (pie.infoType == SUPPLIER) {
				self.supplier = pie.value;
			}
			else if (pie.infoType != DONT_SHOW) {
				[baseDetails addObject:pie];
			}
			[pie release];	
		}
		
		self.details = baseDetails;
		[baseDetails release];
	}
	return self;
}

- (NSUInteger)placeIntID {
	NSString *stringID = self.placeID;
	NSArray *idComponents = [stringID componentsSeparatedByString:@":"];
	return [[idComponents objectAtIndex:1] intValue];
}

- (Favourite)createFavourite {
	Favourite fav;
	fav.setPosition(position);
	fav.setName([self.title cStringUsingEncoding:NSUTF8StringEncoding]);
	if (self.description != nil) {
		fav.setDescription([self.description cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	ItemInfoArray iia = [self getOriginalItemInfoArray];
	ItemInfoArray::iterator it;
	for (it = iia.begin(); it != iia.end(); it++) {
		ItemInfoEntry iie = *it;
		fav.addItemInfoEntry(iie);
	}
	return fav;
}

- (ItemInfoArray)getOriginalItemInfoArray {
	ItemInfoArray iia;
	return iia;
}

- (void)dealloc {
	self.placeID = nil;
	self.title = nil;
	self.subTitle = nil;
	self.supplier = nil;
//	self.distance = nil;
	self.distanceInMeters = nil;
	self.image = nil;
	self.description = nil;
	self.details = nil;
	
    [super dealloc];
}

- (void)prepareDetailsForViewController:(PlaceDetailViewController *)placeDetailViewController {
	// do call this, before you do whatever you have to do in the subclass
	placeDetailViewController.place = self;
}

@end
