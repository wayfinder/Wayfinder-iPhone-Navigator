/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchTermsDataSource.h"
#import "Formatter.h"

@implementation SearchTermsDataSource

@synthesize searchTerms;

- (id)init {
	if (self = [super init]) {
		NSString *filePath = [self searchTermsHistoryFilePath];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
			self.searchTerms = array;
			[array release];
		}
	}
	return self;
}

- (NSString *)searchTermsHistoryFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kSearchTermsHistoryFilename];
}

- (void)addSearchTerm:(NSString *)term {
	NSString *theTerm = [[Formatter trimWhitespaces:term] lowercaseString];
	if ([theTerm length] > 0) {
		if (searchTerms == nil) {
			NSMutableArray *array = [[NSMutableArray alloc] init];
			self.searchTerms = array;
			[array release];
		}
		if ([searchTerms containsObject:theTerm]) {
			[searchTerms removeObject:theTerm];
		}
		[searchTerms insertObject:theTerm atIndex:0];
		if ([searchTerms count] > kMaxSearchTerms) {
			[searchTerms removeLastObject];
		}
		[searchTerms writeToFile:[self searchTermsHistoryFilePath] atomically:YES];
	}	
}

- (void)dealloc {
	self.searchTerms = nil;
    [super dealloc];
}

@end
