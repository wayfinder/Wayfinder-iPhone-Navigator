/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "ErrorHandler.h"
#import <QuartzCore/QuartzCore.h>
#import "WFNavigationAppDelegate.h"
#import "LocalizationHandler.h"
#import "BillingViewController.h"
#import "NetworkStatusCode.h"

using namespace WFAPI;

static ErrorHandler *ERROR_HANDLER;

@implementation ErrorHandler

@synthesize displayErrorMessage;
@synthesize errorCodesForRequestOwners;
@synthesize dialogForErrorCodes;
@synthesize internalAlertView;
@synthesize preserveInternalAlertView;
@synthesize shouldExit;

+ (ErrorHandler *)sharedInstance {
	if (!ERROR_HANDLER) {
		ERROR_HANDLER = [[ErrorHandler alloc] init];
	}
	
	return ERROR_HANDLER;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	self.shouldExit = NO;
	self.preserveInternalAlertView = NO;
	self.displayErrorMessage = YES;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	self.errorCodesForRequestOwners = dict;
	[dict release];
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.dialogForErrorCodes = array;
	[array release];
	
	startupProcessBegan = NO;
	
	return self;
}

- (void)dealloc {
	self.errorCodesForRequestOwners = nil;
	self.dialogForErrorCodes = nil;
	self.internalAlertView  = nil;
	[super dealloc];
}

/*
 * Not part of the new error handling - still here because not all interfaces use the new error handling yet.
 */
- (BOOL)displayWarningForStatus:(AsynchronousStatus *)status receiverObject:(id)receiverObject withExit:(BOOL)exit {
	NSLog(@"This should never be invoked! Please fix it!");
/*
	if(!self.displayErrorMessage) {
		return YES;
	}
	
	// get status code
	NSUInteger statusCode = status->getStatusCode();

	// user account does not exist error
	if ((UNAUTHORIZED_ERROR == statusCode) && (receiverObject != nil)) {
		return NO;
	}
	
	// We assume that everythin between START_LOCATION_STATUS_CODE and START_FAVOURITE_STATUS_CODE is a location error code
	if ((6002 == statusCode)||((statusCode >= START_LOCATION_STATUS_CODE)&&(statusCode<START_FAVOURITE_STATUS_CODE))) {
		if ([receiverObject isKindOfClass:[IPhoneLocationInterface class]]) {
			// Considered an internal error: don't show it because it's intrusive since the user didn't do any action which could cause it.
			return NO;
		}
	}
	
	shouldExit = exit || !APP_SESSION.startupCompleted;
	
	if (self.internalAlertView) {
		[self.internalAlertView dismissWithClickedButtonIndex:10000 animated:YES];
		self.internalAlertView = nil;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	self.internalAlertView = alert;
	[alert release];
	
	switch (statusCode) {
		case 6001:
		case 6002:
			[self.internalAlertView setTag:statusCode];
			[self.internalAlertView setMessage:NSLocalizedStringWithDefaultValue(@"iPh_unnable_2_connect_txt", nil, [NSBundle mainBundle], @"Unable to connect to the network. To use Vodafone navigation you need to turn off the Wi-fi connection and have a working Vodafone SIM card. You also need to check your connection settings.", @"When Iphone client starts, network can fail. This may be due to the following three reasons: You are not a Vodafone customer, you are using Wi-Fi or there is another/real problem with the connection.")];
			[self.internalAlertView addButtonWithTitle:NSLocalizedStringWithDefaultValue(@"iPh_ok_tk", nil, [NSBundle mainBundle], @"OK", @"Touch key name (OK button in pop-up dialogue)")];
			[self.internalAlertView setCancelButtonIndex:0];	
			[self.internalAlertView show];	
			break;
		default:
			[self.internalAlertView setTag:statusCode];
			[self.internalAlertView setTitle:NSLocalizedStringWithDefaultValue(@"iPh_error_txt", nil, [NSBundle mainBundle], @"Error", @"Title for dialog when an error has occured")];
			[self.internalAlertView setMessage:[NSString stringWithUTF8String:status->getStatusMessage().c_str()]];
			break;
	}

*/	
	return YES;	
}

