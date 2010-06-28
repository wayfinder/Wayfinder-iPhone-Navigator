/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFSearchListener.h"
#import "Nav2API.h"
#import "EAGLView.h"
#import "SearchInterface.h"

using namespace std;

void WFSearchListener::setIPhoneSearchListener(id<IPhoneSearchListener> iPhoneSearchListener) {
	setIPhoneSearchListener(RequestID::INVALID_REQUEST_ID, iPhoneSearchListener);
}
void WFSearchListener::setIPhoneSearchListener(RequestID requestID, id<IPhoneSearchListener> iPhoneSearchListener) {
	m_requestID = requestID.getID();
	if (m_iPhoneSearchListener != nil) {
//		[m_iPhoneSearchListener release];
	}
	m_iPhoneSearchListener = iPhoneSearchListener;
//	[m_iPhoneSearchListener retain];
}

WFSearchListener::WFSearchListener() :
		m_requestID(RequestID::INVALID_REQUEST_ID),
		m_iPhoneSearchListener(nil) {
}

WFSearchListener::WFSearchListener(id<IPhoneSearchListener> iPhoneSearchListener) :
		m_requestID(RequestID::INVALID_REQUEST_ID),
		m_iPhoneSearchListener(iPhoneSearchListener) {
}

WFSearchListener::~WFSearchListener() {
	if (m_iPhoneSearchListener != nil) {
//		[m_iPhoneSearchListener release];
	}
}

void WFSearchListener::searchDetailsReply(RequestID requestID, const SearchItemArray& searchItemArray) {	
	[m_iPhoneSearchListener searchDetailsReplyForRequest:&requestID searchItems:(SearchItemArray*) &searchItemArray];
}

void WFSearchListener::searchReply(RequestID requestID, const SearchHeadingArray& searchHeadings, bool final) {
	SearchHeadingArray* sh = (SearchHeadingArray*) &searchHeadings;
	[m_iPhoneSearchListener searchReplyForRequest:&requestID searchHeadings:sh isFinal:final];
}

void WFSearchListener::searchCategoriesUpdated() {
	[m_iPhoneSearchListener searchCategoriesUpdated];
}

void WFSearchListener::nextSearchReply(RequestID requestID, const SearchItemArray& searchItemArray, wf_uint32 heading) {
	[m_iPhoneSearchListener nextSearchReplyForRequest:&requestID searchItems:(SearchItemArray*) &searchItemArray heading:heading];
}

void WFSearchListener::extendedSearchReply(RequestID requestID, const SearchItemArray& searchItemArray, wf_uint32 heading) {
	[m_iPhoneSearchListener extendedSearchReplyForRequest:&requestID searchItems:(SearchItemArray*) &searchItemArray heading:heading];
}

void WFSearchListener::topRegionsChanged() {
	[m_iPhoneSearchListener topRegionsChanged];
}

void WFSearchListener::totalNbrOfHitsReply(RequestID requestID, SearchHeadingArray searchHeadingArray) {
	[m_iPhoneSearchListener totalNbrOfHitsReplyForRequest:&requestID searchHeadings:(SearchHeadingArray*) &searchHeadingArray];
}

void WFSearchListener::headingImagesStatusUpdated(ImageStatus currentStatus) {
	[m_iPhoneSearchListener headingImagesUpdatedWithStatus:currentStatus];
}

void WFSearchListener::categoryImagesStatusUpdated(ImageStatus currentStatus) {
	[m_iPhoneSearchListener categoryImagesUpdatedWithStatus:currentStatus];
}

void WFSearchListener::resultImagesStatusUpdated(ImageStatus currentStatus) {
	[m_iPhoneSearchListener resultImagesUpdatedWithStatus:currentStatus];
}

void WFSearchListener::error(const AsynchronousStatus& status) {
	[m_iPhoneSearchListener errorWithStatus:(AsynchronousStatus *) &status];
	NSLog(@"WFSearchListener::error called with error code = %d (%s)", status.getStatusCode(), status.getStatusMessage().c_str());	
}
