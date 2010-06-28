/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Formatter.h"
#import "LocalizationHandler.h"
#import "IPNavSettingsManager.h"

@implementation Formatter

+ (NSString *)formatTime:(int)time {
	if(time < 60) {
		return [NSString stringWithFormat:@"%d sec", time, [LocalizationHandler getString:@"iPh_seconds_txt"]];
	}
	else {
		time = time / 60;
		if(time < 60) {
			return [NSString stringWithFormat:@"%d %@", time, [LocalizationHandler getString:@"iPh_minutes_txt"]];
		}
		else {
			return [NSString stringWithFormat:@"%d %@ %d %@", time/60, [LocalizationHandler getString:@"iPh_hours_txt"], time%60, [LocalizationHandler getString:@"iPh_minutes_txt"]];
		}
	}
}

+ (NSString *)formatDistance:(int)distance
{
	// Input parameter 'distance' is in meters
	const float kYardConversionUnit = 1.0f/0.91440; // 1 yard = 0.91440 meters
	const float kMileInYards = 1760; // 1 mile is 1760 yards
	const float kMileInFeets = 5280; // 1 mile is 5280 yards
	NSString *formattedString = nil;
	float distanceInYards = distance*kYardConversionUnit;
	
	switch ([[IPNavSettingsManager sharedInstance] distanceUnit]) {
		case MILES_YARD:{
			if(distanceInYards < kMileInYards) {
				formattedString = [NSString stringWithFormat:@"%d %@", (int)roundf(distanceInYards), [LocalizationHandler getString:@"iPh_yards_txt"]];
			}
			else if(distanceInYards < 1000*kMileInYards) {
				formattedString = [NSString stringWithFormat:@"%3.1f %@", (distanceInYards / kMileInYards), [LocalizationHandler getString:@"iPh_miles_txt"]];
			}
			else {
				formattedString = [NSString stringWithFormat:@"%d %@", (int)roundf(distanceInYards / kMileInYards), [LocalizationHandler getString:@"iPh_miles_txt"]];
			}
			break;
		}
		case MILES_FEET:{
			float distanceInFeets = distanceInYards * 3; // 1 foot is a third of a yard
			if(distanceInFeets < kMileInFeets) {
				formattedString = [NSString stringWithFormat:@"%d %@", (int)roundf(distanceInFeets), [LocalizationHandler getString:@"iPh_feet_txt"]];
			}
			else if(distanceInFeets < 1000*kMileInFeets) {
				formattedString = [NSString stringWithFormat:@"%3.1f %@", (distanceInFeets / kMileInFeets), [LocalizationHandler getString:@"iPh_miles_txt"]];
			}
			else {
				formattedString = [NSString stringWithFormat:@"%d %@", (int)roundf(distanceInFeets / kMileInFeets), [LocalizationHandler getString:@"iPh_miles_txt"]];					
			}
			break;
		}
		case KM: {
			if(distance < 1000) {
				formattedString = [NSString stringWithFormat:@"%d %@", distance, [LocalizationHandler getString:@"iPh_metres_txt"]];
			}
			else if(distance < 1000000) {
				formattedString = [NSString stringWithFormat:@"%3.1f %@", ((double)distance) / 1000.0, [LocalizationHandler getString:@"iPh_kilometres_txt"]];
			}
			else {
				formattedString = [NSString stringWithFormat:@"%d %@", distance / 1000, [LocalizationHandler getString:@"iPh_kilometres_txt"]];
			}
			break;
		}
		default:
			break;
	}
	
	return formattedString;
}

// the strings will be formatted like this: string1, string2, .... Case when a string is nil is treated.

+ (NSString*)formatStringsInLine:(NSArray*)stringArray {
	BOOL isFirstStringSet = NO; // Used to know if we are allowed to pot the character ','
	NSMutableString *res = [NSMutableString string];
	
	for(int i = 0; i<[stringArray count]; i++) {
		NSString *s = [stringArray objectAtIndex:i];
		if([s length] > 0) {
			if (!isFirstStringSet) {
				[res appendString:s];
			} else {
				[res appendString:[NSString stringWithFormat:@", %@", s]];
			}
			
			isFirstStringSet = YES;
		}
	}
	
	return res;
}

