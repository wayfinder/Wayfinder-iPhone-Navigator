/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPNavSettingsManager.h"
#import "SettingsInterface.h"

#import "DetailedConfigInterface.h"
#import "MapDrawingInterface.h"
#import "ConfigInterface.h"
#import "POICategories.h"

#import "AppSession.h"
#import "LocalizationHandler.h"

#import "DistanceUnit.h"
#import "StatusCode.h"
#import "VoiceVerbosity.h"

static IPNavSettingsManager *settingsManager;

@implementation IPNavSettingsManager

@synthesize GPSConnectionOn = _GPSConnectionOn;
//@synthesize showMyPlaces = _showMyPlaces;

@synthesize backlightTypes = _backlightTypes;
@synthesize routeOptimisationTypes = _routeOptimisationTypes;
@synthesize trafficUpdatesIntervals = _trafficUpdatesIntervals;
@synthesize distanceUnits = _distanceUnits;
@synthesize POIDownloadsTypes = _POIDownloadsTypes;
@synthesize clientTypes = _clientTypes;
@synthesize speedZoomEnabled = _enableSpeedZoom;


+ (IPNavSettingsManager *)sharedInstance {
	if (!settingsManager) {
		settingsManager = [[IPNavSettingsManager alloc] init];
	}
	return settingsManager;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	// get settings interface
	_interface = &APP_SESSION.nav2API->getSettingsInterface();
	
	// set voice verbosity
	_interface->setVoiceVerbosity(FEW);
			
	/*
	 * load settings data (categories, poi downloads types and selected settings)
	 * this methods executes synchronious calls so we need to do this on a different thread
	 */
	[self loadSettingsAdditionalInformation];
	[self loadSettings];
	
	return self;
}

- (void)dealloc {
	[_backlightTypes release];
	[_distanceUnits release];
	[_routeOptimisationTypes release];
	[_trafficUpdatesIntervals release];
	[_POIDownloadsTypes release];
	[_clientTypes release];
	
	[super dealloc];
}

- (void)hidePOIs:(BOOL)hide {
	DetailedConfigInterface *detailedConfigInterface = APP_SESSION.mapLibAPI->getConfigInterface()->getDetailedConfigInterface();
	detailedConfigInterface->hidePOIs(hide ? true : false);
}

- (void)postNotificationSettingsChanged {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:self];
}

- (void)postNotificationSettingsChangedInSection:(IPNavSettingsSectionsType)section {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:section] forKey:@"section"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChangedInSection" 
														object:self 
													  userInfo:userInfo];
}


- (void)loadSettingsAdditionalInformation {
	_backlightTypes				= [[NSArray alloc] initWithObjects: [LocalizationHandler getString:@"iPh_normal_sett_tk"], 
																	[LocalizationHandler getString:@"iPh_before_turns_sett_tk"],
																	[LocalizationHandler getString:@"iPh_only_on_route_sett_tk"],
																	[LocalizationHandler getString:@"iPh_always_on_tk"],
								nil];
	
	_distanceUnits				= [[NSArray alloc] initWithObjects: [LocalizationHandler getString:@"iPh_metric_sett_tk"],
																	[LocalizationHandler getString:@"iPh_miles_feet_sett_tk"],
																	[LocalizationHandler getString:@"iPh_miles_yards_sett_tk"],
								nil];
	
	_routeOptimisationTypes		= [[NSArray alloc] initWithObjects: [LocalizationHandler getString:@"iPh_fastest_route_sett_tk"],
																	[LocalizationHandler getString:@"iPh_shortest_route_sett_tk"],
								nil];
	
	_trafficUpdatesIntervals	= [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"5 %@", [LocalizationHandler getString:@"iPh_minutes_txt"]],
																	[NSString stringWithFormat:@"10 %@", [LocalizationHandler getString:@"iPh_minutes_txt"]],
																	[NSString stringWithFormat:@"15 %@", [LocalizationHandler getString:@"iPh_minutes_txt"]],
																	[NSString stringWithFormat:@"30 %@", [LocalizationHandler getString:@"iPh_minutes_txt"]],
																	[NSString stringWithFormat:@"60 %@", [LocalizationHandler getString:@"iPh_minutes_txt"]],
								nil];
	
	_POIDownloadsTypes			= [[NSArray alloc] initWithObjects: [LocalizationHandler getString:@"iPh_normal_sett_tk"],
																	[LocalizationHandler getString:@"iPh_limited_sett_tk"],
								nil];
	
	_clientTypes				= [[NSArray alloc] initWithObjects: [LocalizationHandler getString:@"iPh_test_client_type_sett_tk"],
																	[LocalizationHandler getString:@"iPh_prod_client_type_sett_tk"],
								nil];
}