- (BOOL)displayWarningForStatus:(AsynchronousStatus *)status receiverObject:(id)object {
	return [self displayWarningForStatus:status receiverObject:object withExit:NO];
}

#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case 6001:
		case 6002:
			break;
		default:
			break;
	}
	
	if (alertView == self.internalAlertView) {
		// manual cancel of retrying to establish network connection
		if (!preserveInternalAlertView) {
			self.internalAlertView = nil;
			[self connectionStatusConnected:NO hasEverBeenConnected:YES];
			[self notifyRequestCancelled];
		}
	}
	else if (alertView.tag != 6001 && alertView.tag != 6002) {
		self.preserveInternalAlertView = NO;
		if (buttonIndex == 0) {
			[receiver performSelector:selector withObject:receiver];
		}
		else if (buttonIndex == 1) {
			[APP_SESSION.networkInterface removeNetworkStatusHandler:self];
			[self.internalAlertView dismissWithClickedButtonIndex:-1 animated:NO];
			if (shouldExit) {
				Terminate(101);
			}
			else {
				[self notifyRequestCancelled];
			}
		}
	}
}

- (void)notifyRequestCancelled {
	NSLog(@"Tell everybody waiting for the specific error, that the request has been cancelled!");
	for (NSNumber *errorCode in self.dialogForErrorCodes) {
		NSMutableDictionary *errorDict = [self.errorCodesForRequestOwners objectForKey:errorCode];
		if (errorDict != nil) {
			for (NSNumber *requestID in [errorDict keyEnumerator]) {
				IPhoneBaseInterface *baseInterface = [errorDict objectForKey:requestID];
				NSLog(@"ErrorHandler: cancelling request: %d", [requestID unsignedIntValue]);
				[baseInterface cancelRequestWithID:requestID];
			}
		}
		else {
			NSLog(@"ErrorHandler: Nothing to cancel...");
		}
		[self.errorCodesForRequestOwners removeObjectForKey:errorCode];
	}
	[self.dialogForErrorCodes removeAllObjects];
}

/*
 * Main entry point for error handling - this is where we decide what to do with which error codes.
 */
- (void)handleErrorWithStatus:(AsynchronousStatus *)status {
	[self handleErrorWithStatus:status onInterface:nil];
}

- (void)handleErrorWithStatus:(AsynchronousStatus *)status onInterface:(IPhoneBaseInterface *)baseInterface {
	wf_uint32 statusCode = status->getStatusCode();
	NSNumber *requestID = [NSNumber numberWithUnsignedInt:status->getRequestID().getID()];
	NSMutableDictionary *errorDict = [self.errorCodesForRequestOwners objectForKey:[NSNumber numberWithUnsignedInt:statusCode]];
	NSLog(@"ErrorHandler: Requested to handle error for request %d with error code: %d", [requestID unsignedIntValue], statusCode);
	if (errorDict == nil || [errorDict objectForKey:requestID] == nil) {
		if (baseInterface != nil) {
			NSLog(@"Adding interface to list...");
			[self addInterface:baseInterface withRequestID:requestID toErrorCode:[NSNumber numberWithUnsignedInt:statusCode]];
		}
		
		// we gotta start the billing flow...
		if (UNAUTHORIZED_ERROR == statusCode && (!startupProcessBegan)) {
			startupProcessBegan = YES;
			NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:status->getStatusURL().c_str()]];
			[APP_SESSION startNewAccountProcessWithURL:url];
		}
		// search error, that requires a network availabilty test before retrying
		else if (START_SEARCH_STATUS_CODE <= statusCode && START_ROUTE_STATUS_CODE > statusCode) {
			NSLog(@"ErrorHandler: Handling search error... (actually testing network connection, then retrying search request)");
			
			[APP_SESSION.networkInterface addNetworkStatusHandler:self];
			[APP_SESSION.networkInterface testServerConnection];
		}
		// network error
		else if (START_NETWORK_STATUS_CODE <= statusCode && START_TUNNEL_INTERFACE_STATUS_CODE > statusCode) {
			NSLog(@"ErrorHandler: Handling network error...");
			
			[APP_SESSION.networkInterface addNetworkStatusHandler:self];
			[APP_SESSION.networkInterface testServerConnection];
			[self showSpinnerWithTitle:@"Network lost - reconnecting..." andTag:status->getStatusCode() allowCancel:YES];
		}
	}
	else {
		NSLog(@"Ignoring error - same error has already been reported for this request!");
	}
}

