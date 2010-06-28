/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchHistoryDataSource.h"
#import "Formatter.h"

@implementation SearchHistoryDataSource

@synthesize searchHistory;
@synthesize recentCountries;

- (id)init {
	if (self = [super init]) {
		self.searchHistory = [self readNSMutableArrayFromFileNamed:kSearchHistoryFilename];
		for (SearchDetail *det in self.searchHistory) {
			NSLog(@"SearchHistory loaded: %@, %@, %@, %@", det.term, det.category.name, det.location, det.country.name);
		}
		self.recentCountries = [self readNSMutableArrayFromFileNamed:kRecentCountriesFilename];
	}
	return self;
}

- (NSString *)getDocumentPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)writeNSArray:(NSArray *)array toFileNamed:(NSString *)filename {
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:array];
	[archiver finishEncoding];
	[data writeToFile:[[self getDocumentPath] stringByAppendingPathComponent:filename] atomically:YES];
	
	[archiver release];
	[data release];
}

- (NSMutableArray *)readNSMutableArrayFromFileNamed:(NSString *)filename {
	NSMutableArray *array;
	NSString *filePath = [[self getDocumentPath] stringByAppendingPathComponent:filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		array = [unarchiver decodeObject];
		[unarchiver finishDecoding];
		[unarchiver release];
		[data release];
	}
	else {
		array = [[[NSMutableArray alloc] init] autorelease];
	}
	return array;
}

- (void)addSearch:(SearchDetail *)searchDetail {
	SearchDetail *newDetail = [[SearchDetail alloc] init];
	newDetail.term = [[Formatter trimWhitespaces:searchDetail.term] lowercaseString];
	newDetail.category = searchDetail.category;
	newDetail.location = [[Formatter trimWhitespaces:searchDetail.location] capitalizedString];
	newDetail.country = searchDetail.country;
	if ([searchHistory containsObject:newDetail]) {
		[searchHistory removeObject:newDetail];
	}
	[searchHistory insertObject:newDetail atIndex:0];
	[newDetail release];
	if ([searchHistory count] > kMaxSearchTerms) {
		[searchHistory removeLastObject];
	}
	[self writeNSArray:searchHistory toFileNamed:kSearchHistoryFilename];

	if ([recentCountries containsObject:searchDetail.country]) {
		[recentCountries removeObject:searchDetail.country];
	}
	[recentCountries insertObject:searchDetail.country atIndex:0];
	if ([recentCountries count] > kMaxRecentCountries) {
		[recentCountries removeLastObject];
	}
	[self writeNSArray:recentCountries toFileNamed:kRecentCountriesFilename];
}	

- (void)dealloc {
	self.searchHistory = nil;
	self.recentCountries = nil;
	
	[super dealloc];
}

@end
