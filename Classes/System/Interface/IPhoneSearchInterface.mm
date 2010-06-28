/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPhoneSearchInterface.h"
#import "WFSearchListener.h"
#import "SearchInterface.h"
#import "SearchResult.h"
#import "SearchHandler.h"
#import "EAGLView.h"
#import "AppSession.h"
#import "SearchCategoryArray.h"
#import "SearchCategoryDetail.h"
#import "SearchStatusCode.h"
#import "ErrorHandler.h"

@implementation IPhoneSearchInterface

@synthesize suppressHeaderNotifications;

- (id)init {
	if (self = [super init]) {	
		searchListener = new WFSearchListener();
		SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
		searchListener->setIPhoneSearchListener(self);
		searchInterface.addSearchListener(searchListener);
		suppressHeaderNotifications = NO;
	}
	return self;
}

- (void)dealloc {
	searchListener->setIPhoneSearchListener(nil);
	delete searchListener;
	[super dealloc];
}

- (NSNumber *)searchWithQuery:(Search *)searchQuery {
	suppressHeaderNotifications = NO;
	SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
	return [NSNumber numberWithUnsignedInt:searchInterface.search([searchQuery asCoreSearchQuery]).getRequestID().getID()];
}

- (NSNumber *)searchWithQuery:(Search *)searchQuery andSetSearchHandler:(id<SearchHandler>)searchHandler {
	suppressHeaderNotifications = NO;
	InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(searchWithQuery:andSetSearchHandler:) andParameters:[NSArray arrayWithObjects:searchQuery, searchHandler, nil]];
	SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
	NSLog(@"what: %@", searchQuery.what);
	NSLog(@"category ID: %d", searchQuery.categoryID);
	NSLog(@"top region: %d", searchQuery.topRegionID);
	NSLog(@"where: %@", searchQuery.where);
	NSLog(@"heading: %d", searchQuery.headingID);
	NSLog(@"pos: %g, %g", searchQuery->position.latDeg, searchQuery->position.lonDeg);
	SearchQuery sq = [searchQuery asCoreSearchQuery];
	RequestID reqID = searchInterface.search(sq).getRequestID();
	[self setRequestHandler:searchHandler andOutStandingRequest:req forRequestWithID:[NSNumber numberWithUnsignedInt:reqID.getID()]];
	[req release];
	NSLog(@"Search query with ID: %d", reqID.getID());
	return [NSNumber numberWithUnsignedInt:reqID.getID()];
}

- (NSNumber *)getDetailsForResultWithID:(NSString *)resultID andSetSearchHandler:(id<SearchHandler>)searchHandler {
	InvocationRequest *req = [[InvocationRequest alloc] initWithReceiver:self andMethod:@selector(getDetailsForResultWithID:andSetSearchHandler:) andParameters:[NSArray arrayWithObjects:resultID, searchHandler, nil]];
	SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
	SearchIDArray idStrings = SearchIDArray();
	idStrings.push_back([resultID cStringUsingEncoding:NSUTF8StringEncoding]);
	RequestID reqID = searchInterface.searchDetails(idStrings).getRequestID();
	[self setRequestHandler:searchHandler andOutStandingRequest:req forRequestWithID:[NSNumber numberWithUnsignedInt:reqID.getID()]];
	[req release];
	return [NSNumber numberWithUnsignedInt:reqID.getID()];
}

- (void)getSearchCategories:(SearchCategoryArray &)searchCategoryArray {
	SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
	searchInterface.getSearchCategories(searchCategoryArray);
}

- (NSArray *)searchCategories {

	NSMutableArray *searchCategories = [NSMutableArray array];
	SearchCategoryArray categories;
	[APP_SESSION.searchInterface getSearchCategories:categories];
	
	for (SearchCategoryArray::iterator categoryItem = categories.begin(); categoryItem < categories.end(); categoryItem++) {
		SearchCategory category = *categoryItem;
		SearchCategoryDetail *searchCategory = [[SearchCategoryDetail alloc] initWithSearchCategory:&category];
		[searchCategories addObject:searchCategory];
		[searchCategory release];
	}
	
	return searchCategories;
}