- (void)showSpinnerWithTitle:(NSString *)title andTag:(NSInteger)tag allowCancel:(BOOL)allowCancel {
	if (self.internalAlertView != nil) {
		[self.internalAlertView dismissWithClickedButtonIndex:-1 animated:NO];
	}
	static NSString *msg = @" ";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:msg  
												   delegate:self 
										  cancelButtonTitle:(allowCancel ? [LocalizationHandler getString:@"iPh_cancel_tk"] : nil)
										  otherButtonTitles:nil];
	alert.tag = tag;
	self.internalAlertView = alert;
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(123, 45, 37, 37)];//ActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[spinner startAnimating];
	[alert addSubview:spinner];
	[alert show];
	[alert release];
	[spinner release];	
}

/*
 * This is where we store the information about the request related to the specific error code, so we will be able to retry it later
 * it looks like this (a dictionary within a dictionary):
 * - 4 (error code) -> NSMutableDictionary with data:
 *   - 25 (requestID) -> IPhoneFavouriteInterface (IPhoneBaseInterface)
 *   - 27 (requestID) -> IPhoneLocationInterface (IPhoneBaseInterface)
 * - 6001 (error code) -> NSMutableDictionary with data:
 *   - 31 (requestID) -> IPhoneNetworkInterface (IPhoneBaseInterface)
 *   - 37 (requestID) -> IPhoneRouteInterface (IPhoneBaseInterface)
 *
 */
- (void)addInterface:(IPhoneBaseInterface *)baseInterface withRequestID:(NSNumber *)requestID toErrorCode:(NSNumber *)errorCode {
	NSLog(@"ErrorHandler: Adding interface with requestID %d to error code: %d", [requestID unsignedIntValue], [errorCode unsignedIntValue]);
	NSMutableDictionary *errorDict = [self.errorCodesForRequestOwners objectForKey:errorCode];
	if (errorDict == nil) {
		errorDict = [[NSMutableDictionary alloc] init];
		[self.errorCodesForRequestOwners setObject:errorDict forKey:errorCode];
		[errorDict release];
	}
	[errorDict setObject:baseInterface forKey:requestID];
}

/*
 * This method finds all the requests that have reported a particular error code, and then retries them AND removes them from the collection/queue.
 */

- (void)retryAndRemoveRequestsThatFailedWithErrorCode:(NSNumber *)errorCode {
	NSLog(@"ErrorHandler: Retrying requests, that failed with error code: %d", [errorCode unsignedIntValue]);
	NSMutableDictionary *errorDict = [self.errorCodesForRequestOwners objectForKey:errorCode];
	if (errorDict != nil) {
		for (NSNumber *requestID in [errorDict keyEnumerator]) {
			IPhoneBaseInterface *baseInterface = [errorDict objectForKey:requestID];
			NSLog(@"ErrorHandler: retrying request: %d", [requestID unsignedIntValue]);
			[baseInterface retryRequestWithID:requestID];
		}
	}
	else {
		NSLog(@"ErrorHandler: Nothing to retry...");
	}
	[self.errorCodesForRequestOwners removeObjectForKey:errorCode];
}

/*
 * Callback from network handler with status whether we're connected or not...
 */
