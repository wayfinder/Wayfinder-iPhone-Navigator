/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "FavouritePlace.h"
#import "PlaceDetailViewController.h"
#import "PlaceInfoEntry.h"

@implementation FavouritePlace

@synthesize internalFavID;
@synthesize originalFavourite;

- (id)initWithFavourite:(Favourite *)favourite {
	NSString *baseID = [NSString stringWithFormat:@"%d", favourite->getID()];
	NSString *baseTitle = [[NSString alloc] initWithCString:favourite->getName().c_str() encoding:NSUTF8StringEncoding];
	NSString *baseSubTitle = @"";
	NSString *baseDistance = @"";
	NSUInteger baseDistInMeters = -1;
	NSString *baseImage = nil;
	NSString *baseDescription =  [[NSString alloc] initWithCString:favourite->getDescription().c_str() encoding:NSUTF8StringEncoding];
	ItemInfoArray iia = favourite->getInformationArray();
	if (self = [super initWithID:baseID title:baseTitle subTitle:baseSubTitle position:favourite->getPosition() distance:baseDistance distanceInMeters:baseDistInMeters image:baseImage description:baseDescription details:iia]) {
		self.originalFavourite = new Favourite(*favourite);
		for (ItemInfoArray::iterator it = iia.begin(); it < iia.end(); it++) {
			ItemInfoEntry entry = *it;
			PlaceInfoEntry *pie = [[PlaceInfoEntry alloc] initWithItemInfoEntry:&entry];
			if ([pie.key isEqualToString:@"internalfavid"]) {
				self.internalFavID = pie.value;
			}
			[pie release];
		}
	}
	[baseTitle release];
	[baseDescription release];
	
	return self;
}

- (Favourite)createFavourite {
	return [super createFavourite];
}

- (ItemInfoArray)getOriginalItemInfoArray {
	return self.originalFavourite->getInformationArray();
}

- (void)prepareDetailsForViewController:(PlaceDetailViewController *)placeDetailViewController {
	[super prepareDetailsForViewController:placeDetailViewController];
	placeDetailViewController.detailsFetched = true;
}

- (void)dealloc {
	self.internalFavID = nil;
	
	delete originalFavourite;
	
	[super dealloc];
}

@end
