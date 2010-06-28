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
#import "SearchHandler.h"
#import "FavouriteHandler.h"
#import "PlaceDetailOwner.h"
#import "PlaceBase.h"
#import "OverlayLayer.h"

@interface PlaceDetailViewController : UIViewController <SearchHandler, 
														 FavouriteHandler, 
														 PlaceDetailOwner, 
														 UITableViewDelegate, 
														 UITableViewDataSource, 
														 UITabBarDelegate,
														 UIAlertViewDelegate> {
	
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UITableView *headerTableView;
	UITableViewCell *headerTableViewCell;
	IBOutlet UITableView *footerTableView;
	IBOutlet UITableViewCell *footerTableViewCell;
	IBOutlet UIView *headerView;
	IBOutlet UIView *footerView;
	IBOutlet UITableView *detailsTableView;
	IBOutlet UITabBar *tabs;
	IBOutlet UITabBar *altTabs;
	IBOutlet UIImageView *placeImageView;
	IBOutlet UILabel *placeName;
	IBOutlet UILabel *placeDistance;
	IBOutlet UILabel *placeDescription;
	IBOutlet UILabel *placeDescriptionEdit;
	BOOL _controllerDissapearedToTheLeft;// Set this variable to YES whenever you stack another view upon this controller's view
		
	PlaceBase *place;
	BOOL detailsFetched;
	BOOL editingName;
															 
	UIAlertView *gpsSignalAlertView;
	BOOL waitingForGpsSignal;
}

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UITableView *headerTableView;
@property (nonatomic, retain) UITableViewCell *headerTableViewCell;
@property (nonatomic, retain) UITableView *footerTableView;
@property (nonatomic, retain) UITableViewCell *footerTableViewCell;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UITableView *detailsTableView;
@property (nonatomic, retain) UITabBar *tabs;
@property (nonatomic, retain) UITabBar *altTabs;
@property (nonatomic, retain) UIImageView *placeImageView;
@property (nonatomic, retain) UILabel *placeName;
@property (nonatomic, retain) UILabel *placeDistance;
@property (nonatomic, retain) UILabel *placeDescription;
@property (nonatomic, retain) UILabel *placeDescriptionEdit;

@property (nonatomic, retain) PlaceBase *place;
@property (nonatomic, assign) BOOL detailsFetched;

@property (nonatomic, retain) UIAlertView *gpsSignalAlertView;
@property (nonatomic, assign) BOOL waitingForGpsSignal;

- (void)refreshView;

- (void)logSearchItem:(SearchItem *)item;

- (void)editClicked:(id)sender;

@end
