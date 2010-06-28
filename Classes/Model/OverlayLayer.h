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
#import "WGS84Coordinate.h"
#import "OverlayInterface.h"
#import "OverlayItem.h"
#import "PlaceBase.h"

using namespace WFAPI;

@interface OverlayLayer : NSObject {
@public
	OverlayInterface *_interface;
	
	// layer identifier
	NSString *_layerIdentifier;
	
	// items added to this layer
	NSMutableArray *_items;
	
	// coordonate that defines the center of the map
//	WGS84Coordinate _center;
	
	// coordonates needed to define world box
	WGS84Coordinate _firstCorner;
	WGS84Coordinate _secondCorner;
	
	BOOL _hidden;
}

@property (nonatomic, retain) NSString *layerIdentifier;
@property (nonatomic, retain) NSMutableArray *items;
//@property (nonatomic, assign) WFAPI::WGS84Coordinate center;
@property (nonatomic, assign) WGS84Coordinate firstCorner;
@property (nonatomic, assign) WGS84Coordinate secondCorner;
@property (nonatomic, readonly) BOOL hidden;

- (id)initWithIdentifier:(NSString *)identifier;

/* use this method to display favourites and search items on the map*/
- (void)addItems:(NSArray *)items aroundMe:(BOOL)around showOnMap:(BOOL)showOnMap;
- (OverlayItem *)overlayItemFromPlaceBase:(PlaceBase *)place;


- (void)setHidden:(BOOL)hidden;
- (void)reset;

@end
