/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFFavouriteListener.h"

using namespace std;

void WFFavouriteListener::setIPhoneFavouriteListener(id<IPhoneFavouriteListener> iPhoneFavouriteListener) {
	setIPhoneFavouriteListener(RequestID::INVALID_REQUEST_ID, iPhoneFavouriteListener);
}
void WFFavouriteListener::setIPhoneFavouriteListener(RequestID requestID, id<IPhoneFavouriteListener> iPhoneFavouriteListener) {
	m_requestID = requestID.getID();
	if (m_iPhoneFavouriteListener != nil) {
		//		[m_iPhoneSearchListener release];
	}
	m_iPhoneFavouriteListener = iPhoneFavouriteListener;
	//	[m_iPhoneSearchListener retain];
}

WFFavouriteListener::WFFavouriteListener() :
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneFavouriteListener(nil) {
}

WFFavouriteListener::WFFavouriteListener(id<IPhoneFavouriteListener> iPhoneFavouriteListener) :
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneFavouriteListener(iPhoneFavouriteListener) {
}

WFFavouriteListener::~WFFavouriteListener() {
	if (m_iPhoneFavouriteListener != nil) {
		//		[m_iPhoneSearchListener release];
	}
}

void WFFavouriteListener::favouritesChanged() {
	[m_iPhoneFavouriteListener favouritesChanged];
}

void WFFavouriteListener::favouritesSynced(RequestID requestID) {
	[m_iPhoneFavouriteListener favouritesSyncedWithRequest:&requestID];
}

void WFFavouriteListener::error(const AsynchronousStatus& status) {
	if(m_iPhoneFavouriteListener != nil) {
		[m_iPhoneFavouriteListener errorWithStatus:(AsynchronousStatus *) &status];
	}
	NSLog(@"WFFavouriteListener::error called with error code = %d (%s)", status.getStatusCode(), status.getStatusMessage().c_str());
}
