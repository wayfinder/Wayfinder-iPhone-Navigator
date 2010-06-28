/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneNetworkInterface.h"
#import "NetworkInterface.h"
#import "NetworkStatusCode.h"
#import "AppSession.h"
#import "ErrorHandler.h"
//#import "BillingViewController.h"
#import "WFNavigationAppDelegate.h"

@implementation IPhoneNetworkInterface

@synthesize isConnected;
@synthesize hasEverBeenConnected;
@synthesize networkStatusHandlers;
@synthesize requestIDs;

- (id)init {
	if (self = [super init]) {	
		networkListener = new WFNetworkListener();
		NetworkInterface &networkInterface = APP_SESSION.nav2API->getNetworkInterface();
		networkListener->setIPhoneNetworkListener(self);
		networkInterface.addNetworkListener(networkListener);
		NSMutableSet *nsh = [[NSMutableSet alloc] init];
		self.networkStatusHandlers = nsh;
		[nsh release];
		NSMutableSet *rqids = [[NSMutableSet alloc] init];
		self.requestIDs = rqids;
		[rqids release];
		isConnected = NO;
		hasEverBeenConnected = NO;
		attempts = 0;
	}
	return self;
}

- (void)dealloc {
	networkListener->setIPhoneNetworkListener(nil);
	delete networkListener;
	self.networkStatusHandlers = nil;
	self.requestIDs = nil;
	[super dealloc];
}

- (void)testServerConnection {
	NSLog(@"Testing server connection... (retry number: %d)", attempts);
	NetworkInterface &networkInterface = APP_SESSION.nav2API->getNetworkInterface();
	AsynchronousStatus status = networkInterface.testServerConnection();
	NSNumber *reqID = [NSNumber numberWithUnsignedInt:status.getRequestID().getID()];
	// add the request ID, so we have a chance in hell to figure out whether errorWithStatus is invoked because *we* failed or because *core* failed.
	[self.requestIDs addObject:reqID];
}

- (void)addNetworkStatusHandler:(id<NetworkStatusHandler>)networkStatusHandler {
	if (![networkStatusHandlers containsObject:networkStatusHandler]) {
		[networkStatusHandlers addObject:networkStatusHandler];
	}
}

- (void)removeNetworkStatusHandler:(id<NetworkStatusHandler>)networkStatusHandler {
	[networkStatusHandlers removeObject:networkStatusHandler];
}

- (void)notifyNetworkStatusHandlers {
	for (id<NetworkStatusHandler> networkStatusHandler in networkStatusHandlers) {
		[networkStatusHandler connectionStatusConnected:isConnected hasEverBeenConnected:hasEverBeenConnected];
	}
}

#pragma mark -
#pragma mark IPhoneNetworkListener Methods

- (void)testServerConnectionReplyForRequest:(RequestID *)requestID {
	NSNumber *reqID = [NSNumber numberWithUnsignedInt:requestID->getID()];
	// remove outstanding request id from list
	[self.requestIDs removeObject:reqID];
	hasEverBeenConnected = YES;
	isConnected = YES;
	attempts = 0;
	[self notifyNetworkStatusHandlers];
}

- (void)errorWithStatus:(AsynchronousStatus *)status {
	NSNumber *reqID = [NSNumber numberWithUnsignedInt:status->getRequestID().getID()];

	NSLog(@"Error on request: %d", [reqID unsignedIntValue]);
	// this ensures, that we only handle network errors, that is caused by ourselves (testServerConnection)
	if ([self.requestIDs containsObject:reqID]) {
		// remove outstanding request id from list
		[self.requestIDs removeObject:reqID];

		// network error - handle it
		if (status->getStatusCode() >= START_NETWORK_STATUS_CODE && status->getStatusCode() < START_TUNNEL_INTERFACE_STATUS_CODE) {
			isConnected = NO;
			++attempts;
			// if we get a network time out error OR other network errors up up 3 times...
			if (status->getStatusCode() == NETWORK_TIMEOUT_ERROR || attempts >= MAX_RETRIES) {
				attempts = 0;
				[self notifyNetworkStatusHandlers];
			}
			else {
				[self performSelector:@selector(testServerConnection) withObject:self afterDelay:0.5f];
			}
		}
		// let the error handler deal with it...
		else {
			attempts = 0;
			[[ErrorHandler sharedInstance] handleErrorWithStatus:status];
		}
	}
}

@end
