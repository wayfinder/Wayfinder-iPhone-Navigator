/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PulseView.h"
#import "AppSession.h"
#import <CoreGraphics/CoreGraphics.h>
#include "TargetConditionals.h"

#define	TIME_FREQUENCY		(0.1)
#define PULSE_FREQUENCY		(3)
#define PULSE_START_RADIUS	(0.0)
#define PULSE_MAX_RADIUS	(30.0)

#define PULSE_ALPHA			(0.4)

#define LOW_QUALITY_GPS_RADIUS		(300.0)
#define MEDIUM_QUALITY_GPS_RADIUS	(50.0)
#define HIGH_QUALITY_GPS_RADIUS		(5.0)

@implementation PulseView

- (id)initWithCenter:(CGPoint)center {

	_quality = WFAPI::QUALITY_DESCENT;
	
	float initialRadius = LOW_QUALITY_GPS_RADIUS;
	CGRect frame = CGRectMake(center.x - initialRadius, center.y - initialRadius, 2 * initialRadius, 2 * initialRadius);
	
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	_radius = initialRadius;
	_pulseRadius = PULSE_START_RADIUS;
	_pulseAlpha = PULSE_ALPHA;
	_center = center;
	
	_pulseTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_FREQUENCY target:self selector:@selector(pulse) userInfo:nil repeats:YES];
	
	[self setUserInteractionEnabled:NO];
	
	[self setBackgroundColor:[UIColor clearColor]];
	return self;
}

- (void)dealloc {
	[_pulseTimer invalidate];
	CGLayerRelease(_pulseLayer);
    [super dealloc];
}

- (CGLayerRef)createPulseLayerUsingContext:(CGContextRef)context {
	CGLayerRef pulseLayer = CGLayerCreateWithContext(context, CGSizeMake(2 * _radius, 2 * _radius), NULL);
	CGContextRef layerContext = CGLayerGetContext(pulseLayer);
	
	CGContextSetAllowsAntialiasing(layerContext, true);
	CGContextSetShouldAntialias(layerContext, true);
	
	CGContextSetFillColorWithColor(layerContext, [[UIColor whiteColor] CGColor]);
	CGContextSetStrokeColorWithColor(layerContext, [[UIColor whiteColor] CGColor]);
	
	CGContextSetLineWidth(layerContext, 5.0);
	CGContextAddEllipseInRect(layerContext, CGRectMake(3.0, 3.0, 2 *_radius - 6.0, 2 * _radius - 6.0));
	CGContextStrokePath(layerContext);
	
	CGContextSetLineWidth(layerContext, 2.0);
	CGContextAddEllipseInRect(layerContext, CGRectMake(3.0, 3.0, 2 *_radius - 6.0, 2 * _radius - 6.0));
	CGContextStrokePath(layerContext);
	
	CGContextAddEllipseInRect(layerContext, CGRectMake(3.0, 3.0, 2 *_radius - 6.0, 2 * _radius - 6.0));
	CGContextFillPath(layerContext);
	
	return pulseLayer;
}

- (CGLayerRef)createQualityLayerUsingContext:(CGContextRef)context {
	float qualityRadius = [self radiusForQuality:_quality];
	CGLayerRef qualityLayer = CGLayerCreateWithContext(context, CGSizeMake(2 * qualityRadius, 2 * qualityRadius), NULL);
	CGContextRef layerContext = CGLayerGetContext(qualityLayer); 
	
	CGContextSetAllowsAntialiasing(layerContext, true);
	CGContextSetShouldAntialias(layerContext, true);
	
	CGContextSetAlpha(layerContext, 0.5);
	CGContextSetStrokeColorWithColor(layerContext, [[UIColor blueColor] CGColor]);
	CGContextSetLineWidth(layerContext, 2.0);
	CGContextAddEllipseInRect(layerContext, CGRectMake(3.0, 3.0, 2 *qualityRadius - 6.0, 2 * qualityRadius - 6.0));
	CGContextStrokePath(layerContext);

	CGContextSetAlpha(layerContext, 0.2);
	CGContextSetFillColorWithColor(layerContext, [[UIColor blueColor] CGColor]);
	CGContextAddEllipseInRect(layerContext, CGRectMake(3.0, 3.0, 2 * qualityRadius - 6.0, 2 * qualityRadius - 6.0));
	CGContextFillPath(layerContext);
	
	return qualityLayer;
}

- (void)setQuality:(WFAPI::GpsQualityEnum)quality {
	if (_quality != quality) {
		_quality = quality;
		CGLayerRelease(_qualityLayer);
		[self setNeedsDisplay];
	}
}

- (float)radiusForQuality:(WFAPI::GpsQualityEnum)quality {
	float radius = 0.0;
	switch (quality) {
		case WFAPI::QUALITY_POOR:
			radius = LOW_QUALITY_GPS_RADIUS;
			break;
		case WFAPI::QUALITY_DESCENT:
			radius = MEDIUM_QUALITY_GPS_RADIUS;
			break;
		case WFAPI::QUALITY_EXCELLENT:
			radius = HIGH_QUALITY_GPS_RADIUS;
			break;
		default:
			radius = HIGH_QUALITY_GPS_RADIUS;
			break;
	}
	
	return radius;
}

- (void)pulse {
	_pulseRadius+=PULSE_FREQUENCY;
	_pulseAlpha-= 0.01;	
	if (_pulseRadius > [self radiusForQuality:_quality]) {
		_pulseRadius = PULSE_START_RADIUS;
		_pulseAlpha = PULSE_ALPHA;
	}
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetShouldAntialias(context, true);
	
	if (!_pulseLayer) {
		_pulseLayer = [self createPulseLayerUsingContext:context];
	}
	
	if (!_qualityLayer) {
		_qualityLayer = [self createQualityLayerUsingContext:context];
	}
	
	// get zoom level
	MapOperationInterface *mapOperationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();
	double zoomLevel = mapOperationInterface->getZoomLevel();
	
	
	float qualityRadius = [self radiusForQuality:_quality] * 20 / zoomLevel;
	qualityRadius = (qualityRadius < 10) ? 10 : qualityRadius;
	qualityRadius = (qualityRadius > 300) ? 300 : qualityRadius;
	
	float pulseRadius = _pulseRadius * 20 / zoomLevel;
	pulseRadius = (pulseRadius > 300) ? 300 : pulseRadius;
	
	CGRect qualityRect = CGRectMake(_radius - qualityRadius, _radius - qualityRadius, 2 * qualityRadius, 2 * qualityRadius);
	CGRect pulseRect = CGRectMake(_radius - pulseRadius, _radius - pulseRadius, 2 * pulseRadius, 2 * pulseRadius);
	
#ifdef TARGET_IPHONE_SIMULATOR
	//the simulator does not like a small pulseRect when out of map coverage
	if(pulseRect.size.width < 1) {
		//NSLog(@"Skipping a drawRect() call");
		return;
	}
#endif
	CGContextDrawLayerInRect(context, qualityRect, _qualityLayer);
	CGContextSetAlpha(context, _pulseAlpha);
	CGContextDrawLayerInRect(context, pulseRect, _pulseLayer);
	
}

#pragma mark -
#pragma mark UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {	
	[self.nextResponder touchesCancelled:touches withEvent:event];
}

@end
