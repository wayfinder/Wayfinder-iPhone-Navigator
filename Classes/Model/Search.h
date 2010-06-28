#import <Foundation/Foundation.h>

#import "SearchQuery.h"

using namespace WFAPI;

@interface Search : NSObject {

@public	
	/// ID of a SearchArea, the search will be done in this area.
	NSString *areaID;
	
	/**
	 * In what region/country/state the search will be done.
	 */
	NSUInteger topRegionID;
	
	/**
	 * Search hits will be sorted around this position.
	 * If no areaID is given, this position will be usead as search area.
	 */
	WGS84Coordinate position;
	
	/// A WFString that holds what to search for.
	NSString *what;
	
	/**
	 * A WFString that holds where to search. Used to pick which search hits
	 * that are interesting.
	 */
	NSString *where;
	
	/// The wanted index of the first match in the reply.
	NSUInteger startIndex;
	
	/// The maximum number of hits wanted.
	NSUInteger maxHits;
	
	/// The wanted heading.
	NSUInteger headingID;
	
	/// The round to search in for this search.
	NSUInteger round;
	
	/// The ID of the category to search within.
	NSUInteger categoryID;
	
	BOOL aroundMe;
}

@property (nonatomic, retain) NSString *areaID;
@property (nonatomic, assign) NSUInteger topRegionID;
@property (nonatomic, assign) WGS84Coordinate position;
@property (nonatomic, retain) NSString *what;
@property (nonatomic, retain) NSString *where;
@property (nonatomic, assign) NSUInteger startIndex;
@property (nonatomic, assign) NSUInteger maxHits;
@property (nonatomic, assign) NSUInteger headingID;
@property (nonatomic, assign) NSUInteger round;
@property (nonatomic, assign) NSUInteger categoryID;

- (id)initWithWhat:(NSString *)queryString categoryID:(NSUInteger)catID topRegionID:(NSUInteger)countryID;
- (id)initWithWhat:(NSString *)queryString categoryID:(NSUInteger)catID position:(WGS84Coordinate)pos;

- (SearchQuery)asCoreSearchQuery;

@end