- (NSNumber *)getSearchCategoriesByPosition:(Position *)position andSetSearchHandler:(id<SearchHandler>)searchHandler {
	SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
	RequestID reqID = searchInterface.getSearchCategoriesByPosition(position->coord).getRequestID();
	[self setRequestHandler:searchHandler forRequestWithID:[NSNumber numberWithUnsignedInt:reqID.getID()]];
	return [NSNumber numberWithUnsignedInt:reqID.getID()];
}

- (void)getTopRegions:(TopRegionArray &)topRegionArray {
	SearchInterface &searchInterface = APP_SESSION.nav2API->getSearchInterface();
	searchInterface.getTopRegions(topRegionArray);
}	

#pragma mark -
#pragma mark IPhoneSearchListener Methods
- (void)searchReplyForRequest:(RequestID* )requestID searchHeadings:(SearchHeadingArray *)searchHeadings isFinal:(BOOL)final {
	NSLog(@"Headings for search with requestID: %d", requestID->getID());
	if (suppressHeaderNotifications) {
		NSLog(@"Skipping reporting headings to handler...");
	}
	else {
		NSNumber *num = [NSNumber numberWithUnsignedInt:(unsigned int)requestID->getID()];
		id<SearchHandler> theHandler = [requestHandlers objectForKey:num];
		[theHandler searchHeadingsReply:searchHeadings isFinal:final];
	}
}

- (void)totalNbrOfHitsReplyForRequest:(RequestID *)requestID searchHeadings:(SearchHeadingArray *)searchHeadings {
	NSNumber *num = [NSNumber numberWithUnsignedInt:(unsigned int)requestID->getID()];
	id<SearchHandler> theHandler = [requestHandlers objectForKey:num];
	[theHandler searchHeadingsSummary:searchHeadings];
}

- (void)searchDetailsReplyForRequest:(RequestID *)requestID searchItems:(SearchItemArray *)searchItemArray {
	NSNumber *num = [NSNumber numberWithUnsignedInt:(unsigned int)requestID->getID()];
	id<SearchHandler> theHandler = [requestHandlers objectForKey:num];
	[theHandler searchDetailsReply:searchItemArray];
}

- (void)headingImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	NSLog(@"headingImagesStatusUpdatedWithStatus:");
	[self logImageStatus:currentStatus];
	for (NSNumber* num in requestHandlers) {
		id<SearchHandler> theHandler = [requestHandlers objectForKey:num];
		[theHandler headingImagesUpdatedWithStatus:currentStatus];
	}
}

- (void)categoryImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	NSLog(@"categoryImagesStatusUpdatedWithStatus:");
	[self logImageStatus:currentStatus];
	for (NSNumber* num in requestHandlers) {
		id<SearchHandler> theHandler = [requestHandlers objectForKey:num];
		[theHandler categoryImagesUpdatedWithStatus:currentStatus];
	}
}

- (void)resultImagesUpdatedWithStatus:(SearchListener::ImageStatus)currentStatus {
	NSLog(@"resultImagesStatusUpdatedWithStatus:");
	[self logImageStatus:currentStatus];
	for (NSNumber* num in requestHandlers) {
		id<SearchHandler> theHandler = [requestHandlers objectForKey:num];
		[theHandler resultImagesUpdatedWithStatus:currentStatus];
	}
}

- (void)searchCategoriesUpdated {
	id<SearchHandler> theHandler = [requestHandlers objectForKey:kCategoryKey];
	[theHandler searchCategoriesUpdated];
}

- (void)topRegionsChanged {
	NSLog(@"topRegionsChanged - nobody cares!");
}

- (void)nextSearchReplyForRequest:(RequestID *)requestID searchItems:(SearchItemArray *)searchItemArray heading:(wf_uint32)heading {
	NSLog(@"nextSearchReplyForRequest:");
}

- (void)extendedSearchReplyForRequest:(RequestID *)requestID searchItems:(SearchItemArray *)searchItemArray heading:(wf_uint32)heading {
	NSLog(@"extendedSearchReplyForRequest:");
}

