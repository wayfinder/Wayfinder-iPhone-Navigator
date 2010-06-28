/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneFavouriteInterface.h"
#import "AppSession.h"
#import "ErrorHandler.h"
#import "FavouriteInterface.h"
#import "FavouriteHandler.h"
#import "FavouriteArray.h"
#import "FavouritePlace.h"
#import "InvocationRequest.h"

@implementation IPhoneFavouriteInterface

- (id)init {
	if (self = [super init]) {	
		favouriteListener = new WFFavouriteListener();
		FavouriteInterface &favouriteInterface = APP_SESSION.nav2API->getFavouriteInterface();
		favouriteListener->setIPhoneFavouriteListener(self);
		favouriteInterface.addFavouriteListener(favouriteListener);
	}
	return self;
}

- (void)dealloc {
	favouriteListener->setIPhoneFavouriteListener(nil);
	delete favouriteListener;
	[super dealloc];
}

- (void)addFavourite:(FavouritePlace *)favourite {
	FavouriteInterface &favouriteInterface = APP_SESSION.nav2API->getFavouriteInterface();
	favouriteInterface.addFavourite([favourite createFavourite]);
}

- (void)addCurrentPositionAsFavouriteNamed:(NSString *)name withDescription:(NSString *)description /*andItems:(NSArray*)placeInfoEntries*/ {
	FavouriteInterface &favouriteInterface = APP_SESSION.nav2API->getFavouriteInterface();
	WFString wfName = WFString([name cStringUsingEncoding:NSUTF8StringEncoding]);
	WFString wfDescription = WFString([description cStringUsingEncoding:NSUTF8StringEncoding]);
	ItemInfoArray iia;
	
	favouriteInterface.addCurrentPositionAsFavourite(wfName, wfDescription, iia);
}

/*
 * Retrying of delete can be done internally, as it is a synchronous invocation.
 */
- (void)deleteFavouriteWithID:(NSInteger)favID {
	NSUInteger retries = 0;
	BOOL success = NO;
	while (!success && retries < MAX_RETRIES) {
		FavouriteInterface &favouriteInterface = APP_SESSION.nav2API->getFavouriteInterface();
		SynchronousStatus status = favouriteInterface.deleteFavourite(favID);
		if (status.getStatusCode() == OK) {
			success = YES;
		}
		else {
			++retries;
			NSLog(@"Failed deleting favourite %d time(s)!", retries);
		}			
	}
}

/*
 * Retrieving favourites can be done internally, as it is a synchronous invocation.
 */
- (void)getFavouritesFromIndex:(NSInteger)startIndex amountToGet:(NSInteger)count totalCount:(NSUInteger *)totalFavouriteCount andPutThemHere:(NSMutableArray *)favouriteArray {
	NSUInteger retries = 0;
	BOOL success = NO;
	while (!success && retries < MAX_RETRIES) {
		FavouriteInterface &favouriteInterface = APP_SESSION.nav2API->getFavouriteInterface();
		FavouriteArray fa;
		wf_uint32 total = 0;
		SynchronousStatus status = favouriteInterface.getFavourites(startIndex, count, total, fa);
		if (status.getStatusCode() == OK) {
			FavouriteArray::iterator it;
			NSLog(@"*** %d favourites retrieved: ", total);
			for ( it=fa.begin() ; it < fa.end(); it++ ) {
				Favourite fav = *it;
				FavouritePlace *thePlace = [[FavouritePlace alloc] initWithFavourite:&fav];
				NSLog(@"%d -> %@", thePlace.placeID, thePlace.title);
				[favouriteArray addObject:thePlace];
				[thePlace release];
			}
			*totalFavouriteCount = total;
			success = YES;
		}
		else {
			++retries;
			NSLog(@"Failed getting favourites %d time(s)!", retries);
		}
	}
}

- (NSMutableArray *)getAllFavourites {
	NSUInteger totalCount;
	NSMutableArray *favourites = [[[NSMutableArray alloc] init] autorelease];
	[self getFavouritesFromIndex:0 amountToGet:WFAPI::WF_MAX_UINT16 totalCount:&totalCount andPutThemHere:favourites];
	return favourites;
}

- (NSNumber *)syncFavourites {
	return [self syncFavouritesAndSetFavouriteHandler:nil];
}

- (NSNumber *)syncFavouritesAndSetFavouriteHandler:(id<FavouriteHandler>)favouriteHandler {
	InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(syncFavourites) andParameters:[NSArray arrayWithObjects:nil]];
	FavouriteInterface &favouriteInterface = APP_SESSION.nav2API->getFavouriteInterface();
	RequestID reqID = favouriteInterface.syncFavourites().getRequestID();
	NSNumber *requestID = [NSNumber numberWithUnsignedInt:(unsigned int)reqID.getID()];
	[self setRequestHandler:favouriteHandler andOutStandingRequest:req forRequestWithID:requestID];
	[req release];
	return requestID;
}

#pragma mark -
#pragma mark IPhoneSearchListener Methods

- (void)errorWithStatus:(AsynchronousStatus *)status {
	NSNumber *requestID = [NSNumber numberWithUnsignedInt: status->getRequestID().getID()];
	
	// special case...
	if (status->getStatusCode() == GENERAL_ERROR) {
		// ignore: GENERAL_ERROR == already syncing favourites...
		NSLog(@"General error message: %s", status->getStatusMessage().c_str());
		NSLog(@"We expect that it is caused by simultaneous favourite sync requests detected -> ignoring...");
		[self removeRequestHandlerAndOutstandingRequestForRequestWithID:requestID];
	}
	// favourite related error
	else if (status->getStatusCode() >= START_FAVOURITE_STATUS_CODE && status->getStatusCode() < START_SEARCH_STATUS_CODE) {
		if (![self retryRequestWithID:requestID]) {
			id<FavouriteHandler> theHandler = [requestHandlers objectForKey:requestID];
			[theHandler errorWithStatus:status];
			[self removeRequestHandlerAndOutstandingRequestForRequestWithID:requestID];
		}
	}
	// any other errors
	else {
		[[ErrorHandler sharedInstance] handleErrorWithStatus:status onInterface:self];
	}
}

- (void)favouritesChanged {
	for (id<FavouriteHandler> theHandler in [requestHandlers allValues]) {
		[theHandler favouritesChanged];
	}
}

- (void)favouritesSyncedWithRequest:(RequestID *)requestID {
	// regardless of request ID, tell all handlers, that the favourites have synced
	for (id<FavouriteHandler> theHandler in [requestHandlers allValues]) {
		[theHandler favouritesSynced];
	}
	NSNumber *num = [NSNumber numberWithUnsignedInt: requestID->getID()];
	[self removeRequestHandlerAndOutstandingRequestForRequestWithID:num];
}

#pragma mark -
#pragma mark Debug Methods

@end
