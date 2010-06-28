/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFRouteListener.h"

using namespace std;

WFRouteListener::WFRouteListener() :
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneRouteListener(nil) {
}

WFRouteListener::WFRouteListener(id<IPhoneRouteListener> iPhoneRouteListener) :
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneRouteListener(iPhoneRouteListener) {	
}

WFRouteListener::~WFRouteListener() {
}

void WFRouteListener::routeReply(RequestID requestID) {		
	if (m_iPhoneRouteListener != nil) {
		[m_iPhoneRouteListener routeReply:&requestID];
	}	
}

void WFRouteListener::reachedEndOfRouteReply(RequestID requestID) {
	if (m_iPhoneRouteListener != nil) {
		[m_iPhoneRouteListener reachedEndOfRouteReply:&requestID];
	}
}

void WFRouteListener::error(const AsynchronousStatus& status) {
	if (m_iPhoneRouteListener != nil) {	
		[m_iPhoneRouteListener errorWithStatus:(AsynchronousStatus *) &status];
	}
	NSLog(@"WFRouteListener::error called with error code = %d (%s)", status.getStatusCode(), status.getStatusMessage().c_str());
}

void WFRouteListener::setIPhoneRouteListener(id<IPhoneRouteListener> iPhoneRouteListener) {
	setIPhoneRouteListener(RequestID::INVALID_REQUEST_ID, iPhoneRouteListener);
}

void WFRouteListener::setIPhoneRouteListener(RequestID requestID, id<IPhoneRouteListener> iPhoneRouteListener) {
	m_requestID = requestID.getID();
	m_iPhoneRouteListener = iPhoneRouteListener;
}