- (void)loadSettings {
	NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];
	
	_GPSConnectionOn	= [settings objectForKey:@"GPSConnection"]	? [[settings objectForKey:@"GPSConnection"] boolValue]	: YES;
	_keepGPRSAlive		= [settings objectForKey:@"KeepGPRSAlive"]	? [[settings objectForKey:@"KeepGPRSAlive"] boolValue]	: YES;
	
	_voicePromptsOn		= [settings objectForKey:@"VoicePrompts"]	? [[settings objectForKey:@"VoicePrompts"] boolValue]	: YES;
	_useTollRoads		= [settings objectForKey:@"UseTollRoads"]	? [[settings objectForKey:@"UseTollRoads"] boolValue]	: YES;
	_useMotorway		= [settings objectForKey:@"UseMotorway"]	? [[settings objectForKey:@"UseMotorway"] boolValue]	: YES;
//	_showMyPlaces		= [settings objectForKey:@"ShowMyPlaces"]	? [[settings objectForKey:@"ShowMyPlaces"] boolValue]	: YES;
	_accountSignedOn	= [settings objectForKey:@"SignedIn"]		? [[settings objectForKey:@"SignedIn"] boolValue]		: YES;
	
	_backlightType				= [settings objectForKey:@"BackLight"]			? [[settings objectForKey:@"BackLight"] intValue]			: 0;
	_distanceUnitType			= [settings objectForKey:@"DistanceUnits"]		? [[settings objectForKey:@"DistanceUnits"] intValue]		: 2;
	[self setDistanceUnitType:[NSNumber numberWithInt:_distanceUnitType]];

	_routeOptimisationType		= [settings objectForKey:@"RouteOptimisation"]	? [[settings objectForKey:@"RouteOptimisation"] intValue]	: 0;
	_trafficUpdatesIntervalType = [settings objectForKey:@"TrafficUpdates"]		? [[settings objectForKey:@"TrafficUpdates"] intValue]		: 0;
	_POIDownloadsType			= [settings objectForKey:@"POIDownloads"]		? [[settings objectForKey:@"POIDownloads"] intValue]		: 0;
	
	_useExplicitPosition		= [settings objectForKey:@"ExplicitPosition"] ? [[settings objectForKey:@"ExplicitPosition"] boolValue] : NO;	
	_latitude					= [settings objectForKey:@"Latitude"] ? [[settings objectForKey:@"Latitude"] floatValue] : 180.0;
	_longitude					= [settings objectForKey:@"Longitude"] ? [[settings objectForKey:@"Longitude"] floatValue] : 180.0;
	
	_clientType		= [settings objectForKey:@"ClientType"] ? [[settings objectForKey:@"ClientType"] intValue] : 0;
	
	_enableSpeedZoom = [settings objectForKey:@"SpeedZoom"]	? [[settings objectForKey:@"SpeedZoom"] boolValue] : NO;
	
	_accountUsername = [settings objectForKey:@"Username"] ? [settings objectForKey:@"Username"] : @"";
	_accountPassword = [settings objectForKey:@"Password"] ? [settings objectForKey:@"Password"] : @"";
	
	_categories		 = [[settings objectForKey:@"categories"] retain];
	if (!_categories)  {
		_categories = [[NSMutableDictionary alloc] init];
		
		NSArray *searchCategories = [APP_SESSION.searchInterface searchCategories];
		for (NSUInteger index = 0, count = [searchCategories count]; index < count; index++) {
			SearchCategoryDetail *categoryDetail = [searchCategories objectAtIndex:index];
			[_categories setObject:[NSNumber numberWithBool:YES] forKey:[categoryDetail categoryID]];
		}
	}
}

