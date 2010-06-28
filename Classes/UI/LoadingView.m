//
//  LoadingView.m
//  WFNavigation
//
//  Created by Andrei Vig on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"

static CGRect kLoadingViewFrame = {0.0, 0.0, 320.0, 480.0};
static CGRect kLoadingSpinnerFrame = {160.0, 200.0, 20.0, 20.0};

@implementation LoadingView


- (id)init {
	self = [super initWithFrame:kLoadingViewFrame];
	if (!self) return  nil;
	
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:kLoadingSpinnerFrame];
	[spinnerView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	
	[self addSubview:backgroundView];
	[self addSubview:spinnerView];
	[spinnerView startAnimating];
	
	[backgroundView release];
	[spinnerView release];
	
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