- (void)connectionStatusConnected:(BOOL)isConnected hasEverBeenConnected:(BOOL)hasEverBeenConnected {
	BOOL showRetryDialog = self.internalAlertView != nil;

	if (isConnected) {
		NSLog(@"ErrorHandler: yay - got connection...");
		// retry all requests that failed with network errors (6001-6003)
		[self retryAndRemoveRequestsThatFailedWithErrorCode:[NSNumber numberWithUnsignedInt:GENERAL_NETWORK_ERROR]];
		[self retryAndRemoveRequestsThatFailedWithErrorCode:[NSNumber numberWithUnsignedInt:NETWORK_TIMEOUT_ERROR]];
		[self retryAndRemoveRequestsThatFailedWithErrorCode:[NSNumber numberWithUnsignedInt:NETWORK_TRANSPORT_FAILED]];
		[self.internalAlertView dismissWithClickedButtonIndex:-1 animated:YES];
		self.internalAlertView = nil;
	}
	else {
		NSLog(@"ErrorHandler: not connected...");
		[self.dialogForErrorCodes addObject:[NSNumber numberWithUnsignedInt:GENERAL_NETWORK_ERROR]];
		[self.dialogForErrorCodes addObject:[NSNumber numberWithUnsignedInt:NETWORK_TIMEOUT_ERROR]];
		[self.dialogForErrorCodes addObject:[NSNumber numberWithUnsignedInt:NETWORK_TRANSPORT_FAILED]];
		if (showRetryDialog) {
			[self handleNetworkConnectionErrorWithExit:!hasEverBeenConnected];
		}
		else {
			[APP_SESSION.networkInterface removeNetworkStatusHandler:self];
		}
	}
}

/*
 * This is shown when there is a network error. If retry is selected, another testServerConnection is fired. Otherwise the action either leads to termination of the app or a cancellation of the request.
 */
- (void)handleNetworkConnectionErrorWithExit:(BOOL)exit {
	NSLog(@"ErrorHandler: showing network error dialog (with exit %@)...", (exit ? @"YES" : @"NO"));
	self.preserveInternalAlertView = YES;
	self.shouldExit = exit;
	receiver = APP_SESSION.networkInterface;
	selector = @selector(testServerConnection);
	NSString *otherButton = shouldExit ? [LocalizationHandler getString:@"[exit_button]"] : [LocalizationHandler getString:@"iPh_cancel_tk"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[LocalizationHandler getString:@"iPh_error_txt"]
													message:[LocalizationHandler getString:@"iPh_unnable_2_connect_txt"]
												   delegate:self
										  cancelButtonTitle:[LocalizationHandler getString:@"[retry_button]"] 
										  otherButtonTitles:otherButton, nil ];
	[alert show];
	[alert release];
}

- (void)showAlertWithTitle:(NSString*)title
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];

	[alertView setTitle:title];
	[alertView addButtonWithTitle:@"Ok"];
	[alertView setCancelButtonIndex:0];	
	[alertView show];	
	[alertView release];
}

static void ReallyTerminate_(CFRunLoopTimerRef timer, void *info) {
	int exitCode = EXIT_FAILURE;
	(void)CFNumberGetValue((CFNumberRef)info, kCFNumberIntType, &exitCode);
	if (exitCode == EXIT_SUCCESS)
		exitCode = ESHUTDOWN;
	
	exit(exitCode);
}

void Terminate(int code) {
	[UIView beginAnimations: @"ExitAnimation" context: NULL];
	[UIView setAnimationDuration: 1.0];
	CATransform3D t = CATransform3DScale(CATransform3DIdentity, 0.1, 0.1, 1.0);
	for (UIWindow *w in [UIApplication sharedApplication].windows) {
		w.layer.transform = t;
		w.layer.opacity = 0.0;
	}
	[UIView commitAnimations];
	
	CFNumberRef exitCode = CFNumberCreate(NULL, kCFNumberIntType, &code);
	if (exitCode) {
		CFRunLoopTimerContext ctx = {0, (void *)exitCode, &CFRetain, &CFRelease, &CFCopyDescription};
		CFRunLoopTimerRef t = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent() + 1.0, 0.0, kNilOptions, 0, &ReallyTerminate_, &ctx);
		if (t) {
			CFRunLoopAddTimer(CFRunLoopGetMain(), t, kCFRunLoopDefaultMode);
			CFRelease(t);
		}
		CFRelease(exitCode);
	}
}

@end



