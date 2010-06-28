/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchDetail.h"

@implementation SearchDetail

@synthesize term;
@synthesize category;
@synthesize location;
@synthesize country;

#pragma mark -
#pragma mark NSCoding Methods

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:term forKey:kSearchTermKey];
	[encoder encodeObject:category forKey:kSearchCategoryKey];
	[encoder encodeObject:location forKey:kSearchLocationKey];
	[encoder encodeObject:country forKey:kSearchCountryKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.term = [decoder decodeObjectForKey:kSearchTermKey];
		self.category = [decoder decodeObjectForKey:kSearchCategoryKey];
		self.location = [decoder decodeObjectForKey:kSearchLocationKey];
		self.country = [decoder decodeObjectForKey:kSearchCountryKey];
	}
	return self;
}

- (id)init {
	if (self = [super init]) {
		self.term = @"";
		self.category = ALL_CATEGORIES;
		self.location = @"";
		CountryDetail *cd = [[CountryDetail alloc] init];
		self.country = cd;
		[cd release];
	}
	return self;
}

#pragma mark -
- (BOOL)isEqual:(id)anObject {
	if ([anObject isMemberOfClass:SearchDetail.class]) {
		SearchDetail *other = (SearchDetail *)anObject;
		return [[self toString] isEqualToString:[other toString]];
	}
	return NO;
}

- (NSUInteger)hash {
	return [[self toString] hash];
}

- (NSString *)toString {
	return [NSString stringWithFormat:@"%@-%@-%@-%@", self.term, self.category.categoryID, self.location, self.country.countryID];
}

#pragma mark -

- (void)dealloc {
	self.term = nil;
	self.category = nil;
	self.location = nil;
	self.country = nil;
	
	[super dealloc];
}
@end
