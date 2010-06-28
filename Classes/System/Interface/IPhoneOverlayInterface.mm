/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneOverlayInterface.h"
#import "WFNavigationAppDelegate.h"
#import "OverlayItemDescriptionView.h"
#import "MapDrawingInterface.h"
#import "WFSelectedMapObjectListener.h"
#import "OverlayItemVisualSpec.h"
#import "OverlayItemZoomSpec.h"
#import "IPhoneFactory.h"
#import "SearchItemArray.h"
#import "SearchItem.h"
#import "OverlayItem.h"
#import "AppSession.h"
#import "ErrorHandler.h"

@implementation IPhoneOverlayInterface

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	// get core interface for map overlay
	_interface = APP_SESSION.mapLibAPI->getOverlayInterface();
	_linkedOverlayItems = [[NSMutableDictionary alloc] init];
	_layerTrack = 0;
	
	return self;
}

- (void)dealloc {
	[_linkedOverlayItems release];
	[super dealloc];
}

- (OverlayLayer *)newLayer {
	_layerTrack++;
	
	NSString *layerIdentifier = [NSString stringWithFormat:@"%d", _layerTrack];
	OverlayLayer *layer = [[[OverlayLayer alloc] initWithIdentifier:layerIdentifier] autorelease];
	
	return layer;
}

- (void)linkItem:(PlaceBase *)item withOverlayItem:(OverlayItem *)overlayItem {
	MapObjectInfo objectInfo = overlayItem->getMapObjectInfo();
	NSString *overlayKey = [NSString stringWithUTF8String:objectInfo.getIDString().c_str()];
	[_linkedOverlayItems setObject:item forKey:overlayKey];
}

- (id)objectForOverlayItem:(OverlayItem *)overlayItem {
	MapObjectInfo objectInfo = overlayItem->getMapObjectInfo();
	NSString *overlayKey = [NSString stringWithUTF8String:objectInfo.getIDString().c_str()];
	return [_linkedOverlayItems objectForKey:overlayKey];
}

- (void)showOverlayItemInfo:(OverlayItem *)overlayItem {	
	PlaceBase *item = [self objectForOverlayItem:overlayItem];
//	
//	OverlayItemDescriptionView *descriptionView = [[OverlayItemDescriptionView alloc] initWithOverlayObject:(id)object];	
//	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelegate.window addSubview:descriptionView];
//	[descriptionView release];

	[APP_SESSION.glView showDescriptionForItem:item withTarget:nil selector:nil];
}
@end