+ (NSString *)formatGeocodingInformationToOneLine:(GeocodingInformation *)geocodingInformation {
	NSString *result;
	switch(geocodingInformation->highestPrecision) {
		case WFAPI::GeocodingInformation::COUNTRY: {
			result = [self formatStringsInLine:[NSArray arrayWithObjects:
												[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
												nil
												]];
			break;
		}
		case WFAPI::GeocodingInformation::MUNICIPAL: {
			result = [self formatStringsInLine:[NSArray arrayWithObjects:
												[NSString stringWithCString:geocodingInformation->municipalName.c_str() encoding:NSUTF8StringEncoding],
												[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
												nil
												]];			
			break;
		}
		case WFAPI::GeocodingInformation::CITY: {
			result = [self formatStringsInLine:[NSArray arrayWithObjects:
												[NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
												[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
												nil
												]];			
			break;
		}
		case WFAPI::GeocodingInformation::DISTRICT: {
			result = [self formatStringsInLine:[NSArray arrayWithObjects:
												[NSString stringWithCString:geocodingInformation->districtName.c_str() encoding:NSUTF8StringEncoding],
												[NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
												[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
												nil
												]];	
			break;
		}
		case WFAPI::GeocodingInformation::ADDRESS: {
			result = [self formatStringsInLine:[NSArray arrayWithObjects:
												[NSString stringWithCString:geocodingInformation->addressName.c_str() encoding:NSUTF8StringEncoding],
												[NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
												[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
												nil
												]];	
			break;
		}
	}
	
	NSLog(@"Original geolocation: %s, %s, %s, %s, %s", 
		  geocodingInformation->countryName.c_str(), 
		  geocodingInformation->municipalName.c_str(),
		  geocodingInformation->cityName.c_str(),
		  geocodingInformation->districtName.c_str(),
		  geocodingInformation->addressName.c_str());	
	
	NSLog(@"Formatted geolocation line #1 : %@", result); 
	
	return result;
}

+ (NSArray *)formatGeocodingInformationToTwoLines:(GeocodingInformation *)geocodingInformation {
	NSString *addressLine1;
	NSString *addressLine2;
	
	switch(geocodingInformation->highestPrecision) {
		case WFAPI::GeocodingInformation::COUNTRY: {
			addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
							[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
							nil
							]];
			addressLine2 = @"";
			break;
		}
		case WFAPI::GeocodingInformation::MUNICIPAL: {
			addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
							[NSString stringWithCString:geocodingInformation->municipalName.c_str() encoding:NSUTF8StringEncoding],
							[NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
							nil
							]];			
			addressLine2 = @"";	
			break;
		}
		case WFAPI::GeocodingInformation::CITY: {
			if(strcmp(geocodingInformation->municipalName.c_str(), geocodingInformation->cityName.c_str()) == 0) {
				addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];			
				addressLine2 = @"";					
			}
			else {
				addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->municipalName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];			
				addressLine2 = @"";	
			}
			break;
		}
		case WFAPI::GeocodingInformation::DISTRICT: {
			if(strcmp(geocodingInformation->municipalName.c_str(), geocodingInformation->cityName.c_str()) == 0) {			
				addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->districtName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];						
				addressLine2 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->municipalName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];	
			}
			else {
				addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->districtName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];						
				addressLine2 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];					
			}
			break;
		}
		case WFAPI::GeocodingInformation::ADDRESS: {
			if(strcmp(geocodingInformation->municipalName.c_str(), geocodingInformation->cityName.c_str()) == 0) {						
				addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->addressName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->districtName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];						
				addressLine2 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->municipalName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];	
			}
			else {
				addressLine1 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->addressName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->districtName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];						
				addressLine2 = [self formatStringsInLine:[NSArray arrayWithObjects:
														  [NSString stringWithCString:geocodingInformation->cityName.c_str() encoding:NSUTF8StringEncoding],
														  [NSString stringWithCString:geocodingInformation->countryName.c_str() encoding:NSUTF8StringEncoding],
														  nil
														  ]];					
			}
			break;
		}
	}

	NSLog(@"Original geolocation: %s, %s, %s, %s, %s", 
		  geocodingInformation->countryName.c_str(), 
		  geocodingInformation->municipalName.c_str(),
		  geocodingInformation->cityName.c_str(),
		  geocodingInformation->districtName.c_str(),
		  geocodingInformation->addressName.c_str());		
	
	NSLog(@"Formatted geolocation line #1 : %@", addressLine1);
	NSLog(@"Formatted geolocation line #2 : %@", addressLine2);
		
	return [[[NSArray alloc] initWithObjects:addressLine1, addressLine2, nil] autorelease];
}	

+ (NSString *)trimWhitespaces:(NSString *)aString {
	NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [aString componentsSeparatedByCharactersInSet:whitespaces];
	NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
	return [filteredArray componentsJoinedByString:@" "];

}

@end
