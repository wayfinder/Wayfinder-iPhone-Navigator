/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WFNavigationInfoUpdateListener.h"
#import "NavigationInterface.h"
#import "IPNavSettingsManager.h"
#import "IPNavAudioPlayer.h"
#import "WFStringArray.h"
#import "AppSession.h"

using namespace std;

WFNavigationInfoUpdateListener::WFNavigationInfoUpdateListener():
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneNavigationInfoUpdateListener(nil) {
}

WFNavigationInfoUpdateListener::WFNavigationInfoUpdateListener(id<IPhoneNavigationInfoUpdateListener> iPhoneNavigationInfoUpdateListener):	
	m_requestID(RequestID::INVALID_REQUEST_ID),
	m_iPhoneNavigationInfoUpdateListener(iPhoneNavigationInfoUpdateListener) {	
}
		
WFNavigationInfoUpdateListener::~WFNavigationInfoUpdateListener() {

}

void WFNavigationInfoUpdateListener::distanceUpdate(const UpdateNavigationDistanceInfo &info) {
	if (m_iPhoneNavigationInfoUpdateListener != nil) {
		[m_iPhoneNavigationInfoUpdateListener distanceUpdate:(UpdateNavigationDistanceInfo *)&info];
	}	
}

void WFNavigationInfoUpdateListener::infoUpdate(const UpdateNavigationInfo &info) {
	if (m_iPhoneNavigationInfoUpdateListener != nil) {
		[m_iPhoneNavigationInfoUpdateListener infoUpdate:(UpdateNavigationInfo *)&info];
	}
}

void WFNavigationInfoUpdateListener::playSound() {

//	if (m_iPhoneNavigationInfoUpdateListener != nil) {
//		[m_iPhoneNavigationInfoUpdateListener playSound];
//	}
	if ([[IPNavSettingsManager sharedInstance] voicePromptsOn]) {
		[[IPNavAudioPlayer sharedInstance] play];
	}
	NavigationInterface &navigationInterface = APP_SESSION.nav2API->getNavigationInterface();
	navigationInterface.soundPlayed();
}

void WFNavigationInfoUpdateListener::prepareSound(const WFStringArray &soundNames) {	
	NSMutableArray *soundsSequence = [[NSMutableArray alloc] init];	
	for (WFStringArray::const_iterator arrayIterator = soundNames.begin(); arrayIterator < soundNames.end(); arrayIterator++ ) {
		WFString soundName = *arrayIterator;
		[soundsSequence addObject:[NSString stringWithUTF8String:soundName.c_str()]];
	}
	NavigationInterface &navigationInterface = APP_SESSION.nav2API->getNavigationInterface();
	if ([soundsSequence count] > 0) {
		[[IPNavAudioPlayer sharedInstance] prepareToPlayTheFollowingSequence:soundsSequence];
		navigationInterface.soundPrepared([[IPNavAudioPlayer sharedInstance] currentSoundDuration]);
	} else {
		navigationInterface.soundPrepared(100);
	}
	[soundsSequence release];
}

void WFNavigationInfoUpdateListener::error(const AsynchronousStatus& status) {
	if(m_iPhoneNavigationInfoUpdateListener != nil) {
		[m_iPhoneNavigationInfoUpdateListener errorWithStatus:(AsynchronousStatus *) &status];
	}
	NSLog(@"WFNavigationInfoUpdateListener::error called with error code = %d (%s)", status.getStatusCode(), status.getStatusMessage().c_str());
}

void WFNavigationInfoUpdateListener::setIPhoneNavigationInfoUpdateListener(id<IPhoneNavigationInfoUpdateListener> iPhoneNavigationInfoUpdateListener) {
	setIPhoneNavigationInfoUpdateListener(RequestID::INVALID_REQUEST_ID, iPhoneNavigationInfoUpdateListener);
}

void WFNavigationInfoUpdateListener::setIPhoneNavigationInfoUpdateListener(RequestID requestID, id<IPhoneNavigationInfoUpdateListener> iPhoneNavigationInfoUpdateListener) {
	m_requestID = requestID.getID();
	m_iPhoneNavigationInfoUpdateListener = iPhoneNavigationInfoUpdateListener;
}


