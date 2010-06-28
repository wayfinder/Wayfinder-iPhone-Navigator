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
#import "PlaceDetailViewController.h"
#import "SearchResult.h"
#import "PlaceInfoEntry.h"
#import "ItemInfoEnums.h"
#import "IPNavSettingsManager.h"
#import "Formatter.h"

using namespace WFAPI;

@implementation SearchResult

@synthesize resultID;
@synthesize originalSearchItem;

- (id)initWithSearchItem:(SearchItem *)item {
	NSString *baseID = [NSString stringWithUTF8String:item->getID().c_str()];
	NSString *baseTitle = [[NSString alloc] initWithCString:item->getName().c_str() encoding:NSUTF8StringEncoding];
	NSString *baseSubTitle = [[NSString alloc] initWithCString:item->getLocationName().c_str() encoding:NSUTF8StringEncoding];
//	NSString *baseDistance = [[NSString alloc] initWithCString:item->getDistanceFromSearchPos(WFAPI::KM).c_str()];
//	NSUInteger baseDistInMeters = item->getDistanceFromSearchPos();
	NSUInteger baseDistInMeters = item->getDistanceFromPos(APP_SESSION.locationManager->currentPosition);
	NSString *baseDistance = [Formatter formatDistance:baseDistInMeters];
	NSString *baseImage = [[NSString alloc] initWithCString:item->getImageName().c_str()];
	NSString *baseDescription = @"";
	ItemInfoArray iia = item->getAdditionalInformation();
	if (self = [super initWithID:baseID title:baseTitle subTitle:baseSubTitle position:item->getPosition() distance:baseDistance distanceInMeters:baseDistInMeters image:baseImage description:baseDescription details:iia]) {
		self.resultID = [NSString stringWithUTF8String:item->getID().c_str()];
		self.originalSearchItem = new SearchItem(*item);
	}
	[baseTitle release];
	[baseSubTitle release];
	[baseImage release];
	return self;
}

- (void)updateSearchResultWithDetails:(ItemInfoArray *)itemInfoDetails {
}

- (Favourite)createFavourite {
	Favourite fav = [super createFavourite];
	fav.addItemInfoEntry(ItemInfoEntry(WFString("favimage"), WFString([self.image cStringUsingEncoding:NSUTF8StringEncoding]), DONT_SHOW));
	NSString *idString = [NSString stringWithFormat:@"%@-%.0f", self.placeID, [NSDate timeIntervalSinceReferenceDate]];
	fav.addItemInfoEntry(ItemInfoEntry(WFString("internalfavid"), WFString([idString cStringUsingEncoding:NSUTF8StringEncoding]), DONT_SHOW));
	return fav;
}

- (ItemInfoArray)getOriginalItemInfoArray {
	return self.originalSearchItem->getAdditionalInformation();
}

- (void)dealloc {
	
	[resultID release];
	
	delete self.originalSearchItem;
	
    [super dealloc];
}

- (void)prepareDetailsForViewController:(PlaceDetailViewController *)placeDetailViewController {
	[super prepareDetailsForViewController:placeDetailViewController];
	[APP_SESSION.searchInterface getDetailsForResultWithID:self.resultID andSetSearchHandler:placeDetailViewController];
}

@end
