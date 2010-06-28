/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "NetworkTunnel.h"
#import "NetworkTunnelListener.h"
#import "AppSession.h"
#import "RegexKitLite.h"

#define kImageURLPath		@"ImageURLPath"
#define kImageLocalURLPath	@"ImageLocalURLPath"
#define kImageSRCLocation	@"ImageSRCLocation"

#define kImagesFolderName	@"TunnelImages"

NetworkTunnel *_networkTunnel;

@implementation NetworkTunnel

+ (NetworkTunnel *)sharedInstance {
	if (!_networkTunnel) {
		_networkTunnel = [[NetworkTunnel alloc] init];
	}
	return _networkTunnel;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	// initiate tunnel interface
	_tunnelInterface = &APP_SESSION.nav2API->getTunnelInterface(); 
	NetworkTunnelListener *networkListener = new NetworkTunnelListener;
	_tunnelInterface->addTunnelListener(networkListener);
	
	_requesters				= [[NSMutableDictionary alloc] init]; // registered requesters
	_requestsData			= [[NSMutableDictionary alloc] init]; // requests data
	_requestsURL			= [[NSMutableDictionary alloc] init]; // requests urls
	_modifiedRequestsData	= [[NSMutableDictionary alloc] init]; // requests copy data
	_imagesData				= [[NSMutableDictionary alloc] init]; // images data
	_downloadingImages		= [[NSMutableDictionary alloc] init]; // linker between requests and images
	
	// create folder to store images
	NSFileManager *fileManager = [NSFileManager defaultManager];
	_imagesDirectoryPath = [[[UIApplication getDocumentsPath] stringByAppendingPathComponent:kImagesFolderName] retain];
	
	// create directory for image storage
	BOOL isDirectory = NO;
	BOOL fileExists = [fileManager fileExistsAtPath:_imagesDirectoryPath isDirectory:&isDirectory];
		
	// if file exists delete
	if (fileExists) {
		NSError *error = nil;
		[fileManager removeItemAtPath:_imagesDirectoryPath error:&error];
		if (error) {
			NSLog(@"can not remove image directory with error: %@", [error localizedDescription]);
		}
	}
	
	if (!fileExists || (fileExists && !isDirectory)) {
		NSError *error = nil;
		[fileManager createDirectoryAtPath:_imagesDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error];
		
		if (error) {
			NSLog(@"images folder not created with error: %@", [error localizedDescription]);
		}
	}

	return self;
}

- (void)dealloc {
	[_imagesDirectoryPath release];
	[_modifiedRequestsData release];
	[_requestsData release];
	[_requestsURL release];
	[_requesters release];
	[_downloadingImages release];
	[super dealloc];
}

- (void)registerRequester:(id<NetworkTunnelRequester>)requester forURLData:(NSURL *)url firstCall:(BOOL)first{
	
	// start download
	WFAPI::AsynchronousStatus	requestStatus = [self startLoadingURL:url withType:RequestHTMLType firstCall:first];
	WFAPI::RequestID			requestID = requestStatus.getRequestID();
	
	// build request key
	NSString *requestKey = [NSString stringWithFormat:@"%d", requestID.getID()];
	
	// if request is valid register requester
	if (WFAPI::RequestID::INVALID_REQUEST_ID != requestID.getID()) {
		[_requesters setObject:requester forKey:requestKey];
		[_requestsURL setObject:url forKey:requestKey];
	}
}

- (void)retryRequest:(WFAPI::RequestID)requestID {
	NSString *requestKey = [NSString stringWithFormat:@"%d", requestID.getID()];
	
	// get requester for request key
	id<NetworkTunnelRequester>requester = [_requesters objectForKey:requestKey];
	NSURL *url = [_requestsURL objectForKey:requestKey];

	// register the requester again
	[self registerRequester:requester forURLData:url firstCall:YES];

	// remove old request
	[_requesters removeObjectForKey:requestKey];
	[_requestsURL removeObjectForKey:requestKey];
}

- (WFAPI::AsynchronousStatus)startLoadingURL:(NSURL *)url withType:(RequestType)requestType firstCall:(BOOL)first {
	
	// request url using the tunnel
	WFAPI::AsynchronousStatus requestStatus = _tunnelInterface->requestData([[url absoluteString] UTF8String], "", "9.0.1");	
	WFAPI::RequestID requestID = requestStatus.getRequestID();
	
	// build request key
	NSString *requestKey = [NSString stringWithFormat:@"%d", requestID.getID()];
	
	NSLog(@"Start RequestID : %@ with url: %@", requestKey, [url absoluteString]);
	
	// if request failed log the error
	if (WFAPI::RequestID::INVALID_REQUEST_ID == requestID.getID()) {
		NSLog(@"INVALID REQUEST ID received, status message is %@", [NSString stringWithUTF8String:requestStatus.getStatusMessage().c_str()]);
	} else {
	// else check the type of the request and set corresponding storage	
		if (RequestHTMLType == requestType) {
			[_requestsData setObject:[NSMutableData data] forKey:requestKey];
		} else if (RequestImageType == requestType) {
			[_imagesData setObject:[NSMutableData data] forKey:requestKey];
		}
	}
	
	return requestStatus;
}

