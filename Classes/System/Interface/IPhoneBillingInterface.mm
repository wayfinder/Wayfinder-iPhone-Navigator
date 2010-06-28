/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneBillingInterface.h"

#import "BillingInterface.h"
#import "AppSession.h"
#import "ErrorHandler.h"

@implementation IPhoneBillingInterface

- (id)init {
	if (self = [super init]) {	
		billingListener = new WFBillingListener(self);
		
		BillingInterface &billingInterface = APP_SESSION.nav2API->getBillingInterface();
		billingInterface.addBillingListener(billingListener);		
		
	}
	return self;
}

- (void)verifyThirdPartyTransactionWithId:(NSString *)transactionID andSelectionString:(NSString *)selectionString {

	WFString transId = WFString([transactionID cStringUsingEncoding:NSUTF8StringEncoding]);
	WFString selectStr = WFString([selectionString cStringUsingEncoding:NSUTF8StringEncoding]);	
	
	BillingInterface &billingInterface = APP_SESSION.nav2API->getBillingInterface();	
	billingInterface.verifyThirdPartyTransaction(transId, selectStr);
}

#pragma mark -
#pragma mark IPhoneBillingListener Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	[[ErrorHandler sharedInstance] displayWarningForStatus:status receiverObject:self];
}

#pragma mark -
#pragma mark IPhoneBillingListener Methods

- (void)thirdPartyTransactionVerified:(RequestID *)requestID withSuccess:(BOOL)success {
	
	if(success) {
		// TODO: Now we try to route again
	}
	else {
		// TODO: Remove routeOverView (go back)
	}
}

@end
