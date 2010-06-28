/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "BorderedView.h"


@implementation BorderedView

@synthesize borders;

- (id)initWithFrame:(CGRect)aRect {
	if(self = [super initWithFrame:aRect]) {		
		self.borders = 0;
		//self.borders = North | South | East | West;	
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if(self = [super initWithCoder:decoder]) {		
		self.borders = 0;
		self.borders = North | South | East | West;	
	}
	return self;	
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if(self.borders != 0) {
		CGContextRef ctx = UIGraphicsGetCurrentContext(); 
		CGContextSetRGBStrokeColor(ctx, 0, 0, 0.75, 1); 
		
		if((self.borders & North) != 0) {		
			CGContextMoveToPoint(ctx, 0, 0);
			CGContextAddLineToPoint(ctx, self.frame.size.width, 0);
		}
		if((self.borders & South) != 0) {		
			CGContextMoveToPoint(ctx, 0, self.frame.size.height);
			CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
		}
		if((self.borders & East) != 0) {		
			CGContextMoveToPoint(ctx, self.frame.size.width,  0);
			CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
		}
		if((self.borders & West) != 0) {		
			CGContextMoveToPoint(ctx, 0,  0);
			CGContextAddLineToPoint(ctx, 0, self.frame.size.height);
		}
		
		CGContextStrokePath(ctx);	
	}
}	
@end
