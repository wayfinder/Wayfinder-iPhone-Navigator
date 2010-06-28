/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "OverlayView.h"


@implementation OverlayView

@synthesize pulseView = _pulseView;
@synthesize indicatorPosition;
@synthesize indicatorType;
@synthesize indicator;

- (id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {	
		
		self.indicatorPosition = CGPointMake(0.0, 0.0);
		self.indicatorType = none;
		self.indicator = nil;
		
		_currentPositionGPSImage = [[UIImage imageNamed:@"CurrentPositionGPS.png"] retain];
		_navigationMarker2DImage = [[UIImage imageNamed:@"NavigationMarker2D.png"] retain];
		_navigationMarker3DImage = [[UIImage imageNamed:@"NavigationMarker3D.png"] retain];
		
		self.opaque = NO;
		self.multipleTouchEnabled = YES;
	}
	return self;
}

- (void)dealloc {
	self.indicator = nil;
	[_currentPositionGPSImage release];
	[_navigationMarker2DImage release];
	[_navigationMarker3DImage release];
	
	[_pulseView removeFromSuperview];
	[_pulseView release];
	
	[super dealloc];
}

- (void)setIndicatorType:(PositionIndicatorType)newValue {
	indicatorType = newValue;
	
	switch(indicatorType) {
		case currentPositionNonGPS: {
			// Not visualized by the class anymore.							
			break;
		}
		case currentPositionGPS: {
			self.indicator = _currentPositionGPSImage;							
			break;
		}
		case driving2D: {
			self.indicator = _navigationMarker2DImage;										
			break;
		}
		case driving3D: {
			self.indicator = _navigationMarker3DImage;
			break;			
		}
	}		
}

#pragma mark -
#pragma mark UIView Methods

- (void)drawRect:(CGRect)rect {
	CGPoint position = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);								
	
	UIImage *image = self.indicator;
	CGSize imageSize = image.size;
	
	if(self.indicatorType != none) {
		position = self.indicatorPosition;								
		
		if (currentPositionNonGPS == self.indicatorType) {
			if (!_pulseView) {
				_pulseView = [[PulseView alloc] initWithCenter:position];
				[self addSubview:_pulseView];
			}
			[_pulseView setCenter:position];
			[_pulseView setHidden:NO];
		} else {
			[_pulseView setHidden:YES];
			position.x -= imageSize.width / 2.0;
			position.y -= imageSize.height / 2.0;	
			[self.indicator drawAtPoint:position];			
		}				
	} else {
		[_pulseView setHidden:YES];
	}
}

- (void)setFrame:(CGRect)newValue {
	[super setFrame:newValue];
	
	NSLog(@"Overlay View frame set: (%f, %f) (%f, %f)", newValue.origin.x, newValue.origin.y, newValue.size.width, newValue.size.height);
}

#pragma mark -
#pragma mark UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	[self.nextResponder touchesCancelled:touches withEvent:event];
}

@end
