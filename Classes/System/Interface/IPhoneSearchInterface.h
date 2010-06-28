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

#import "IPhoneBaseInterface.h"
#import "WFSearchListener.h"
#import "IPhoneSearchListener.h"
#import "SearchHandler.h"
#import "Search.h"
#import "Position.h"
#import "SearchResult.h"

#define kCategoryKey @"categories"

@interface IPhoneSearchInterface : IPhoneBaseInterface <IPhoneSearchListener> {
	WFSearchListener *searchListener;

	BOOL suppressHeaderNotifications;
}

@property (nonatomic, assign) BOOL suppressHeaderNotifications;

- (NSNumber *)searchWithQuery:(Search *)searchQuery;

- (NSNumber *)searchWithQuery:(Search *)searchQuery andSetSearchHandler:(id<SearchHandler>)searchHandler;

- (NSNumber *)getDetailsForResultWithID:(NSString *)resultID andSetSearchHandler:(id<SearchHandler>)searchHandler;

- (NSNumber *)getSearchCategoriesByPosition:(Position *)position andSetSearchHandler:(id<SearchHandler>)searchHandler;

- (void)getSearchCategories:(SearchCategoryArray &)searchCategoryArray;

- (NSArray *)searchCategories;

- (void)getTopRegions:(TopRegionArray &)topRegionArray;

// TODO: remove log methods...
- (void)logImageStatus:(SearchListener::ImageStatus)currentStatus;

- (void)logSearchHeading:(SearchHeading *)sh;

- (void)logSearchItem:(SearchItem *)item;

@end
