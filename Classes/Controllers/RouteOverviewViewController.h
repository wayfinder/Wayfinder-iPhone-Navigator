/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIKit.h>

#import "RouteHandler.h"
#import "LocationHandler.h"
#import "SearchItem.h"
#import "PlaceBase.h"
#import "BusyViewController.h"

@interface RouteOverviewViewController : UIViewController <RouteHandler, LocationHandler, UIAlertViewDelegate> {	
	
	UIBarButtonItem *homeTabBarItem;
	UIBarButtonItem *navigateStartTabBarItem;
	UIBarButtonItem *settingsTabBarItem;
	UILabel *estimatedTimeLiteralLabel;
	UILabel *estimatedTimeLabel;
	UILabel *distanceLiteralLabel;
	UILabel *distanceLabel;
	
	BusyViewController *busyViewController;
	PlaceBase *place;
	NSString *selectionStr;																
	NSString *productId;
	BOOL newSubscriptionRequired;
	
	UIAlertView *_waitForGPSAlert;
	NSTimer *_checkGPSSignalTimer;
	
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *homeTabBarItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *navigateStartTabBarItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsTabBarItem;
@property (nonatomic, retain) IBOutlet UILabel *estimatedTimeLiteralLabel;
@property (nonatomic, retain) IBOutlet UILabel *estimatedTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLiteralLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;

@property (nonatomic, retain) BusyViewController *busyViewController;

@property (nonatomic, retain) PlaceBase *place;
@property (nonatomic, retain) NSString *selectionStr;																
@property (nonatomic, retain) NSString *productId;
@property (nonatomic, assign) BOOL newSubscriptionRequired;

- (IBAction)homeButtonPressed:(id)sender;

- (IBAction)startNavigationButtonPressed:(id)sender;

- (IBAction)settingButtonPressed:(id)sender;

- (void)checkGPSSignal;

@end
