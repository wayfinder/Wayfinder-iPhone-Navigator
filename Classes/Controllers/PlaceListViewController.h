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
#import "PlaceDataChangeListener.h"
#import "PlaceDataSource.h"
#import "LocationHandler.h"
#import "ImageHandler.h"
#import "SearchQuery.h"
#import "CategoryTableViewController.h"
#import "CountryTableViewController.h"
#import "GeocodingHandler.h"
#import "OverlayLayer.h"

#define SEGMENT_MAP  0
#define SEGMENT_LIST 1

@interface PlaceListViewController : UIViewController <GeocodingHandler, LocationHandler, ImageHandler, PlaceDataChangeListener, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	IBOutlet UIToolbar *bottomBar;
	
	PlaceDataSource *placeDataSource;
//	OverlayLayer *mapLayer;
	
	IBOutlet UISegmentedControl *resultDisplayType;
	UIViewController *contentViewController;
	UIViewController *busyViewController;
	UITableViewController *placeTableViewController;
	CategoryTableViewController *categoryTableViewController;
	CountryTableViewController *countryTableViewController;
	IBOutlet UIView *contentView;
	IBOutlet UIBarButtonItem *myPositionButton;
	BOOL _controllerDissapearedToTheLeft; // Set this variable to YES whenever you stack another view upon this controller's view

@private
	wf_uint32 requestID;
	NSMutableArray *results;
	NSArray *sortedResults;
	BOOL aroundMeStyle;
	BOOL resultsReady;
	BOOL addressMode;
	BOOL firstTime;
	BOOL viewVisible;	
}

@property (nonatomic, retain) UIToolbar *bottomBar;

@property (nonatomic, retain) PlaceDataSource *placeDataSource;
@property (nonatomic, retain) UISegmentedControl *resultDisplayType;
@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, retain) UIViewController *busyViewController;
@property (nonatomic, retain) UITableViewController *placeTableViewController;
@property (nonatomic, retain) CategoryTableViewController *categoryTableViewController;
@property (nonatomic, retain) CountryTableViewController *countryTableViewController;
@property (nonatomic, retain) UIView *contentView;

@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSArray *sortedResults;

@property (nonatomic, assign) BOOL addressMode;
@property (nonatomic, assign) BOOL viewVisible;
@property (nonatomic, assign) BOOL firstTime;

//@property (nonatomic, retain) OverlayLayer *mapLayer;

- (void)registerPlaceDataSource:(PlaceDataSource *)pdc;

- (IBAction)segmentedControlHandler:(id)sender;

- (void)refreshResultsDisplays;

- (void)loadingStarted;

- (void)setUseAroundMeStyle:(BOOL)useAroundMeStyle;

- (void)addMyPositionButton;
- (void)removeMyPositionButton;

- (void)showRouteOverviewForPlace:(PlaceBase *)place;

//- (void)setMapProperties;

@end