- (void)saveSettings {

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	
	[settings setObject:[NSNumber numberWithBool:_GPSConnectionOn] forKey:@"GPSConnection"];
	[settings setObject:[NSNumber numberWithBool:_keepGPRSAlive] forKey:@"KeepGPRSAlive"];
	[settings setObject:[NSNumber numberWithBool:_voicePromptsOn] forKey:@"VoicePrompts"];
	[settings setObject:[NSNumber numberWithBool:_useTollRoads] forKey:@"UseTollRoads"];
	[settings setObject:[NSNumber numberWithBool:_useMotorway] forKey:@"UseMotorway"];
//	[settings setObject:[NSNumber numberWithBool:_showMyPlaces] forKey:@"ShowMyPlaces"];
	[settings setObject:[NSNumber numberWithBool:_accountSignedOn] forKey:@"SignedIn"];
	
	[settings setObject:[NSNumber numberWithInt:_backlightType] forKey:@"BackLight"];
	[settings setObject:[NSNumber numberWithInt:_distanceUnitType] forKey:@"DistanceUnits"];
	[settings setObject:[NSNumber numberWithInt:_routeOptimisationType] forKey:@"RouteOptimisation"];
	[settings setObject:[NSNumber numberWithInt:_trafficUpdatesIntervalType] forKey:@"TrafficUpdates"];
	[settings setObject:[NSNumber numberWithInt:_POIDownloadsType] forKey:@"POIDownloads"];
	[settings setObject:[NSNumber numberWithInt:_useExplicitPosition] forKey:@"ExplicitPosition"];
	[settings setObject:[NSNumber numberWithFloat:_latitude] forKey:@"Latitude"];	
	[settings setObject:[NSNumber numberWithFloat:_longitude] forKey:@"Longitude"];		
	[settings setObject:[NSNumber numberWithInt:_clientType] forKey:@"ClientType"];
	
	[settings setObject:[NSNumber numberWithBool:_enableSpeedZoom] forKey:@"SpeedZoom"];

	[settings setObject:@"" forKey:@"Username"];
	[settings setObject:@"" forKey:@"Password"];
	if (_categories) [settings setObject:_categories forKey:@"categories"];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:settings forKey:@"settings"];
	
	[settings release];
}

