/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "UIApplication-Additions.h"
#import "NSData+Base64Additions.h"
#import "SKPSMTPMessage.h"

// this constant defines the name for the log file
static NSString *LOG_FILE_NAME = @"console.txt";

// this constant defines the address where the log file is being sent
static NSString *LOG_EMAIL_ADDRESS = @"iLogs@wayfinder.com";

// this constant defines the address for the email server
static NSString *EMAIL_RELAY_HOST = @"fw.itinerary.com";

// this constant defines the key used in NSUserDefaults to identify Log Info data
static NSString *LOG_CREATION_DATE_KEY = @"LogInfoCreationDate";

// this constant defines the key used in NSUserDefaults to identify log secret search word (secret word that triggers sending logs through email)
static NSString *LOG_SECRET_SEARCH_KEY = @"LogSecretSearch";

// this constant defines the default value for the secret word
static NSString *LOG_DEFAULT_SECRET_WORD = @"1234567";

@implementation UIApplication (UIApplication_Additions) 

#pragma mark FirstTimeStart related methods
+ (BOOL)firstStart {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	BOOL firstStart = ![userDefaults boolForKey:@"NavFirstStart"];
	
	if (firstStart) {
		[userDefaults setBool:YES forKey:@"NavFirstStart"];
		[userDefaults synchronize];
	}
	
	return firstStart;
}


#pragma mark EULA related methods
+ (void)acceptEULA:(BOOL)accepted {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:accepted forKey:@"NavEULAAccepted"];
	[userDefaults synchronize];
}

+ (BOOL)EULAAccepted {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"NavEULAAccepted"];
}

#pragma mark Driving Warning related methods

+ (BOOL)drivingWarningDisabled {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"NavDrivingWarningDisabled"];
}

+ (void)disableDrivingWarning:(BOOL)disable {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:disable forKey:@"NavDrivingWarningDisabled"];
	[userDefaults synchronize];
}

/*
 * Utility method to resolve bundlePath (for locating paramseed file)
 */
+ (NSString *)getBundlePath {
	NSString *bundleStr = [[[NSString alloc] initWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]] autorelease];
	return bundleStr;
}

/*
 * Utility method to resolve documentsPath (which is writable and hence used for caching and writing other stuff)
 */
+ (NSString *)getDocumentsPath {
	NSArray *docList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														   NSUserDomainMask,
														   YES);
	
	/** Take the last path in the list, this is the most suitable */
	
	NSString* nsDocumentsDirectory = [docList lastObject];
	NSString *docPathStr = [[[NSString alloc] initWithFormat:@"%@/", nsDocumentsDirectory] autorelease];
	return docPathStr;
}

+ (NSString *)getSoundsPath {
	return [NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] bundlePath]];
}

+ (NSString *)getLogFilePath {
	NSString *documentsPath = [self getDocumentsPath];
	return [documentsPath stringByAppendingPathComponent:LOG_FILE_NAME];
}

+ (void)enableLogFileSystem {
	// get log file path
	NSString *logFilePath = [self getLogFilePath];
 
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSString *secretWord = [userDefaults objectForKey:LOG_SECRET_SEARCH_KEY];
	if (!secretWord) {
		[userDefaults setObject:LOG_DEFAULT_SECRET_WORD forKey:LOG_SECRET_SEARCH_KEY];
	}
	
	BOOL cleanLogsFile = NO;
	
	NSDate *creationDate = [userDefaults objectForKey:LOG_CREATION_DATE_KEY];
	if (nil != creationDate) {
		NSTimeInterval interval = [creationDate timeIntervalSinceNow];
		if (interval > 24 * 3600) {
			cleanLogsFile = YES;
		}
	} else {
		cleanLogsFile = YES;
	}
	
	if (cleanLogsFile) {
		freopen([logFilePath UTF8String], "w+", stderr);
		[userDefaults setObject:[NSDate date] forKey:LOG_CREATION_DATE_KEY];
	} else {	
		freopen([logFilePath UTF8String], "a+", stderr);
	}
}

+ (void)sendLogsFileWithDelegate:(id)delegate {

	[UIApplication generateNewSecretWord];
	
	SKPSMTPMessage *logMessage = [[SKPSMTPMessage alloc] init];
    logMessage.fromEmail = LOG_EMAIL_ADDRESS;
    logMessage.toEmail = LOG_EMAIL_ADDRESS;
    logMessage.relayHost = EMAIL_RELAY_HOST;
    logMessage.requiresAuth = NO;
    logMessage.subject = [NSString stringWithFormat:@"Log File for device: %@, New Secret Key: %@", [[UIDevice currentDevice] uniqueIdentifier], [UIApplication secretWord]];
    logMessage.delegate = delegate;
	
	
	logMessage.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
    logMessage.validateSSLChain = NO;
    
	// create attachment part for the message
    NSString *logsPath = [self getLogFilePath];
    NSData *logsData = [NSData dataWithContentsOfFile:logsPath];
    
    NSDictionary *logsPart = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"", LOG_FILE_NAME], kSKPSMTPPartContentTypeKey,
																	    [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"", LOG_FILE_NAME], kSKPSMTPPartContentDispositionKey,
																	    [logsData encodeBase64ForData], kSKPSMTPPartMessageKey,
																	    @"base64", kSKPSMTPPartContentTransferEncodingKey,
							 nil];
    
    logMessage.parts = [NSArray arrayWithObjects: logsPart, nil];
	//!!! Library Design - the message will be released by the delegate 
	// send message
    [logMessage send];
}

+ (NSString *)secretWord {
	return [[NSUserDefaults standardUserDefaults] objectForKey:LOG_SECRET_SEARCH_KEY];
}

+ (void)generateNewSecretWord {	
	//generate new secret word
	NSString *secretWord = [NSString stringWithFormat:@"%d", random()];
	[[NSUserDefaults standardUserDefaults] setObject:secretWord forKey:LOG_SECRET_SEARCH_KEY];
}

+ (void)resetSecretWord {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:LOG_DEFAULT_SECRET_WORD forKey:LOG_SECRET_SEARCH_KEY];
}

@end