- (void)errorWithStatus:(AsynchronousStatus *)status {
	RequestID reqID = status->getRequestID();
	wf_uint32 statusCode = status->getStatusCode();
	NSLog(@"Error for search with requestID: %d", reqID.getID());
	NSNumber *requestID = [NSNumber numberWithUnsignedInt: reqID.getID()];
	
	// search related error
	if (statusCode >= START_SEARCH_STATUS_CODE && statusCode < START_ROUTE_STATUS_CODE) {
		switch (statusCode) {
			// if we get this, treat is as "no results found"
			case UNABLE_TO_RECEIVE_AREA_MATCH_SEARCH_RESULTS: {
				[self searchReplyForRequest:&reqID searchHeadings:nil isFinal:YES];
			}
			break;

			// if we get these, we simply retry - it's gotta succeed eventually...
			case UNABLE_TO_INITIATE_SEARCH:
			case OUTSTANDING_SEARCH_REQUEST: {
				InvocationRequest *req = [self getInvocationRequestForRequestWithID:requestID];
				req.retries = 0;
				[self performSelector:@selector(retryRequestWithID) withObject:requestID afterDelay:5.0f];
			}
			break;
			// if we get these, we check for network availability (the first time), and then we retry up to three times, then notify handler
			case UNABLE_TO_REQUEST_NEXT_SEARCH_RESULTS:
			case UNABLE_TO_RECEIVE_MORE_SEARCH_RESULTS:
			case UNABLE_TO_RETRIEVE_SEARCH_DETAILS: {
				InvocationRequest *req = [self getInvocationRequestForRequestWithID:requestID];
				if (req.retries == 0) {
					[[ErrorHandler sharedInstance] handleErrorWithStatus:status onInterface:self];
				}
				else {
					if (![self retryRequestWithID:requestID]) {
						id<SearchHandler> theHandler = [requestHandlers objectForKey:requestID];
						[theHandler errorWithStatus:status];
						[self removeRequestHandlerAndOutstandingRequestForRequestWithID:requestID];
					}
				}
			}
			break;
			
			default: {
				if (![self retryRequestWithID:requestID]) {
					id<SearchHandler> theHandler = [requestHandlers objectForKey:requestID];
					[theHandler errorWithStatus:status];
					[self removeRequestHandlerAndOutstandingRequestForRequestWithID:requestID];
				}
			}
		}
	}
	// any other errors
	else {
		suppressHeaderNotifications = YES;
		[[ErrorHandler sharedInstance] handleErrorWithStatus:status onInterface:self];
	}
	
}

#pragma mark -
#pragma mark Debug Methods

- (void)logImageStatus:(SearchListener::ImageStatus)currentStatus {
	switch (currentStatus) {
		case SearchListener::CURRENT_IMAGES_OK:
			NSLog(@"- Current images OK!");
			break;
		case SearchListener::CURRENT_IMAGES_NOT_OK:
			NSLog(@"- Current images *NOT* OK!");
			break;
		case SearchListener::UPDATED_IMAGES_OK:
			NSLog(@"- Updated images OK!");
			break;
		default:
			NSLog(@"- Unknown image status: %d", currentStatus); 
	}
}

- (void)logSearchHeading:(SearchHeading *)sh {
	NSLog(@"- %@: %s (%d) [%s]", (WFAPI::SEARCH_RESULTS == sh->getTypeOfHits() ? @"Search results" : @"Area Matches"), (&sh->getName())->c_str(), sh->getTotalNbrHits(), (&sh->getImageName())->c_str());
	SearchItemArray sir = sh->getItemResults();
	SearchItemArray::iterator it;
	
	NSLog(@"Item results: %d", sir.size());
	for (it = sir.begin(); it < sir.end(); it++) {
		SearchItem item = *it;
		[self logSearchItem:&item];
	}
}

- (void)logSearchItem:(SearchItem *)item {
	NSLog(@"   - (%s)[%d-%d]  @ %s (%s) [%s]", (&item->getID())->c_str(), item->getType(), item->getSubType(), (&item->getLocationName())->c_str(), (item->getDistanceFromSearchPos(WFAPI::KM)).c_str(), (&item->getImageName())->c_str());
}

@end
