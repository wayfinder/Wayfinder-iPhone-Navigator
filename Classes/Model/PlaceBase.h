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

#import "Favourite.h"
#import "ItemInfoEntryArray.h"
#import "WGS84Coordinate.h"

using namespace WFAPI;

@class PlaceDetailViewController;

@interface PlaceBase : NSObject {
@public
	
	NSString *placeID;
	NSString *title;
	NSString *subTitle;
	NSString *supplier;
	WGS84Coordinate position;
//	NSString *distance;
	NSUInteger distanceInMeters;
	NSString *image;
	NSString *description;
	
	NSMutableArray *details;
}

@property (nonatomic, retain) NSString *placeID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSString *supplier;
@property (nonatomic, assign) WGS84Coordinate position;
//@property (nonatomic, retain) NSString *distance; // Commented out variable because the distance will be formatted dynamically from now on and'll not be kept in this var.
@property (nonatomic, assign) NSUInteger distanceInMeters;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSMutableArray *details;

- (id)initWithID:(NSString *)thePlaceID
		   title:(NSString *)theTitle
		subTitle:(NSString *)theSubTitle
		position:(WGS84Coordinate)thePosition
		distance:(NSString *)theDistance
distanceInMeters:(NSUInteger)theDistanceInMeters
		   image:(NSString *)theImage
	 description:(NSString *)theDescription
		 details:(ItemInfoArray)theDetails;

- (void)prepareDetailsForViewController:(PlaceDetailViewController *)placeDetailViewController;

- (Favourite)createFavourite;

- (ItemInfoArray)getOriginalItemInfoArray;

@end
