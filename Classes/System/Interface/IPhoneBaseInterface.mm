/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneBaseInterface.h"
#import "BaseHandler.h"
#import "InvocationRequest.h"

#define MAX_RETRIES 3

@implementation IPhoneBaseInterface

- (id)init {
	if (self = [super init]) {	
		requestHandlers = [[NSMutableDictionary alloc] init];
		outstandingRequests = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[requestHandlers release];
	[outstandingRequests release];
	[super dealloc];
}

/*
 * Here we retrieve the invocation request for the given ID, fire it as a new request, and replace the old request ID with the new noe, so the proper handler is invoked, when it completes.
 */
- (BOOL)retryRequestWithID:(NSNumber *)requestID {
	BOOL didRetry = NO;
	InvocationRequest *req = [outstandingRequests objectForKey:requestID];
	id theHandler = [requestHandlers objectForKey:requestID];
	if (req != nil && req.retries < MAX_RETRIES) {
		NSNumber *newRequestID = [req retry];
		if (theHandler != nil) {
			[requestHandlers setObject:theHandler forKey:newRequestID];
			[requestHandlers removeObjectForKey:requestID];
		}
		[outstandingRequests setObject:req forKey:newRequestID];
		[outstandingRequests removeObjectForKey:requestID];
		didRetry = YES;
	}
	return didRetry;
}

- (void)cancelRequestWithID:(NSNumber *)requestID {
	id<BaseHandler> theHandler = [requestHandlers objectForKey:requestID];
	[theHandler requestCancelled:requestID];
	[self removeRequestHandlerAndOutstandingRequestForRequestWithID:requestID];
}

- (void)setRequestHandler:(id<BaseHandler>)requestHandler andOutStandingRequest:(InvocationRequest *)invocationRequest forRequestWithID:(NSNumber *)requestID {
	if (requestHandler != nil) {
		[self setRequestHandler:requestHandler forRequestWithID:requestID];
	}
	[outstandingRequests setObject:invocationRequest forKey:requestID];
}

- (void)setRequestHandler:(id<BaseHandler>)requestHandler forRequestWithID:(NSNumber *)requestID {
	[requestHandlers setObject:requestHandler forKey:requestID];
}

- (void)removeRequestHandlerAndOutstandingRequestForRequestWithID:(NSNumber *)requestID {
	[requestHandlers removeObjectForKey:requestID];
	[outstandingRequests removeObjectForKey:requestID];
}

- (void)removeRequestHandler:(id<BaseHandler>)requestHandler {
	[requestHandlers removeObjectsForKeys:[requestHandlers allKeysForObject:requestHandler]];
}

- (InvocationRequest *)getInvocationRequestForRequestWithID:(NSNumber *)requestID {
	return [outstandingRequests objectForKey:requestID];
}

@end
