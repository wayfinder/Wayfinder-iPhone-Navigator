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
#import "AppSession.h"
#import "IPhoneBaseInterface.h"
#import "AsynchronousStatus.h"
#import "NetworkStatusHandler.h"

extern void Terminate(int code);

@interface ErrorHandler : NSObject <UIAlertViewDelegate, NetworkStatusHandler> {
	
@public
	
	BOOL displayErrorMessage;	
	BOOL startupProcessBegan;
	
@private 
	NSMutableDictionary *errorCodesForRequestOwners;
	NSMutableArray *dialogForErrorCodes;
	UIAlertView *internalAlertView;
	BOOL preserveInternalAlertView;
	BOOL shouldExit;
	id receiver;
	SEL selector;
}

@property (nonatomic, assign) BOOL displayErrorMessage;
@property (nonatomic, retain) NSMutableDictionary *errorCodesForRequestOwners;
@property (nonatomic, retain) NSMutableArray *dialogForErrorCodes;
@property (nonatomic, retain) UIAlertView *internalAlertView;
@property (nonatomic, assign) BOOL preserveInternalAlertView;
@property (nonatomic, assign) BOOL shouldExit;

+ (ErrorHandler *)sharedInstance;

- (BOOL)displayWarningForStatus:(AsynchronousStatus *)status receiverObject:(id)object;
- (BOOL)displayWarningForStatus:(AsynchronousStatus *)status receiverObject:(id)object withExit:(BOOL)exit;

- (void)handleErrorWithStatus:(AsynchronousStatus *)status;
- (void)handleErrorWithStatus:(AsynchronousStatus *)status onInterface:(IPhoneBaseInterface *)baseInterface;
- (void)notifyRequestCancelled;
- (void)showSpinnerWithTitle:(NSString *)title andTag:(NSInteger)tag allowCancel:(BOOL)allowCancel;
- (void)handleNetworkConnectionErrorWithExit:(BOOL)exit;

- (void)addInterface:(IPhoneBaseInterface *)baseInterface withRequestID:(NSNumber *)requestID toErrorCode:(NSNumber *)errorCode;
- (void)retryAndRemoveRequestsThatFailedWithErrorCode:(NSNumber *)errorCode;

@end
