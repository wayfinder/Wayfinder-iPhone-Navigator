/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneImageInterface.h"
#import "ImageInterface.h"
#import "AppSession.h"
#import "ErrorHandler.h"

@implementation IPhoneImageInterface

- (id)init {
	if (self = [super init]) {	
		imageListener = new WFImageListener();
		ImageInterface &imageInterface = APP_SESSION.nav2API->getImageInterface();
		imageListener->setIPhoneImageListener(self);
		NSString *docsPath = [UIApplication getDocumentsPath];
		imageInterface.setImagePath([docsPath UTF8String]);
		imageInterface.addImageListener(imageListener);
	}
	return self;
}

- (void)dealloc {
	imageListener->setIPhoneImageListener(nil);
	delete imageListener;
	[super dealloc];
}

- (NSNumber *)getImageNamed:(NSString *)imageName {
	// not wrapped in new error handling - there is no handler that expects a reply for this, so if it doesn't succeed, we don't care...
	ImageInterface &imageInterface = APP_SESSION.nav2API->getImageInterface();
	// never get image as buffer - we always want to write it to a file
	return [NSNumber numberWithUnsignedInt:imageInterface.getImage(WFString([imageName cStringUsingEncoding:NSUTF8StringEncoding]), NO).getRequestID().getID()];
}

- (NSNumber *)getImageNamed:(NSString *)imageName andSetImageHandler:(id<ImageHandler>)imageHandler {
	InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(getImageNamed:andSetImageHandler:) andParameters:[NSArray arrayWithObjects:imageName, imageHandler, nil]];
	ImageInterface &imageInterface = APP_SESSION.nav2API->getImageInterface();
	// never get image as buffer - we always want to write it to a file
	RequestID reqID = imageInterface.getImage(WFString([imageName cStringUsingEncoding:NSUTF8StringEncoding]), NO).getRequestID();
	NSNumber *requestID = [NSNumber numberWithUnsignedInt:reqID.getID()];
	[self setRequestHandler:imageHandler andOutStandingRequest:req forRequestWithID:requestID];
	[req release];
	return requestID;
}

#pragma mark -
#pragma mark IPhoneImageListener Methods

- (void)imageReplyForRequest:(RequestID *)requestID imageNamed:(NSString *)imageName {
	NSNumber *num = [NSNumber numberWithUnsignedInt: requestID->getID()];
	id<ImageHandler> theHandler = [requestHandlers objectForKey:num];
	[theHandler imageReplyForImageNamed:imageName];
	[self removeRequestHandlerAndOutstandingRequestForRequestWithID:num];
}

- (void)imageReplyForRequest:(RequestID *)requestID imageNamed:(NSString *)imageName imageData:(ImageReplyData *)imageReplyData {
	NSNumber *num = [NSNumber numberWithUnsignedInt: requestID->getID()];
	id<ImageHandler> theHandler = [requestHandlers objectForKey:num];
	[theHandler imageReplyForImageNamed:imageName imageData:imageReplyData];	
	[self removeRequestHandlerAndOutstandingRequestForRequestWithID:num];
}

- (void)errorWithStatus:(AsynchronousStatus *)status {
	// ignore image interface specific errors
	if (START_IMAGE_STATUS_CODE >= status->getStatusCode() && START_NETWORK_STATUS_CODE < status->getStatusCode()) {
		// ignore
	}
	// let error handler deal with everything else
	else {
		[[ErrorHandler sharedInstance] handleErrorWithStatus:status onInterface:self];
	}
}

@end
