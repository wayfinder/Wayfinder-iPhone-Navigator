/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "OverlayItemDescriptionView.h"
#import "PlaceDetailViewController.h"
#import "OverlayInterface.h"
#import "WFNavigationAppDelegate.h"
#import "OverlayItemMapViewController.h"
#import "AppSession.h"
#import "Formatter.h"

#define FRAME_MAX_WIDTH		(300.0)
#define FRAME_HEIGHT		(50.0)
#define FRAME_BUFFER		(2.0)

#define FRAME_TAIL_WIDTH	(10.0)
#define FRAME_TAIL_HEIGHT	(10.0)

#define IMAGE_HEIGHT		(45.0)
#define IMAGE_WIDTH			(45.0)
#define IMAGE_PADDING		(2.0)

@implementation OverlayItemDescriptionView

@synthesize distanceLabel	= _distanceLabel;
@synthesize nameLabel		= _nameLabel;
@synthesize itemImage		= _itemImage;
@synthesize selectedObject	= _selectedObject;

- (id)initWithOverlayObject:(PlaceBase *)item center:(CGPoint)center target:(id)target selector:(SEL)selector shouldHideWhenTouchedOutside:(BOOL)shouldHideWhenTouchedOutside
{
	
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if (!self) return nil;
	
	_selectedObject = [item retain];

	_shouldHideWhenTouchedOutside = shouldHideWhenTouchedOutside;
	
	// get object information
	_image = [[ImageFactory getImageNamed:[item image]] retain];
	_title = [[item title] retain];
	if (-1 != item.distanceInMeters) {
		// It means this is a favourite
		_distance = [[Formatter formatDistance:item.distanceInMeters] retain];
	} else {
		_distance = [@"" retain];
	}
	
	// calculate frame dimensions and position
	CGSize titleSize = [_title sizeWithFont:[UIFont boldSystemFontOfSize:12]];
	CGSize distanceSize = [_distance sizeWithFont:[UIFont systemFontOfSize:12]];
//	CGRect screenFrame = frame;
	
	_width = MIN(MAX(titleSize.width, distanceSize.width) + IMAGE_WIDTH + 3 * FRAME_BUFFER, FRAME_MAX_WIDTH);
	_startX = round(center.x - _width / 2);
	_startY = round(center.y - FRAME_HEIGHT - FRAME_TAIL_HEIGHT / 2) - round(FRAME_HEIGHT / 2);
	
	// create image, title and distance frame
	_imageFrame = CGRectMake(_startX + FRAME_BUFFER + IMAGE_PADDING, 
							 _startY + FRAME_BUFFER + IMAGE_PADDING, 
							 IMAGE_WIDTH - IMAGE_PADDING, 
							 IMAGE_HEIGHT - IMAGE_PADDING);
	
	_titleFrame = CGRectMake(_startX + IMAGE_WIDTH + 3 * FRAME_BUFFER, 
							 _startY + FRAME_BUFFER, 
							 _width - IMAGE_WIDTH - 3 * FRAME_BUFFER, 
							 titleSize.height);
	
	_distanceFrame = CGRectMake(_startX + IMAGE_WIDTH + 3 * FRAME_BUFFER, 
								_startY + round(FRAME_HEIGHT / 2), 
								_width - IMAGE_WIDTH - 3 * FRAME_BUFFER, 
								distanceSize.height);
		
	// set background color to clear
	[self setBackgroundColor:[UIColor clearColor]];

	_nameLabel = [[UILabel alloc] initWithFrame:_titleFrame];
	[_nameLabel setTextColor:[UIColor whiteColor]];
	[_nameLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
	[_nameLabel setAdjustsFontSizeToFitWidth:NO];
	[_nameLabel setBackgroundColor:[UIColor clearColor]];
	[_nameLabel setText:_title];
	[self addSubview:_nameLabel];
	
	_distanceLabel = [[UILabel alloc] initWithFrame:_distanceFrame];
	[_distanceLabel setTextColor:[UIColor whiteColor]];
	[_distanceLabel setFont:[UIFont systemFontOfSize:10.0]];
	[_distanceLabel setAdjustsFontSizeToFitWidth:NO];
	[_distanceLabel setBackgroundColor:[UIColor clearColor]];
	[_distanceLabel setText:_distance];
	[self addSubview:_distanceLabel];
	
	_itemImage = [[UIImageView alloc] initWithFrame:_imageFrame];
	[_itemImage setBackgroundColor:[UIColor clearColor]];
	[_itemImage setImage:_image];
	[self addSubview:_itemImage];

	_descriptionView = [[UIView alloc] initWithFrame:CGRectMake(_startX, _startY, _width, FRAME_HEIGHT)];
	[_descriptionView setBackgroundColor:[UIColor clearColor]];
	[self addSubview:_descriptionView];
	
	[self setUserInteractionEnabled:NO];
	
    return self;
}

- (void)dealloc {
	[_selectedObject release];
	
	[_descriptionView release];
	[_nameLabel release];
	[_distanceLabel release];
	[_itemImage release];
	
	[_title release];
	[_distance release];
	[_image release];
	
	[super dealloc];
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
		
	CGContextMoveToPoint(context, _startX, _startY);
	CGContextAddLineToPoint(context, _startX + _width, _startY);
	CGContextAddLineToPoint(context, _startX + _width, _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX + round(_width / 2) + round(FRAME_TAIL_WIDTH / 2), _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX + round(_width / 2), _startY + FRAME_HEIGHT + FRAME_TAIL_HEIGHT);
	CGContextAddLineToPoint(context, _startX + round(_width / 2) - round(FRAME_TAIL_WIDTH / 2), _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX, _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX, _startY);

	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.0 green:0.36 blue:0.63 alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 2.0);
	CGContextStrokePath(context);

	CGContextMoveToPoint(context, _startX, _startY);
	CGContextAddLineToPoint(context, _startX + _width, _startY);
	CGContextAddLineToPoint(context, _startX + _width, _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX + round(_width / 2) + round(FRAME_TAIL_WIDTH / 2), _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX + round(_width / 2), _startY + FRAME_HEIGHT + FRAME_TAIL_HEIGHT);
	CGContextAddLineToPoint(context, _startX + round(_width / 2) - round(FRAME_TAIL_WIDTH / 2), _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX, _startY + FRAME_HEIGHT);
	CGContextAddLineToPoint(context, _startX, _startY);
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.0 green:0.52 blue:0.82 alpha:1.0] CGColor]);
	CGContextFillRect(context, CGRectMake(_startX + FRAME_BUFFER, 
										  _startY + FRAME_BUFFER, 
										  _width - 2 * FRAME_BUFFER, 
										  round(FRAME_HEIGHT / 2) - FRAME_BUFFER));
	
	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.0 green:0.36 blue:0.63 alpha:1.0] CGColor]);
	CGContextFillRect(context, CGRectMake(_startX + FRAME_BUFFER, 
										  _startY + round(FRAME_HEIGHT / 2), 
										  _width - 2 * FRAME_BUFFER, 
										  round(FRAME_HEIGHT / 2) - FRAME_BUFFER));
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] == 1) {
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		CGPoint touchPoint = [touch locationInView:_descriptionView];
		
		if (_shouldHideWhenTouchedOutside) {
			if ([_descriptionView pointInside:touchPoint withEvent:event]) {
				
				WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
				// huge hack but no time to fix this the normal way
				if (![appDelegate.navController.topViewController isKindOfClass:[OverlayItemMapViewController class]]) {
				
					PlaceDetailViewController *pdc = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
					pdc.place = _selectedObject;
					
					if ([_selectedObject isKindOfClass:[SearchResult class]]) {
						[APP_SESSION.searchInterface getDetailsForResultWithID:((SearchResult *)_selectedObject).resultID andSetSearchHandler:pdc];
					}
					
					WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController *ctrl = appDelegate.navController;
					
					[ctrl pushViewController:pdc animated:YES];
					[pdc release];
				}
			} else {
				[self setHidden:YES];
				[[self nextResponder] touchesBegan:touches withEvent:event];
			}
		} else {
			[[self nextResponder] touchesBegan:touches withEvent:event];
		}
	} else {
		[[self nextResponder] touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {	
	[[self nextResponder] touchesCancelled:touches withEvent:event];
}


@end