- (RequestType)requestTypeForRequestKey:(NSString *)requestKey {
	
	RequestType type = RequestHTMLType;
	if ([[_imagesData allKeys] containsObject:requestKey]) {
		type = RequestImageType;
	} else if ([[_requestsData allKeys] containsObject:requestKey]) {
		type = RequestHTMLType;
	}
	return type;
}

- (NSString *)requestKeyForImageRequestKey:(NSString *)imageRequestKey {
	NSString *requestKey = nil;
	for (NSUInteger index = 0, count = [[_downloadingImages allKeys] count]; index < count; index++) {
		NSString *key = [[_downloadingImages allKeys] objectAtIndex:index];
		
		if ([[[_downloadingImages objectForKey:key] allKeys] containsObject:imageRequestKey]) {
			requestKey = key;
			break;
		}
	}
	return requestKey;
}

- (void)receivedData:(WFAPI::ReplyData *)data forRequestID:(WFAPI::RequestID)requestID {
	
	// build request key
	NSString *requestKey = [NSString stringWithFormat:@"%d",requestID.getID()];
	
	// get request type 
	RequestType type = [self requestTypeForRequestKey:requestKey];
	
	if (RequestImageType == type) {			// image request
		NSMutableData *imageData = [_imagesData objectForKey:requestKey];
		[imageData appendData:[NSData dataWithBytes:(const void *)data->getData() length:data->getSize()]];
		
		if ([imageData length] == data->getTotalDataSize()) {
			
			// get the parent request key
			NSString *key = [self requestKeyForImageRequestKey:requestKey];
			
			// get image information
			NSDictionary *imageInfo = [[_downloadingImages objectForKey:key] objectForKey:requestKey];
			
			NSString *imageURL = [imageInfo objectForKey:kImageURLPath];
			NSString *imageExtension = [imageURL pathExtension];
			NSString *imageName = [NSString stringWithFormat:@"%@.%@", requestKey, imageExtension];
			NSString *imagePath = [_imagesDirectoryPath stringByAppendingPathComponent:imageName];
			
			// local path where images should be stored
			NSRange location = NSRangeFromString([imageInfo objectForKey:kImageSRCLocation]);
			
			BOOL imageSaved = NO;
			
			NSData *defaultData = UIImagePNGRepresentation([UIImage imageWithData:imageData]);
			imageSaved = [[NSFileManager defaultManager] createFileAtPath:imagePath contents:defaultData attributes:nil];
			
			if (!imageSaved) {
				NSLog(@"Image for requestID %@ was saved at path :%@", requestKey, imagePath);
				
				// get content and modified content for html request
				NSString *content = [_requestsData objectForKey:key];
				NSString *modifiedContent = [_modifiedRequestsData objectForKey:key];
				
				// calculate the difference between contents
				NSInteger offset = [content length] - [modifiedContent length];
				
				// calculate new location based on the offset
				NSRange newLocation = NSMakeRange(location.location + offset, location.length);
				
				// replace image url with local path
				NSString *defPath = [NSString stringWithFormat:@"%@/wayfinder_logo.png", [[NSBundle mainBundle] resourcePath]];
				
				//UIImage *testImage = [UIImage imageWithContentsOfFile:defPath];

				modifiedContent = [modifiedContent stringByReplacingCharactersInRange:newLocation withString:defPath];

				[_modifiedRequestsData setObject:modifiedContent forKey:key];
				NSLog(@"Image for requestID %@ not saved we are using the default", requestKey);

			} else {
				NSLog(@"Image for requestID %@ was saved at path :%@", requestKey, imagePath);
				
				// get content and modified content for html request
				NSString *content = [_requestsData objectForKey:key];
				NSString *modifiedContent = [_modifiedRequestsData objectForKey:key];
				
				// calculate the difference between contents
				NSInteger offset = [content length] - [modifiedContent length];
				
				// calculate new location based on the offset
				NSRange newLocation = NSMakeRange(location.location + offset, location.length);
				
				//modifiedContent = [modifiedContent stringByReplacingCharactersInRange:newLocation withString:[fileURL absoluteString]];
				modifiedContent = [modifiedContent stringByReplacingCharactersInRange:newLocation withString:imagePath];
				[_modifiedRequestsData setObject:modifiedContent forKey:key];
				
			}

			// remove image link
			[[_downloadingImages objectForKey:key] removeObjectForKey:requestKey];
			
			if (0 == [[[_downloadingImages objectForKey:key] allKeys] count]) {
				NSString *modifiedContent = [_modifiedRequestsData objectForKey:key];
				NSLog(@"Download completed with images for request : %@ with data: %@", key, modifiedContent);
				id requester = [_requesters objectForKey:key];
				[requester requestFinishedWithData:modifiedContent];
			}
		}
	} else if (RequestHTMLType == type) {	// html request
		// append received data
		
		NSMutableData *requestData = [_requestsData objectForKey:requestKey];
		[requestData appendBytes:(const char *)data->getData() length:data->getSize()];

		[_requestsData setObject:requestData forKey:requestKey];
		
		// check if download finished
		if ([requestData length] == data->getTotalDataSize()) {
			NSLog(@"Download completed for request : %@ with data: %@", requestKey, requestData);
			
			// make a copy of the data - we will use this copy to replace the images url
			NSString *modifiedData = [[NSString alloc] initWithBytes:[requestData bytes] length:[requestData length] encoding:NSUTF8StringEncoding];
			
			[_modifiedRequestsData setObject:modifiedData forKey:requestKey];
			[_requestsData setObject:modifiedData forKey:requestKey];
			
			// if request is completed, check content for images and download them using the tunnel
			if (![self downloadImagesForRequest:requestID]) {
				id requester = [_requesters objectForKey:requestKey];
				[requester requestFinishedWithData:modifiedData];
			}
			[modifiedData release];
		} else {
			[_requestsData setObject:requestData forKey:requestKey];
		}
	}
}

