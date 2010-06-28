/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SearchCategoryDetail.h"
#import "LocalizationHandler.h"

SearchCategoryDetail *ALL_CATEGORIES;

@implementation SearchCategoryDetail

@synthesize categoryID;
@synthesize categoryIDAsInt;
@synthesize name;
@synthesize image;

- (id)initWithAllCategories {
	if (self = [super init]) {
		NSString *tmp = [[NSString alloc] initWithFormat:@"%d", WF_MAX_UINT32];
		self.categoryID = tmp;
		[tmp release];
		NSNumber *num = [[NSNumber alloc] initWithInt:WF_MAX_UINT32];
		self.categoryIDAsInt = num;
		[num release];
		// this is a temporary fix for the search page...
		self.name = [NSString stringWithFormat:@"- %@ -", [LocalizationHandler getString:@"[select_category]"]];
		//self.name = [LocalizationHandler getString:@"iPh_all_categ_txt"];
		self.image = @"";
	}
	return self;
}

- (id)initWithSearchCategory:(SearchCategory *)searchCategory {
	if (self = [super init]) {
		NSString *tmp = [[NSString alloc] initWithCString:searchCategory->getId().c_str()];
		self.categoryID = tmp;
		[tmp release];
		NSNumber *num = [[NSNumber alloc] initWithInt:searchCategory->getIntId()];
		self.categoryIDAsInt = num;
		[num release];
		tmp = [[NSString alloc] initWithCString:searchCategory->getName().c_str() encoding:NSUTF8StringEncoding];
		self.name = tmp;
		[tmp release];
		tmp = [[NSString alloc] initWithCString:searchCategory->getImageName().c_str()];
		self.image = tmp;
		[tmp release];
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding Methods

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:categoryID forKey:kCategoryIDKey];
	[encoder encodeObject:categoryIDAsInt forKey:kCategoryIDAsIntKey];
	[encoder encodeObject:name forKey:kNameKey];
	[encoder encodeObject:image forKey:kImageKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.categoryID = [decoder decodeObjectForKey:kCategoryIDKey];
		self.categoryIDAsInt = [decoder decodeObjectForKey:kCategoryIDAsIntKey];
		self.name = [decoder decodeObjectForKey:kNameKey];
		self.image = [decoder decodeObjectForKey:kImageKey];
	}
	return self;
}

#pragma mark -

- (void)dealloc {
	self.categoryID = nil;
	self.categoryIDAsInt = nil;
	self.name = nil;
	self.image = nil;
	
	[super dealloc];
}

@end
