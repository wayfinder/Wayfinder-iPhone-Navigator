/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFGeocodingListener.h"


using namespace std;

WFGeocodingListener::WFGeocodingListener():
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneGeocodingListener(nil) {
}

WFGeocodingListener::WFGeocodingListener(id<IPhoneGeocodingListener> iPhoneGeocodingListener):	
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneGeocodingListener(iPhoneGeocodingListener) {	
}

WFGeocodingListener::~WFGeocodingListener() {
	
}

void WFGeocodingListener::reverseGeocodingReply(RequestID requestID, GeocodingInformation info) {
	if(m_iPhoneGeocodingListener != nil) {
		[m_iPhoneGeocodingListener reverseGeocodingReply:&info];
	}	
}


void WFGeocodingListener::error(const AsynchronousStatus& status) {
	if(m_iPhoneGeocodingListener != nil) {
		[m_iPhoneGeocodingListener errorWithStatus:(AsynchronousStatus *) &status];
	}	
	NSLog(@"WFGeocodingListener::error called with error code = %d (%s)", status.getStatusCode(), status.getStatusMessage().c_str());
}

void WFGeocodingListener::setIPhoneGeocodingListener(id<IPhoneGeocodingListener> iPhoneGeocodingListener) {
	setIPhoneGeocodingListener(RequestID::INVALID_REQUEST_ID, iPhoneGeocodingListener);
}

void WFGeocodingListener::setIPhoneGeocodingListener(RequestID requestID, id<IPhoneGeocodingListener> iPhoneGeocodingListener) {
	m_requestID = requestID.getID();
	m_iPhoneGeocodingListener = iPhoneGeocodingListener;
}

