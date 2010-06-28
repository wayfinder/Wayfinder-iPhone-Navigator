/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "FavouritePlaceDataSource.h"
#import "AppSession.h"
#import "ErrorHandler.h"
#import "LocalizationHandler.h"

@implementation FavouritePlaceDataSource

- (id)init {
	if (self = [super initWithEmptyTitle:[LocalizationHandler getString:@"[no_favourites_title]"]
							emptyMessage:[LocalizationHandler getString:@"[no_favourites_message]"]]) {
		waitingForFavouriteSync = NO;
	}
	return self;
}

- (NSString *)dataSourceType {
	return [LocalizationHandler getString:@"iPh_my_places_tk"];
}

- (void)viewReadyForData {
	waitingForFavouriteSync = YES;
	[APP_SESSION.favouriteInterface syncFavouritesAndSetFavouriteHandler:self];
	[self refreshData];
}

- (void)refreshData {
	[super refreshData];
	if (!waitingForFavouriteSync) {
		[self fetchingCompleted];
		if ([self.places count] == 0) {
			NSLog(@"Not waiting for sync and no places available!");
			[self noPlacesAvailable];
		}
	}
}

- (void)dealloc {
	
	[super dealloc];
}

#pragma mark -
#pragma mark FavouriteHandler Methods

- (void)favouritesChanged {
	NSLog(@"Favourites changed...");
	self.places = [APP_SESSION.favouriteInterface getAllFavourites];
	[self refreshData];
}

- (void)favouritesSynced {
	NSLog(@"Favourites synced...");
	self.places = [APP_SESSION.favouriteInterface getAllFavourites];
	waitingForFavouriteSync = NO;
	[self refreshData];
}

- (void)errorWithStatus:(AsynchronousStatus *)status{
	for (id<PlaceDataChangeListener> listener in listeners) {
		[listener coreErrorWithStatus:status];
	}
}

- (void)requestCancelled:(NSNumber *)requestID {
	NSLog(@"Request cancelled - anything we can do here?");
	for (id<PlaceDataChangeListener> listener in listeners) {
		[listener placeFetchingCancelled];
	}
}


@end
