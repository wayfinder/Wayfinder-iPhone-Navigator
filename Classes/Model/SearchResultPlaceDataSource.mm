/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchResultPlaceDataSource.h"
#import "AppSession.h"
#import "WFNavigationAppDelegate.h"
#import "LocalizationHandler.h"
#import "SearchResult.h"
#import "ErrorHandler.h"
#import "SearchViewController.h"

@implementation SearchResultPlaceDataSource

- (id)init {
	if (self = [super initWithEmptyTitle:[LocalizationHandler getString:@"iPh_no_results_txt"]
							emptyMessage:[LocalizationHandler getString:@"wid_no_result_found_txt"]]) {
	}
	return self;
}

- (NSString *)dataSourceType {
	return [LocalizationHandler getString:@"iPh_search_results_txt"];
}

- (void)refreshData {

	[super refreshData];
}

- (void)dealloc {
	
	[super dealloc];
}

#pragma mark -
#pragma mark SearchHandler Methods

- (void)searchHeadingsSummary:(SearchHeadingArray *)searchHeadingArray {
	NSLog(@"searchHeadingsSummary: %d", searchHeadingArray->size());
}

- (void)searchHeadingsReply:(SearchHeadingArray *)searchHeadings isFinal:(BOOL)final {
	NSLog(@"searchReplyForRequest: - %@final!", (final ? @"" : @"not "));
	
	SearchHeadingArray *shr = searchHeadings;
	if (shr != nil) {
		SearchHeadingArray::iterator it;
		for ( it=shr->begin() ; it < shr->end(); it++ ) {
			SearchHeading sh = *it;
			[self processSearchHeading:&sh];
		}
	}
	if (final) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		[self fetchingCompleted];
		if ([self.places count] == 0) {
			[self noPlacesAvailable];
		}
	}	
}

- (void)processSearchHeading:(SearchHeading *)sh {
	NSLog(@"- %@: %s (%d) [%s]", (WFAPI::SEARCH_RESULTS == sh->getTypeOfHits() ? @"Search results" : @"Area Matches"), (&sh->getName())->c_str(), sh->getTotalNbrHits(), (&sh->getImageName())->c_str());
	SearchItemArray sir = sh->getItemResults();
	SearchItemArray::iterator it;
	
	NSLog(@"Item results: %d", sir.size());
	for (it = sir.begin(); it < sir.end(); it++) {
		SearchItem item = *it;
		[self logSearchItem:&item];
		if (item.getPosition().isValid()) {
			bool found = false;
			for (SearchResult *result in self.places) {
				NSString *idString = [[NSString alloc] initWithCString:item.getID().c_str()];
				if ([result.resultID caseInsensitiveCompare:idString] == NSOrderedSame) {
					found = true;
				}
				[idString release];
			}
			if (!found) {
				SearchResult *result = [[SearchResult alloc] initWithSearchItem:&item];
				[self.places addObject:result];
				[result release];
			}
		}
	}
	[self refreshData];
}

- (void)headingImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self refreshData];
	}
}

- (void)categoryImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self refreshData];
	}
}	

- (void)resultImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	if (currentStatus == SearchListener::UPDATED_IMAGES_OK) {
		[self refreshData];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate.navController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Debug Methods

- (void)logSearchItem:(SearchItem *)item {
	NSLog(@"   - (%d)[%d-%d] %s @ %s (%s) [%s]", item->getDistance(), item->getType(), item->getSubType(), (&item->getName())->c_str(), (&item->getLocationName())->c_str(), (item->getDistance(WFAPI::KM)).c_str(), "");//(&item->getImageName())->c_str());
}

- (void)errorWithStatus:(AsynchronousStatus *)status {
	if (status->getStatusCode() == GENERAL_SERVER_ERROR) {
		// ignore - we get this when there are invalid input characters, but we don't care...
		// we will still get responds for search results (which will likely be empty)
	}
	else {
		// any other error... treat it like no results (for now)
		[self noPlacesAvailable];
	}
}

- (void)requestCancelled:(NSNumber *)requestID {
	NSLog(@"Request cancelled - anything we can do here?");
	for (id<PlaceDataChangeListener> listener in listeners) {
		[listener placeFetchingCancelled];
	}
}

@end