- (void)requestCompleted:(WFAPI::RequestID)requestID {
	
}

- (BOOL)downloadImagesForRequest:(WFAPI::RequestID)requestID {
	
	NSString *requestKey = [NSString stringWithFormat:@"%d",requestID.getID()];
	NSString *requestContent = [_requestsData objectForKey:requestKey];
	NSString *imagesRegexp  = @"<img (.+?) />";
	
	// extract all images from the content request
	NSArray *images = [requestContent componentsMatchedByRegex:imagesRegexp];
	
	if (0 == [images count]) {
		return NO;
	}
	
	// initiate store images for this request
	[_downloadingImages setObject:[NSMutableDictionary dictionaryWithCapacity:[images count]] forKey:requestKey];
	
	for (NSUInteger index = 0, count = [images count];index < count; index++) {
		NSString *image = [images objectAtIndex:index];
		NSString *srcRegexp = @"(?<=src=[\"|\'])(.+?)(?=[\"|\'])";
		
		// get image url
		NSArray *src = [image componentsMatchedByRegex:srcRegexp];
		
		if ([src count] == 0) {
			NSLog(@"Image tag does not contain src attribute");
		} else {
			NSString *imageURL = [src objectAtIndex:0];
			
			// get location for this src in the main content
			NSRange location = [requestContent rangeOfString:imageURL];
			
			// use the right url
			NSURL *url = [NSURL URLWithString:imageURL];
			
			if (nil == [url scheme]) {
				NSURL *mainRequestURL = [_requestsURL objectForKey:requestKey];

				url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", [mainRequestURL scheme], [mainRequestURL host], [url path]]];
			}
			
			
			WFAPI::AsynchronousStatus	imageRequestStatus = [self startLoadingURL:url withType:RequestImageType firstCall:NO];
			WFAPI::RequestID			imageRequestID = imageRequestStatus.getRequestID();
			
			NSString *imageRequestKey = [NSString stringWithFormat:@"%d", imageRequestID.getID()];
			
			if (WFAPI::RequestID::INVALID_REQUEST_ID == requestID.getID()) {
				NSLog(@"INVALID REQUEST ID received when downloading image, status message is %@", [NSString stringWithUTF8String:imageRequestStatus.getStatusMessage().c_str()]);
			} else {
				
				NSMutableDictionary *requestImages = [_downloadingImages objectForKey:requestKey];
				
				// set image data
				NSMutableDictionary *imageData = [[NSMutableDictionary alloc] init];
				
				[imageData setObject:imageURL forKey:kImageURLPath];
				[imageData setObject:NSStringFromRange(location) forKey:kImageSRCLocation];
				[requestImages setObject:imageData forKey:imageRequestKey];
				[imageData release];
				
				[_downloadingImages setObject:requestImages forKey:requestKey];
			}
		}
	}
	return YES;
}

@end