- (NSDictionary *)infoForSettingType:(IPNavSettingsType)settingType {
	NSDictionary *settingInfo = nil;
	NSString *settingLabel = nil;
	switch (settingType) {
		case IPNavGPSConnection:
			settingLabel = [LocalizationHandler getString:@"iPh_gps_connection_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName", 
																	 [NSNumber numberWithBool:_GPSConnectionOn], @"settingValue", 
						   nil];
			break;
		case IPNavKeepGPRSAlive:
			settingLabel = [LocalizationHandler getString:@"iPh_gprs_connection_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	 [NSNumber numberWithBool:_keepGPRSAlive], @"settingValue",
						   nil];
			break;
		case IPNavDistanceUnits:
			settingLabel = [LocalizationHandler getString:@"iPh_distance_units_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	 [_distanceUnits objectAtIndex:_distanceUnitType], @"settingValue",
																	 [NSNumber numberWithInt:_distanceUnitType], @"selectedValueIndex",
																	 _distanceUnits, @"datasource",
						   nil];
			break;
		case IPNavRouteOptimisation:
			settingLabel = [LocalizationHandler getString:@"iPh_route_optimisation_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	 [_routeOptimisationTypes objectAtIndex:_routeOptimisationType], @"settingValue",
																	 [NSNumber numberWithInt:_routeOptimisationType], @"selectedValueIndex",
																	 _routeOptimisationTypes, @"datasource",
						   nil];
			break;
		case IPNavVoicePrompts:
			settingLabel = [LocalizationHandler getString:@"iPh_voice_guidance_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[NSNumber numberWithBool:_voicePromptsOn], @"settingValue",
						   nil];
			break;
		case IPNavUseTollRoads:
			settingLabel = [LocalizationHandler getString:@"iPh_use_toll_roads_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[NSNumber numberWithBool:_useTollRoads], @"settingValue",
						   nil];
			break;
		case IPNavUseMotorway:
			settingLabel = [LocalizationHandler getString:@"iPh_use_motorways_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[NSNumber numberWithBool:_useMotorway], @"settingValue",
						   nil];
			break;
		case IPNavTrafficUpdate:
			settingLabel = [LocalizationHandler getString:@"iPh_traffic_updates_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[_trafficUpdatesIntervals objectAtIndex:_trafficUpdatesIntervalType], @"settingValue",
																    [NSNumber numberWithInt:_trafficUpdatesIntervalType], @"selectedValueIndex",
																    _trafficUpdatesIntervals, @"datasource",
						   nil];
			break;
		case IPNavPOIDownloads:
			settingLabel = [LocalizationHandler getString:@"iPh_poi_downloads_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[_POIDownloadsTypes objectAtIndex:_POIDownloadsType], @"settingValue",
																	[NSNumber numberWithInt:_POIDownloadsType], @"selectedValueIndex",
																	_POIDownloadsTypes, @"datasource",
						   nil];
			break;
		case IPNavAccountStatus:
			settingLabel = [LocalizationHandler getString:@"iPh_logged_in_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[NSNumber numberWithBool:_accountSignedOn], @"settingValue",
						   nil];
			break;
		case IPNavAccountUsername:
			settingLabel = [LocalizationHandler getString:@"iPh_username_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	_accountUsername, @"settingValue",
						   nil];
			break;
		case IPNavAccountPassword:
			settingLabel = [LocalizationHandler getString:@"iPh_password_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	_accountPassword, @"settingValue",
						   nil];
			break;
		case IPNavDebugExplicitPosition:
			settingLabel = [LocalizationHandler getString:@"iPh_explicit_postion_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
						   [NSNumber numberWithBool:_useExplicitPosition], @"settingValue",
						   nil];
			break;
		case IPNavDebugPositionLatitude:
			settingLabel = [LocalizationHandler getString:@"iPh_latitude_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
																	[NSNumber numberWithFloat:_latitude], @"settingValue",
						   nil];			
			break;
		case IPNavDebugPositionLongitude:
			settingLabel = [LocalizationHandler getString:@"iPh_longitude_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
												[NSNumber numberWithFloat:_longitude], @"settingValue",
						   nil];			
			break;			
		case IPNavDebugClientType:
			settingLabel = [LocalizationHandler getString:@"iPh_clientserver_sett_txt"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
										[_clientTypes objectAtIndex:_clientType], @"settingValue",
											[NSNumber numberWithInt:_clientType], @"selectedValueIndex",
																	_clientTypes, @"datasource",
						   nil];				
			break;		
		case IPNavSpeedZoom:
			settingLabel = [LocalizationHandler getString:@"[enable_speed_zoom]"];
			settingInfo = [NSDictionary dictionaryWithObjectsAndKeys:settingLabel, @"settingName",
						   [NSNumber numberWithBool:_enableSpeedZoom], @"settingValue",
						   nil];
			break;
		default:
			break;
	}

	return settingInfo;
}

- (void)GPSConnectionChanged:(id)sender {
	BOOL CGPSConnectionValue = [(UISwitch *)sender isOn];
	_GPSConnectionOn = CGPSConnectionValue;
	[self saveSettings];
//	[self postNotificationSettingsChangedInSection:IPNavSettingsSectionGeneral];
}

- (void)keepGPRSAliveChanged:(id)sender {
	BOOL keepGPRSAliveValue = [(UISwitch *)sender isOn];
	_keepGPRSAlive = keepGPRSAliveValue;
	[self saveSettings];
}

- (void)voicePromptsChanged:(id)sender {
	BOOL voicePromptsValue = [(UISwitch *)sender isOn];
	_voicePromptsOn = voicePromptsValue;
	[self saveSettings];
}

- (BOOL)voicePromptsOn {
	return _voicePromptsOn;
}

- (void)useTollRoadsChanged:(id)sender {
	BOOL useTollRoadsValue = [(UISwitch *)sender isOn];
	_useTollRoads = useTollRoadsValue;
	[self saveSettings];
	_interface->setAvoidTollRoad(_useTollRoads ? false : true);
}

