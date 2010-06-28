/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PlaceDataSource.h"

@implementation PlaceDataSource

@synthesize places;
@synthesize listeners;

@synthesize emptyListTitle;
@synthesize emptyListMessage;

- (id)initWithEmptyTitle:(NSString *)title emptyMessage:(NSString *)message {
	if (self = [super init]) {
		emptyNotificationSent = NO;
		fetchingCompletedSent = NO;
		NSMutableArray *arr = [[NSMutableArray alloc] init];
		self.places = arr;
		[arr release];
		arr = [[NSMutableArray alloc] init];
		self.listeners = arr;
		[arr release];
		self.emptyListTitle = title;
		self.emptyListMessage = message;
	}
	return self;
}

- (void)noPlacesAvailable {
	if (!emptyNotificationSent) {
		emptyNotificationSent = YES;
		for (id<PlaceDataChangeListener> listener in listeners) {
			[listener noPlacesAvailableTitle:emptyListTitle message:emptyListMessage];
		}
	}
}

- (void)fetchingCompleted {
	fetchingCompletedSent = YES;
	for (id<PlaceDataChangeListener> listener in listeners) {
		[listener placeFetchingCompleted];
	}
}

- (NSString *)dataSourceType {
	// implement something useful when subclassing
	return @"[undefined]";
}

- (void)viewReadyForData {
	[self refreshData];
	if (fetchingCompletedSent) {
		[self fetchingCompleted];
	}
}

- (void)refreshData {
	// implement something useful when subclassing, then call this ([super refreshData]) to notify listeners...
	// NOTICE: call this *AFTER* doing whatever the subclass does in refreshData - *NOT* before
	for (id<PlaceDataChangeListener> listener in listeners) {
		[listener dataRefreshed:places];
	}
}

- (void)addDataChangeListener:(id<PlaceDataChangeListener>) placeDataChangeListener {
	if (![listeners containsObject:placeDataChangeListener]) {
		[listeners addObject:placeDataChangeListener];
	}
}

- (void)removeDataChangeListener:(id<PlaceDataChangeListener>) placeDataChangeListener {
		if ([listeners containsObject:placeDataChangeListener]) {
			[listeners removeObject:placeDataChangeListener];
		}
	}

- (void)dealloc {
	self.places = nil;
	self.listeners = nil;
	
	self.emptyListTitle = nil;
	self.emptyListMessage = nil;
	
	[super dealloc];
}

@end
