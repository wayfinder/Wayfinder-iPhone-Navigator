/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "OverlayLayer.h"
#import "PlaceBase.h"
#import "SearchResult.h"
#import "WGS84Coordinate.h"
#import "AppSession.h"
#import "OverlayItemDescriptionView.h"
#import "OverlayItemVisualSpec.h"
#import "OverlayItemZoomSpec.h"
#import "IPhoneFactory.h"


#define AROUND_ME_MAX_RADIUS (100000)

@implementation OverlayLayer

@synthesize layerIdentifier = _layerIdentifier;
@synthesize items = _items;
//@synthesize center = _center;
@synthesize firstCorner = _firstCorner;
@synthesize secondCorner = _secondCorner;
@synthesize hidden = _hidden;

- (id)initWithIdentifier:(NSString *)identifier {
	self = [super init];
	if (!self) return nil;
	
	// get core interface for map overlay
	_interface = APP_SESSION.mapLibAPI->getOverlayInterface();
	
	_layerIdentifier = [identifier retain];
	_items = [[NSMutableArray alloc] init];
	
//	_center = WGS84Coordinate(180.0, 180.0);
	
	[self reset];
	
	return self;
}

- (void)reset
{
	_firstCorner = WGS84Coordinate(10000.0, 10000.0);
	_secondCorner = WGS84Coordinate(-10000.0, -10000.0);
	[self setHidden:YES];
}

- (void)dealloc {	
	[self setHidden:YES];
	[_layerIdentifier release];
	[_items release];
	
	[super dealloc];
}

- (void)addItems:(NSArray *)items aroundMe:(BOOL)around showOnMap:(BOOL)showOnMap
{
	if (0 == [items count]) {
		return;
	}
	
	double minLat = _firstCorner.latDeg , maxLat = _secondCorner.latDeg;
	double minLon = _firstCorner.lonDeg , maxLon = _secondCorner.lonDeg;
	
	for (NSUInteger index = 0, count = [items count]; index < count; index++) {
		
		PlaceBase *item = [items objectAtIndex:index];
		WGS84Coordinate itemPosition = [item position];
		
		if (![_items containsObject:[item placeID]]) {
			
			WGS84Coordinate itemPosition = [item position];
			
			if ([item isKindOfClass:[SearchResult class]]) {
				SearchItem *searchItem = [(SearchResult *)item originalSearchItem];
				NSUInteger baseDistInMeters = searchItem->getDistanceFromSearchPos();
				
				if ((!around) || ((around) && (AROUND_ME_MAX_RADIUS > baseDistInMeters))) {
					if (itemPosition.isValid()) {
						if (itemPosition.latDeg < minLat) {
							minLat = itemPosition.latDeg;
						}
						if (itemPosition.latDeg > maxLat) {
							maxLat = itemPosition.latDeg;
						}
						if (itemPosition.lonDeg < minLon) {
							minLon = itemPosition.lonDeg;
						}
						if (itemPosition.lonDeg > maxLon) {
							maxLon = itemPosition.lonDeg;
						}
					}
				}
			} else {
				if (itemPosition.isValid()) {
					if (itemPosition.latDeg < minLat) {
						minLat = itemPosition.latDeg;
					}
					if (itemPosition.latDeg > maxLat) {
						maxLat = itemPosition.latDeg;
					}
					if (itemPosition.lonDeg < minLon) {
						minLon = itemPosition.lonDeg;
					}
					if (itemPosition.lonDeg > maxLon) {
						maxLon = itemPosition.lonDeg;
					}
				}
			}
			
			if (showOnMap) {
				OverlayItem *overlayItem = [self overlayItemFromPlaceBase:item];
				_interface->addOverlayItem(overlayItem, [_layerIdentifier intValue]);
				overlayItem->removeReference();
			}
		}
	}
	
	_firstCorner = WGS84Coordinate(minLat, minLon);
	_secondCorner = WGS84Coordinate(maxLat, maxLon);
}

- (OverlayItem *)overlayItemFromPlaceBase:(PlaceBase *)place {
	// get favourite position
	WGS84Coordinate coordinates = [place position];
	
	// define map object info
	MapObjectInfo placeInfo([[place title] UTF8String], 1, [[place placeID] UTF8String]);
	
	UIImage *image = [ImageFactory getImageNamed:[place image]];
	ScreenPoint imagePosition = ScreenPoint(round(image.size.width / 2), round(image.size.width / 2));
	
	// define zoom and visual specs for all states
	ImageSpec *itemImage = IPhoneFactory::createIPhoneImageSpec([image CGImage]); // for now we use the default image
	OverlayItemVisualSpec *visualSpec = OverlayItemVisualSpec::allocate(itemImage, imagePosition, imagePosition, 0); // ? focus point vs center point
	OverlayItemZoomSpec *zoomSpec = OverlayItemZoomSpec::allocate();
	// normal specs, stacked specs, normal taped specs, stacked tapped specs ??? what does this mean ???
	zoomSpec->addZoomLevelRange(0,100000, visualSpec, visualSpec);
	zoomSpec->setHighlightedSpecs(visualSpec, visualSpec);
	
	// create overlay item
	OverlayItem* overlayItem = OverlayItem::allocate(zoomSpec, placeInfo, coordinates);
	//overlayItem->setStackable(true);
	[APP_SESSION.overlayInterface linkItem:place withOverlayItem:overlayItem];
	
	return overlayItem;
}

// TODO(Fabian): find a proper name to this method
- (void)setHidden:(BOOL)hidden {
	
	_hidden = hidden;
	if (hidden) {
		_interface->clearLayer([_layerIdentifier intValue]);
	}
}

@end