- (void)useMotorwayChanged:(id)sender {
	BOOL useMotorwayValue = [(UISwitch *)sender isOn];
	_useMotorway = useMotorwayValue;
	[self saveSettings];
	_interface->setAvoidHighway(_useMotorway ? false : true);
}

- (void)enableSpeedZoomChanged:(id)sender {
	BOOL enableSpeedZoom = [(UISwitch *)sender isOn];
	_enableSpeedZoom = enableSpeedZoom;
	[self saveSettings];
}

- (void)useExplicitUserPosition:(id)sender {
	BOOL useUsersPosition = [(UISwitch *)sender isOn];
	[self setUseExplicitPosition:useUsersPosition];
	[self saveSettings];
}


- (void)setBacklightType:(NSNumber *)backlightType {
	_backlightType = [backlightType intValue];
	[self saveSettings];
	[self postNotificationSettingsChanged];
}

- (void)setDistanceUnitType:(NSNumber *)distanceUnitType {
	_distanceUnitType = [distanceUnitType intValue];
	[self saveSettings];
	// set value on the server
	SynchronousStatus status = _interface->setDistanceUnit((DistanceUnit) _distanceUnitType);
	int statusCode = status.getStatusCode();	
	if (OK  != statusCode) {
		NSLog(@"setting was not set");
	}
	// post notification that settings are changed
	[self postNotificationSettingsChanged];
}

- (void)setRouteOptimisationType:(NSNumber *)routeOptimisationType {
	_routeOptimisationType = [routeOptimisationType intValue];
	_interface->setRouteCost((RouteCost) _routeOptimisationType);
	[self saveSettings];
	[self postNotificationSettingsChanged];
}

- (void)setTrafficUpdatesIntervalType:(NSNumber *)trafficUpdatesIntervalType {
	_trafficUpdatesIntervalType = [trafficUpdatesIntervalType intValue];
	
	// transform selected time interval into minutes
	wf_uint32 minutes = 0;
	switch (_trafficUpdatesIntervalType) {
		case 0:
			minutes = 5;
			break;
		case 1:
			minutes = 10;
			break;
		case 2:
			minutes = 15;
			break;
		case 3:
			minutes = 30;
			break;
		case 4:
			minutes = 60;
			break;
		default:
			break;
	}
	
	[self saveSettings];
	_interface->setTrafficInformationUpdateTime(minutes);
	[self postNotificationSettingsChanged];
}

- (void)setPOIDownloadsType:(NSNumber *)POIDownloadType {
	_POIDownloadsType = [POIDownloadType intValue];
	[self saveSettings];
	[self postNotificationSettingsChanged];
}

- (void)setUseExplicitPosition:(BOOL)newValue {	
	_useExplicitPosition = newValue;
	[self postNotificationSettingsChanged];
}

- (BOOL)useExplicitPosition {
	return _useExplicitPosition;
}

- (void)setLatitude:(float)latitude {
	 _latitude = latitude;
	[self saveSettings];
	[self postNotificationSettingsChanged];
}

- (float)getLatitude {
	return _latitude;
}

- (void)setLongitude:(float)longitude {
	_longitude = longitude;
	[self saveSettings];
	[self postNotificationSettingsChanged];
}

- (float)getLongitude {
	return _longitude;
}

- (void)setClientType:(NSNumber *)clientType {
	_clientType = [clientType intValue];
	[self saveSettings];
	
	APP_SESSION.nav2API->setClientType(WFString(CLIENT_TYPE));	
	
	[self postNotificationSettingsChanged];	
}

- (BOOL)valueForCategory:(NSString *)categoryID {
	return [[_categories objectForKey:categoryID] boolValue];
}

- (void)setValue:(BOOL)val forCategory:(NSString *)categoryID {
	[_categories setObject:[NSNumber numberWithBool:val] forKey:categoryID];
}

- (DistanceUnit)distanceUnit {
	return (DistanceUnit)_distanceUnitType;
}

- (void)setUIN:(NSString *)uin {
	_interface->setUIN([uin UTF8String]);
}

- (NSString *)getUsername {
	WFString username;
	_interface->getUsername(username);
	return [NSString stringWithCString:username.c_str() encoding:NSUTF8StringEncoding];
}

@end
