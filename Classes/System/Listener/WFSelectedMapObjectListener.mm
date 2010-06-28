/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFSelectedMapObjectListener.h"
#import "FontSpec.h"
#import "OverlayItemZoomSpec.h"
#import "OverlayItemVisualSpec.h"
#import "ImageSpec.h"
#import "IPhoneFactory.h"
#import "OverlayInterface.h"
#import "OverlayItem.h"
#import "MapOperationInterface.h"
#import "AppSession.h"

WFSelectedMapObjectListener::WFSelectedMapObjectListener() :
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneSelectedMapObjectListener(nil) {
}

void WFSelectedMapObjectListener::handleSelectedMapObject(const MapObjectInfo &mapObjectInfo, OverlayItem *overlayItem, const WGS84Coordinate &coord, bool longPress) {	
	// if an item on the map was selected
	if (overlayItem) {
		
		// put overlay item in the center of the map
		MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();
		operationInterface->setCenter(overlayItem->getPosition());
		
		// show description box for overlay item
		[APP_SESSION.overlayInterface showOverlayItemInfo:overlayItem];
		
	}
}

void WFSelectedMapObjectListener::handleStackedDialogOpened() {

}

void WFSelectedMapObjectListener::handleStackedDialogClosed() {

}

void WFSelectedMapObjectListener::setIPhoneSelectedMapObjectListener(id<IPhoneSelectedMapObjectListener> iPhoneSelectedMapObjectListener) {
	setIPhoneSelectedMapObjectListener(RequestID::INVALID_REQUEST_ID, iPhoneSelectedMapObjectListener);
}

void WFSelectedMapObjectListener::setIPhoneSelectedMapObjectListener(RequestID requestID, id<IPhoneSelectedMapObjectListener> iPhoneSelectedMapObjectListener) {
	m_requestID = requestID.getID();
	m_iPhoneSelectedMapObjectListener = iPhoneSelectedMapObjectListener;
}

