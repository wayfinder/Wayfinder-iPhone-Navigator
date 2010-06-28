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

#import "NavigationHandler.h"
#import "LocationHandler.h"
#import "RouteHandler.h"

@interface NavigationViewController : UIViewController <NavigationHandler, LocationHandler, RouteHandler> {
	
	BOOL resumedNavigation;
	BOOL portrait;
	
	IBOutlet UIView *portraitView;
	IBOutlet UIView *landscapeView;
	
	IBOutlet UIView *streetNameView;
	IBOutlet UIView *streetNameViewLandscape;
	
	IBOutlet UIImageView *nextTurnIndicatorImageView;
	IBOutlet UILabel *nextTurnExitLabel;
	IBOutlet UILabel *nextTurnDistanceLabel;
	IBOutlet UILabel *nextTurnStreetNameLabel;
	IBOutlet UILabel *currentStreetNameLabel;	
	IBOutlet UILabel *timeLeftLable;
	IBOutlet UILabel *distanceLeftLabel;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *startStopToggleButton;	
	IBOutlet UIBarButtonItem *perspectiveToggleButton;	
	IBOutlet UIBarButtonItem *dayNightToggleButton;

	IBOutlet UIImageView *nextTurnIndicatorImageViewLandscape;
	IBOutlet UILabel *nextTurnExitLabelLandscape;	
	IBOutlet UILabel *nextTurnDistanceLabelLandscape;
	IBOutlet UILabel *nextTurnStreetNameLabelLandscape;
	IBOutlet UILabel *currentStreetNameLabelLandscape;	
	IBOutlet UILabel *timeLeftLableLandscape;
	IBOutlet UILabel *distanceLeftLabelLandscape;
	IBOutlet UIToolbar *toolbarLandscape;	
	IBOutlet UIBarButtonItem *startStopToggleButtonLandscape;	
	IBOutlet UIBarButtonItem *dayNightToggleButtonLandscape;
	IBOutlet UIBarButtonItem *perspectiveToggleButtonLandscape;
	
	// BEGIN Helper outlets for localization
	IBOutlet UILabel *timeLeftLiteralLabel;
	IBOutlet UILabel *timeLeftLiteralLabelLandscape;
	IBOutlet UILabel *distanceLeftLiteralLabel;
	IBOutlet UILabel *distanceLeftLiteralLabelLandscape;
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UIBarButtonItem *cancelButtonLandscape;
	
	CGPoint _viewPosCorrectionHackOffset;
	
	// END Helper outlets for localization
	
@private	
	
	BOOL is3DEnabled;
	BOOL hasSimulationBeenStarted;
	BOOL isSimulationEnabled;
	BOOL isNightViewEnabled;
	
	RouteAction lastAction;
	RouteCrossing lastRouteCrossing;
	BOOL lastLeftSideTraffic;
	BOOL lastHighWay;
	BOOL destinationReached;
}

@property (nonatomic, assign) BOOL resumedNavigation;
@property (nonatomic, assign) BOOL portrait;

@property (nonatomic, retain) UIView *streetNameView;
@property (nonatomic, retain) UIView *streetNameViewLandscape;

@property (nonatomic, retain) UIView *portraitView;
@property (nonatomic, retain) UIView *landscapeView;

@property (nonatomic, retain) UIImageView *nextTurnIndicatorImageView;
@property (nonatomic, retain) UILabel *nextTurnExitLabel;
@property (nonatomic, retain) UILabel *nextTurnDistanceLabel;
@property (nonatomic, retain) UILabel *nextTurnStreetNameLabel;
@property (nonatomic, retain) UILabel *currentStreetNameLabel;	
@property (nonatomic, retain) UILabel *timeLeftLable;
@property (nonatomic, retain) UILabel *distanceLeftLabel;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *startStopToggleButton;	
@property (nonatomic, retain) UIBarButtonItem *dayNightToggleButton;
@property (nonatomic, retain) UIBarButtonItem *perspectiveToggleButton;	

@property (nonatomic, retain) UIImageView *nextTurnIndicatorImageViewLandscape;
@property (nonatomic, retain) UILabel *nextTurnExitLabelLandscape;	
@property (nonatomic, retain) UILabel *nextTurnDistanceLabelLandscape;
@property (nonatomic, retain) UILabel *nextTurnStreetNameLabelLandscape;
@property (nonatomic, retain) UILabel *currentStreetNameLabelLandscape;	
@property (nonatomic, retain) UILabel *timeLeftLableLandscape;
@property (nonatomic, retain) UILabel *distanceLeftLabelLandscape;
@property (nonatomic, retain) UIToolbar *toolbarLandscape;
@property (nonatomic, retain) UIBarButtonItem *startStopToggleButtonLandscape;	
@property (nonatomic, retain) UIBarButtonItem *dayNightToggleButtonLandscape;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *perspectiveToggleButtonLandscape;

@property (nonatomic, retain)  UILabel *timeLeftLiteralLabel;
@property (nonatomic, retain)  UILabel *timeLeftLiteralLabelLandscape;
@property (nonatomic, retain)  UILabel *distanceLeftLiteralLabel;
@property (nonatomic, retain)  UILabel *distanceLeftLiteralLabelLandscape;
@property (nonatomic, retain)  UIBarButtonItem *cancelButton;
@property (nonatomic, retain)  UIBarButtonItem *cancelButtonLandscape;

@property (nonatomic) BOOL is3DEnabled;
@property (nonatomic) BOOL hasSimulationBeenStarted;
@property (nonatomic) BOOL isSimulationEnabled;
@property (nonatomic) BOOL isNightViewEnabled;

@property (nonatomic, assign) RouteAction lastAction;
@property (nonatomic, assign) RouteCrossing lastRouteCrossing;
@property (nonatomic, assign) BOOL lastLeftSideTraffic;
@property (nonatomic, assign) BOOL lastHighWay;
@property (nonatomic, assign) BOOL destinationReached;

- (IBAction)cancelNavigation:(id)sender;

- (IBAction)toggleMapsPerspective:(id) sender;

- (IBAction)toggleStartStopSimulation:(id)sender;

- (void)setViewPerspective:(BOOL)used3D;

- (void)toggleViewPerspective;

- (IBAction)toggleNightDay:(id)sender;

@end
