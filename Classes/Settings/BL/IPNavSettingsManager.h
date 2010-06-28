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
#import "SettingsInterface.h"
#import "Position.h"
#import "WGS84Coordinate.h"

using namespace WFAPI;

typedef enum IPNavSettingsSectionsType {
	IPNavSettingsSectionGeneral = 0,
	IPNavSettingsSectionRoute,
	IPNavSettingsSectionMap,
	// IPNavSettingsSectionAccount,
	IPNavSettingsSectionDebug
} IPNavSettingsSectionsType;

typedef enum IPNavSettingsType {
	IPNavGPSConnection = 0,
	IPNavKeepGPRSAlive,
	IPNavBacklight,
	IPNavDistanceUnits,
	IPNavRouteOptimisation,
	IPNavVoicePrompts,
	IPNavVoicePromptsVlume,
	IPNavUseTollRoads,
	IPNavUseMotorway,
	IPNavTrafficUpdate,
	IPNavPOIDownloads,
	IPNavShowMyPlaces,
	IPNavAccountStatus,
	IPNavAccountUsername,
	IPNavAccountPassword,
	IPNavDebugExplicitPosition,
	IPNavDebugPositionLatitude,
	IPNavDebugPositionLongitude,
	IPNavDebugClientType,
	IPNavSpeedZoom
} IPNavSettingsType;

@interface IPNavSettingsManager : NSObject {
	WFAPI::SettingsInterface *_interface;
	
	NSArray *_backlightTypes;
	NSArray *_distanceUnits;
	NSArray *_routeOptimisationTypes;
	NSArray *_trafficUpdatesIntervals;
	NSArray *_POIDownloadsTypes;
	NSArray *_clientTypes;
	
	NSMutableDictionary *_categories;
	
	BOOL _GPSConnectionOn, _keepGPRSAlive, _voicePromptsOn;
	BOOL _useTollRoads, _useMotorway, _showMyPlaces;
	BOOL debugEnabled;
	
	NSUInteger _backlightType;
	NSUInteger _distanceUnitType;
	NSUInteger _routeOptimisationType;
	NSUInteger _trafficUpdatesIntervalType;
	NSUInteger _POIDownloadsType;
	BOOL _useExplicitPosition;
	float _latitude;
	float _longitude;
	NSUInteger _clientType;
	
	BOOL _enableSpeedZoom;
	
	BOOL _accountSignedOn;
	NSString *_accountUsername;
	NSString *_accountPassword;
}

@property (nonatomic, assign) BOOL GPSConnectionOn;

@property (nonatomic, retain) NSArray *backlightTypes;
@property (nonatomic, retain) NSArray *routeOptimisationTypes;
@property (nonatomic, retain) NSArray *trafficUpdatesIntervals;
@property (nonatomic, retain) NSArray *distanceUnits;
@property (nonatomic, retain) NSArray *POIDownloadsTypes;
@property (nonatomic, retain) NSArray *clientTypes;
@property (nonatomic, assign) BOOL speedZoomEnabled;

// use this method to get Settings Manager
+ (IPNavSettingsManager *)sharedInstance;

- (void)postNotificationSettingsChanged;
- (void)postNotificationSettingsChangedInSection:(IPNavSettingsSectionsType)section;

- (void)loadSettingsAdditionalInformation;
- (void)loadSettings;

- (void)saveSettings;

- (NSDictionary *)infoForSettingType:(IPNavSettingsType)settingType;

- (void)GPSConnectionChanged:(id)sender;
- (void)keepGPRSAliveChanged:(id)sender;
- (void)voicePromptsChanged:(id)sender;
- (BOOL)voicePromptsOn;
- (void)useTollRoadsChanged:(id)sender;
- (void)useMotorwayChanged:(id)sender;
//- (void)showMyPlacesChanged:(id)sender;
- (void)enableSpeedZoomChanged:(id)sender;
- (void)useExplicitUserPosition:(id)sender;

- (void)setBacklightType:(NSNumber *)backlightType;
- (void)setDistanceUnitType:(NSNumber *)distanceUnitType;
- (void)setRouteOptimisationType:(NSNumber *)routeOptimisationType;
- (void)setTrafficUpdatesIntervalType:(NSNumber *)trafficUpdatesIntervalType;
- (void)setPOIDownloadsType:(NSNumber *)POIDownloadType;

- (void)setUseExplicitPosition:(BOOL)newValue;
- (BOOL)useExplicitPosition;

- (void)setLatitude:(float)latitude;
- (float)getLatitude;
- (void)setLongitude:(float)longitude;
- (float)getLongitude;
- (void)setClientType:(NSNumber *)clientType;

- (BOOL)valueForCategory:(NSString *)categoryID;
- (void)setValue:(BOOL)val forCategory:(NSString *)categoryID;

- (void)hidePOIs:(BOOL)hide;

- (WFAPI::DistanceUnit)distanceUnit;
- (void)setUIN:(NSString *)uin;

- (NSString *)getUsername;
@end
