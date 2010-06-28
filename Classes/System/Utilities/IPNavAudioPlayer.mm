/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPNavAudioPlayer.h"
#import "LocalizationHandler.h"
#import "WFNavigationAppDelegate.h"
#import "NavigationViewController.h"

#define MILISECONDS_FACTOR (1000);

static IPNavAudioPlayer *_audioPlayer;

@implementation IPNavAudioPlayer


+ (IPNavAudioPlayer *)sharedInstance {
	if (!_audioPlayer) {
		_audioPlayer = [[IPNavAudioPlayer alloc] init];
	}
	
	return _audioPlayer;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	// load localized sounds bundle
	LocalizationHandler *localizationHandler = [[LocalizationHandler alloc] init];
	_localizedBundlePath = [[self bundlePathForVoiceLanguage:[localizationHandler getVoiceLanguage]] retain];
	[localizationHandler release];
	
	_filesExtension = [[NSString alloc] initWithString:@"mp3"];
	
//	_cachedPlayers			= [[NSMutableDictionary alloc] init];	
	_cachedDataSounds		= [[NSMutableDictionary alloc] init];
//	_cachedCombinedSounds	= nil;//[[NSMutableDictionary alloc] init];
	
	_preparedPlayer = nil;
	_player = nil;
	
	return self;
}

- (void)dealloc {
	[_preparedPlayer release];
	[_player release];
	
	[_localizedBundlePath release];
	[_filesExtension release];
	
//	[_cachedPlayers release];
	[_cachedDataSounds release];
//	[_cachedCombinedSounds release];
	[super dealloc];
}

- (void)prepareToPlayTheFollowingSequence:(NSArray *)sequence {
	
//	NSString *sequenceKey = [sequence componentsJoinedByString:@""];
	
	// check if the player for this sequence was already prepared
//	if (![[_cachedPlayers allKeys] containsObject:sequenceKey]) {
		
		// check if the sequence data was already loaded 
//		if (![[_cachedCombinedSounds allKeys] containsObject:sequenceKey]) {
			
			NSMutableData *sequenceData = [[NSMutableData alloc] init];
			
			for (NSUInteger index = 0, count = [sequence count]; index < count; index++) {
				NSData *soundData = nil;
				NSString *soundKey = [sequence objectAtIndex:index];
				
				// check if the data for this sound was already loaded
				if (![[_cachedDataSounds allKeys] containsObject:soundKey]) {
					NSString *soundName = [soundKey stringByAppendingPathExtension:_filesExtension];
					NSString *soundPath = [_localizedBundlePath stringByAppendingPathComponent:soundName];
					soundData = [[NSData alloc] initWithContentsOfFile:soundPath];
					if (soundData) {
						[_cachedDataSounds setObject:soundData forKey:soundKey];
					} else {
						NSLog(@"Sound file not found at path: %@", soundPath);
					}
					
					[soundData release];
				}
				
				soundData = [_cachedDataSounds objectForKey:soundKey];
				[sequenceData appendData:soundData];
			}
			
//			[_cachedCombinedSounds setObject:sequenceData forKey:sequenceKey];
//			[sequenceData release];
//		}
		
		// initialize player
		NSError *playerError = nil;
		AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:sequenceData error:&playerError];
		[sequenceData release];
	
		if (playerError != nil) {
			NSLog(@"Player failed to initialize with the following error: %@", [playerError localizedDescription]);
		}
		
		if (player) {
			[player setVolume:1.0];
			
			// prepare + cache player
			[player prepareToPlay];
			//[_cachedPlayers setObject:player forKey:sequenceKey];
		}
	
	// get current player
	[_preparedPlayer release];
	_preparedPlayer = player;//[_cachedPlayers objectForKey:sequenceKey];
}

- (NSTimeInterval)currentSoundDuration {
	return [_preparedPlayer duration] * MILISECONDS_FACTOR;
}

- (NSString *)bundlePathForVoiceLanguage:(WFAPI::VoiceLanguage::VoiceLanguage)voiceLanguage {
	NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MP3"];
	
	switch (voiceLanguage) {
		case WFAPI::VoiceLanguage::GERMAN:
			path = [path stringByAppendingPathComponent:@"DE"];
			break;
		case WFAPI::VoiceLanguage::ITALIAN:
			path = [path stringByAppendingPathComponent:@"IT"];
			break;
//		case WFAPI::VoiceLanguage::IRLAND:
//			path = [path stringByAppendingPathComponent:@"IE"];
//			break;
		case WFAPI::VoiceLanguage::ENGLISH:
			path = [path stringByAppendingPathComponent:@"EN"];
			break;
		case WFAPI::VoiceLanguage::GREEK:
			path = [path stringByAppendingPathComponent:@"EL"];
			break;
		case WFAPI::VoiceLanguage::SPANISH:
			path = [path stringByAppendingPathComponent:@"ES"];
			break;
		case WFAPI::VoiceLanguage::DUTCH:
			path = [path stringByAppendingPathComponent:@"NL"];
			break;
		case WFAPI::VoiceLanguage::PORTUGUESE:
			path = [path stringByAppendingPathComponent:@"PT"];
			break;
		default:
			path = [path stringByAppendingPathComponent:@"EN"]; 
			break;
	}
	
	return path;
}

- (void)play {
	if ([_player isPlaying]) [_player stop];

	[_player release];
	_player = [_preparedPlayer retain];
	
	WFNavigationAppDelegate *delegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([[delegate.navController topViewController] isKindOfClass:[NavigationViewController class]]) {
		[_player setVolume:1.0];
		[_player play];
	}
}

- (void)stop {
	[_player stop];
}


@end
