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
#import "TunnelInterface.h"
#import "NetworkTunnelRequester.h"
#import "ReplyData.h"
#import "RequestID.h"

typedef enum RequestType {
	RequestHTMLType = 0,
	RequestImageType
} RequestType;


@interface NetworkTunnel : NSObject {
	WFAPI::TunnelInterface *_tunnelInterface;

	NSString *_imagesDirectoryPath;
	
	NSMutableDictionary *_requesters;
	NSMutableDictionary *_requestsData;
	NSMutableDictionary *_requestsURL;
	NSMutableDictionary *_modifiedRequestsData;	// data that contains the local images paths
	NSMutableDictionary *_imagesData;
	NSMutableDictionary *_downloadingImages;
}

// use this method to get the instance for NetworkTunnel
+ (NetworkTunnel *)sharedInstance;

- (void)registerRequester:(id<NetworkTunnelRequester>)requester forURLData:(NSURL *)url firstCall:(BOOL)first;
- (void)retryRequest:(WFAPI::RequestID)requestID;
- (WFAPI::AsynchronousStatus)startLoadingURL:(NSURL *)url withType:(RequestType)requestType firstCall:(BOOL)first;
- (RequestType)requestTypeForRequestKey:(NSString *)requestKey;
- (NSString *)requestKeyForImageRequestKey:(NSString *)imageRequestKey;
- (void)receivedData:(WFAPI::ReplyData *)data forRequestID:(WFAPI::RequestID)requestID;
- (void)requestCompleted:(WFAPI::RequestID)requestID;
- (BOOL)downloadImagesForRequest:(WFAPI::RequestID)requestID;

@end
