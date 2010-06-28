/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "AppSession.h"
#import "OpenGLCommon.h"

#import "EAGLView.h"
#import "MapLibAPI.h"
#import "MapOperationInterface.h"
#import "WGS84Coordinate.h"
#import "ScreenPoint.h"
#import "MapObjectInfo.h"
#import "OverlayItemZoomSpec.h"
#import "OverlayView.h"
#import "OverlayItemDescriptionView.h"
#import "ConfigInterface.h"
#import "DetailedConfigInterface.h"
#import "MapDrawingInterface.h"
#import "MapLibKeyInterface.h"
#import "ErrorHandler.h"
#import "MapOperationInterface.h"

using namespace WFAPI;

#define USE_DEPTH_BUFFER 0

@implementation EAGLView

@synthesize backingWidth;
@synthesize backingHeight;

//@synthesize context;
//@synthesize depthRenderbuffer;
@synthesize glDrawer;

@synthesize initialTouchLocation;
@synthesize startingDistance;
@synthesize lastTouchDistance;
@synthesize numTouches;

@synthesize overlayView;
@synthesize descriptionView = _descriptionView;

@synthesize needsToSetWorldBox;
@synthesize needsToSetUsersPosition;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

// Perform the initialization of Nav2Lib MapLib
- (void)initialize {
	depthRenderbuffer = 0;
	viewFramebuffer = 0;
	viewRenderbuffer = 0;
	glDrawer = nil;
	
	overlayView = nil;
	_descriptionView = nil;
		
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;	
	eaglLayer.opaque = YES;	
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO],
									kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8,
									kEAGLDrawablePropertyColorFormat, 
									nil
									];
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

	if(!context || ![EAGLContext setCurrentContext:context]) {
		[self release];
		return;
	}
	
	self.panningEnabled = YES;
	self.zoomingEnabled = YES;	
	
	self.centerUserPosition = YES;
	self.angle = 0.0;
	self.use3DMap = NO;
	self.zoomLevel = 1;
	self.indicatorType = none;
	if (APP_SESSION == nil) {
		self.usersPosition = WGS84Coordinate(180.0, 180.0);
	}
	else {
		self.usersPosition = APP_SESSION.locationManager->currentPosition;//WGS84Coordinate(180.0, 180.0);
	}
	self.mapsCenter = usersPosition;
	
	needsToSetWorldBox = NO;
	needsToSetUsersPosition = NO;
}

- (id)initWithFrame:(CGRect)rect {
    if(self = [super initWithFrame:rect]) {
		[self initialize];
    }
    return self;	
}

- (void)addOverlayView {
	CGRect frame = [self frame];
	
	if (nil == overlayView) {
		OverlayView *overlay = [[OverlayView alloc] initWithFrame:frame];
		
		[self addSubview:overlay];

		self.overlayView = overlay;
		[overlay release];
	}

	[self.overlayView setFrame:frame];
}


-(void)drawRect:(CGRect)rect {   
	
    // Once we have created a frame buffer, we clear the screen so that we
    // do not see any old content by mistake.
    [EAGLContext setCurrentContext:context];
    
    glViewport(0, 0, backingWidth, backingHeight);
	
	glDrawer->setScreenSize(backingWidth, backingHeight);
	
	// Apply transforms only after setting the map dimensions on screen
	[self applyRequestedTransformsToMap];
	
	// This function is called whenever the window needs to be repainted.
	// MapLib will invalidate the window when it has drawn a map, triggering
	// a repaint. If the application writer wants to draw any OpenGL ES
	// content on top of the map, this is the place to do it.
		
	if(APP_SESSION.mapLibAPI != nil) {	
		
		ScreenPoint point = [self worldToScreen:usersPosition];
		[self.overlayView setIndicatorPosition:CGPointMake(point.getX(), point.getY())];
		
		if (_descriptionView != nil) {
			ScreenPoint itemScreenPoint = [self worldToScreen:_descriptionView.selectedObject->position];
			[self.descriptionView setCenter:CGPointMake(itemScreenPoint.getX(), itemScreenPoint.getY())];
		}
		
		[self.overlayView setNeedsDisplay];
	}
	
	// When we are ready with our custom drawing (if any) we need to swap
	// the buffer. The buffer to swap needs to be the same as the one supplied
	// to IPWFSession.
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)drawView {
	[self drawRect:[self bounds]];
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
//    [self destroyFramebuffer];
    [self createFramebufferIfNeeded];
    [self drawView];
}

// TODO(Fabian): method needs a proper name
- (BOOL)createFramebufferIfNeeded
{
	bool shouldBackingBufferBeCreated = false;
	// Create the renderbuffer/framebuffer once
	if (0 == viewFramebuffer) {
		shouldBackingBufferBeCreated = true;
		
		glGenFramebuffersOES(1, &viewFramebuffer);
		glGenRenderbuffersOES(1, &viewRenderbuffer);
		
		if (USE_DEPTH_BUFFER) {
			glGenRenderbuffersOES(1, &depthRenderbuffer);
			glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
			glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
			glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
		}
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

	if (shouldBackingBufferBeCreated) {
		if (![context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer]) {
			NSLog(@"! renderbufferStorage failed !");
		}
		
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
		if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
			NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
			return NO;
		}
	}
    
    // Once we have created a frame buffer, we clear the screen so that we
    // do not see any old content by mistake.
    [EAGLContext setCurrentContext:context];
    
    glViewport(0, 0, backingWidth, backingHeight);
	
    glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );
    glClear (GL_COLOR_BUFFER_BIT);
    
	[self initMapDrawer];
	
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"sessionloadingFinished" object:nil];
	
    return YES;
}

- (void)initMapDrawer {
	if(glDrawer) {
		// If we've already created an OpenGL ES based renderer, we only
		// need to update its context.
		
		// In fact, no variable values change. We could also not update at all the glDrawer.
		
		glDrawer->updateContext(viewRenderbuffer, viewFramebuffer, context);
	}
	else {
//		if(APP_SESSION.glDrawer) {
//			delete APP_SESSION.glDrawer;
//		}
		// If we have not created an OpenGL ES based drawer at this time,
		// we do so using the supplied render and frame buffers
		glDrawer = new IPhoneOpenGLESDrawer(self, viewRenderbuffer, viewFramebuffer, context);
		
		if(APP_SESSION.mapLibAPI != nil) {
			APP_SESSION.mapLibAPI->setDrawingContext(glDrawer->getDrawingContext());
		}
	}
	
	glDrawer->setScreenSize(backingWidth, backingHeight);

	[self setAngle:0];
	[self setMapsCenter:mapsCenter];
	
	// Apply transforms only after setting the map dimensions on screen
	[self applyRequestedTransformsToMap];
}

- (void)destroyFramebuffer {
    
	if (viewFramebuffer > 0) {
		glDeleteFramebuffersOES(1, &viewFramebuffer);
		viewFramebuffer = 0;
		glDeleteRenderbuffersOES(1, &viewRenderbuffer);
		viewRenderbuffer = 0;
	}
	
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)dealloc {
	// Normally, the EAGLView will not be dealloced during the app lifetime because of some internal caches from the core which need these buffers no to be recreated.
	[self removeFromSuperview];
	
	[_descriptionView removeFromSuperview];
	[_descriptionView release];
	
	[overlayView removeFromSuperview];
	[overlayView release];
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:nil];
	
	APP_SESSION.mapLibAPI->setDrawingContext(NULL);
	[self destroyFramebuffer];
    if([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
	
	delete glDrawer;
	
    [context release];
    context = nil;
	
    [super dealloc];
}

- (MapConfiguration)getMapConfiguration {
	MapConfiguration conf;
	conf.usersPosition = usersPosition;
	conf.mapsCenter = mapsCenter;
	conf.angle = self.angle;
	conf.centerUserPosition = self.centerUserPosition;
	conf.use3DMap = self.use3DMap;
	conf.zoomLevel = self.zoomLevel;
	conf.indicatorType = self.indicatorType;
	return conf;
}

- (void)setMapConfiguration:(MapConfiguration)conf {
	self.usersPosition = conf.usersPosition;
	self.mapsCenter = conf.mapsCenter;
	self.angle = conf.angle;
	self.centerUserPosition = conf.centerUserPosition;
	self.use3DMap = conf.use3DMap;
	self.zoomLevel = conf.zoomLevel;
	self.indicatorType = conf.indicatorType;	
}

+ (MapConfiguration)getDefaultMapConfiguration {
	MapConfiguration conf;
	conf.usersPosition = WGS84Coordinate(180.0, 180.0);
	conf.mapsCenter = conf.usersPosition;
	conf.angle = 0.0;
	conf.centerUserPosition = YES;
	conf.use3DMap = NO;
	conf.zoomLevel = 10.0;
	conf.indicatorType = none;
	
	return conf;
}

#pragma mark -
#pragma mark Getter and setter Methods

- (void)setNeedsSetWorldBoxToFirstCoord:(WGS84Coordinate)firstCoord secondCoord:(WGS84Coordinate)secondCoord
{
	needsToSetWorldBox = YES;
	worldBoxFirstCoord = firstCoord;
	worldBoxSecondCoord = secondCoord;
}

- (WGS84Coordinate)usersPosition {
	return usersPosition;
}

- (void)setUsersPosition:(WGS84Coordinate)newValue {
	usersPosition = newValue;
	if(self.centerUserPosition) {
		self.mapsCenter = usersPosition;
	}
		
	if(APP_SESSION.mapLibAPI != nil) {
		ScreenPoint point = [self worldToScreen:usersPosition];
		[overlayView setIndicatorPosition:CGPointMake(point.getX(), point.getY())];
		
		// Could be optimized so a repaint only is done if necessary!
		MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();			
		mapDrawingInterface->requestRepaint();				
	}
}

- (void)setNeedsSetUsersPosition:(WGS84Coordinate)newValue {
	neededUsersPosition = newValue;
	needsToSetUsersPosition = YES;
}

- (WGS84Coordinate)mapsCenter {
	return mapsCenter;
}

- (void)setMapsCenter:(WGS84Coordinate)newValue {
	mapsCenter = newValue;
	
	if(APP_SESSION.mapLibAPI != nil) {	
		MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();	
		operationInterface->setCenter(mapsCenter);	
		
		// Could be optimized so a repaint only is done if necessary!
		MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();	
		mapDrawingInterface->requestRepaint();	
		
		if((usersPosition.latDeg != mapsCenter.latDeg) || (usersPosition.lonDeg != mapsCenter.lonDeg) ) {
			centerUserPosition = NO;
		}
	}
}

- (double)angle {
	return angle;
}

- (void)setAngle:(double)newValue {
	angle = newValue;
	
	if(APP_SESSION.mapLibAPI != nil) {	
		MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();
		operationInterface->setAngle(self.angle);	
	}	
}

- (BOOL)panningEnabled {
	return panningEnabled;
}

- (void)setPanningEnabled:(BOOL)newValue {
	if(newValue && (self.indicatorType == driving3D || self.indicatorType == driving2D)) {
		return;
	}
	
	panningEnabled = newValue;
}

- (BOOL)zoomingEnabled {
	return zoomingEnabled;
}

- (void)setZoomingEnabled:(BOOL)newValue {
	if(newValue && (self.indicatorType == driving3D || self.indicatorType == driving2D)) {
		return;
	}
	
	zoomingEnabled = newValue;
}

- (BOOL)centerUserPosition {
	return centerUserPosition;
}

- (void)setCenterUserPosition:(BOOL)newValue {
	centerUserPosition = newValue;

	if(self.centerUserPosition) {
		self.mapsCenter = usersPosition;	
	}
	
	if(APP_SESSION.mapLibAPI != nil) {	
		MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();	
		operationInterface->setAngle(0);
	}
}

- (BOOL)use3DMap {
	return use3DMap;
}

- (void)setUse3DMap:(BOOL)newValue {
	use3DMap = newValue;
	if(self.use3DMap) {
		self.indicatorType = driving3D;
	}
	else {
		if(APP_SESSION.mapLibAPI !=nil) {		
			ConfigInterface *configInterface = APP_SESSION.mapLibAPI->getConfigInterface();
			configInterface->set3dMode(NO);	
		}
	}
}

- (double)zoomLevel {
	return zoomLevel;
}

- (void)setZoomLevel:(double)newValue {
	if(0 < newValue  && newValue < MAX_ZOOM_LEVEL) {
		zoomLevel = newValue;
		
		if(APP_SESSION.mapLibAPI != nil) {
			MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();	
			operationInterface->setZoomLevel(newValue);			
		}
	}
}

- (PositionIndicatorType)indicatorType {
	return indicatorType;
}

- (void)setIndicatorType:(PositionIndicatorType)newValue {
	if(!(self.use3DMap && newValue != driving3D)) {
		indicatorType = newValue;

		[overlayView setIndicatorType:self.indicatorType];		

		if(APP_SESSION.mapLibAPI !=nil) {		
			ConfigInterface *configInterface = APP_SESSION.mapLibAPI->getConfigInterface();
			configInterface->set3dMode(self.use3DMap);	
			// TODO: WFAPI::DetailedConfigInterface::set3dHorizonHeight is not yet implemented by the CoreLib.
			// We need to find another way of adjusting the height of the horizon
			// DetailedConfigInterface *detailedConfigInterface = configInterface->getDetailedConfigInterface();
			// detailedConfigInterface->set3dHorizonHeight(100);// (self.frame.size.height / 3) * 2);
		}
	}
}

- (void)showDescriptionForItem:(PlaceBase *)item withTarget:(id)target selector:(SEL)selector {
	if (_descriptionView) {
		[_descriptionView removeFromSuperview];
		[_descriptionView release];
	}
	
	CGRect visibleZoneFromOverlay = CGRectMake(0, 0, backingWidth, backingHeight);
	_descriptionView = [[OverlayItemDescriptionView alloc] initWithOverlayObject:item center:CGPointMake(backingWidth/2, (RENDERBUFFER_MAX_Y-backingHeight)+backingHeight/2) target:target selector:selector shouldHideWhenTouchedOutside:NO];
	[overlayView addSubview:_descriptionView];
}

- (void)relocateCopyrightMessageAtTop:(BOOL)top andOffset:(int)offset {
	DetailedConfigInterface *detailedConfigInterface = APP_SESSION.mapLibAPI->getConfigInterface()->getDetailedConfigInterface();
	int xpos = top ? 0 : 6;
	int ypos = top ? 0 : ((int)APP_SESSION.glView.frame.size.height);
	ScreenPoint position(xpos,  ypos + offset);
	detailedConfigInterface->setCopyrightPos(position);
}


#pragma mark -
#pragma mark UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([touches count] == 1) {
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		
		initialTouchLocation = [touch locationInView:self];
		CGPoint loc = [touch locationInView:self];
		
		if(APP_SESSION.mapLibAPI != nil) {
			MapLibKeyInterface* keyInterface = APP_SESSION.mapLibAPI->getKeyInterface();
			keyInterface->handlePointerEvent(MapLibKeyInterface::DRAG_TO,
											 MapLibKeyInterface::POINTER_DOWN_EVENT,
											 [self transformViewCoordInScreenCoord:loc]);
		}
	}		

	// Force a refresh in operation interface. This workaround is needed for the case 'setCenter' is called, a touch begins(no move) and the old map position is shown.
	MapOperationInterface* operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();
	operationInterface->move(0,0);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Get the MapLib from the wfSession.
	MapLibAPI* mapLib = APP_SESSION.mapLibAPI;
	
	// Get the operationInterface from MapLib
	MapOperationInterface* operationInterface = mapLib->getMapOperationInterface();

	// Set movementMode to true
	operationInterface->setMovementMode(true);	
	
	// Get position, update the map 
	if([touches count] == 1 && self.panningEnabled) {
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		CGPoint loc = [touch locationInView:self];
		CGPoint prevLoc = [touch previousLocationInView:self];
		
		MapLibAPI* mapLib = APP_SESSION.mapLibAPI;
		if (mapLib != NULL) {
			mapLib->getMapOperationInterface()->move(prevLoc.x - loc.x, prevLoc.y - loc.y);
			self.mapsCenter = mapLib->getMapOperationInterface()->getCenter();
		}				
	} else if([touches count] == 2 && self.zoomingEnabled) {
		// Get the touches for both fingers.
		UITouch *t1 = [[touches allObjects] objectAtIndex:0];
		UITouch *t2 = [[touches allObjects] objectAtIndex:1];
		
		// Get the scrreen positions for the touch points
		CGPoint loc1 = [t1 locationInView:self];
		CGPoint loc2 = [t2 locationInView:self];
		
		// Get the screen points for the previous touch points
		CGPoint prevLoc1 = [t1 previousLocationInView:self];
		CGPoint prevLoc2 = [t2 previousLocationInView:self];        
		
		// Zoom center
		CGPoint center = CGPointMake((loc1.x + loc2.x) / 2, (loc1.y + loc2.y) / 2);
		CGPoint prevCenter = CGPointMake((prevLoc1.x + prevLoc2.x) / 2, (prevLoc1.y + prevLoc2.y) / 2);
		
		// Zoom amount
		CGFloat lastDist = hypot(prevLoc1.x - prevLoc2.x,
								 prevLoc1.y - prevLoc2.y);
		CGFloat dist = hypot(loc1.x - loc2.x, loc1.y - loc2.y);
		
		lastTouchDistance += fabs(lastDist - dist);
		
		// Move the map to keep the center
		MapOperationInterface* operationInterface =
		mapLib->getMapOperationInterface();
		operationInterface->move(prevCenter.x - center.x,
								 prevCenter.y - center.y);
		
		// Convert the center screen point to world coordinates
		WGS84Coordinate centerCoord;
		ScreenPoint centerPt = [self transformViewCoordInScreenCoord:center];
		operationInterface->screenToWorld(centerCoord, centerPt);
		
		// Zoom, in or out depends on the result of lastDist / dist
		self.centerUserPosition = NO;						
		
		MapLibAPI* mapLib = APP_SESSION.mapLibAPI;
		if((lastDist / dist) * self.zoomLevel < MAX_ZOOM_LEVEL) {
			mapLib->getMapOperationInterface()->zoom(lastDist / dist, centerCoord, centerPt);
			zoomLevel = mapLib->getMapOperationInterface()->getZoomLevel();
			self.mapsCenter = mapLib->getMapOperationInterface()->getCenter();		
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	MapLibAPI *mapLib =  APP_SESSION.mapLibAPI;
	MapLibKeyInterface* keyInterface = mapLib->getKeyInterface();
	MapOperationInterface* operationInterface = mapLib->getMapOperationInterface();
	
	// added code for detecting hold down event
	if ([touches count] == 1) {
		UITouch *endTouch = [[touches allObjects] objectAtIndex:0];
		CGPoint endPoint = [endTouch locationInView:self];
		
		if (((endPoint.x >= initialTouchLocation.x - 5) && (endPoint.x <= initialTouchLocation.x + 5)) &&
			((endPoint.y >= initialTouchLocation.y - 5) && (endPoint.y <= initialTouchLocation.y + 5))) {
			
			ScreenPoint screenCoordsEndPoint = [self transformViewCoordInScreenCoord:endPoint];
			
			NSLog(@"Detected hold down event at view point %@, screen point: (%d,%d)", NSStringFromCGPoint(endPoint), screenCoordsEndPoint.getX(), screenCoordsEndPoint.getY());
			
			if (mapLib != NULL) {
				keyInterface->handlePointerEvent(MapLibKeyInterface::DRAG_TO,
												 MapLibKeyInterface::POINTER_DOWN_EVENT,
												 screenCoordsEndPoint);
				keyInterface->handlePointerEvent(MapLibKeyInterface::DRAG_TO,
												 MapLibKeyInterface::POINTER_UP_EVENT,
												 screenCoordsEndPoint);
				
			}
		}
	}
	
	// Set movementMode to false
	operationInterface->setMovementMode(false);
	
	lastTouchDistance = 0;
}

#pragma mark -
#pragma mark UIView Methods

- (void)setFrame:(CGRect)newValue {
	[super setFrame:newValue];
	CALayer *layer = self.layer;
	CGRect bounds = layer.bounds;
	NSLog(@"EAGL View frame set:    (%f, %f) (%f, %f)", newValue.origin.x, newValue.origin.y, newValue.size.width, newValue.size.height);
}

#pragma mark -
#pragma mark Coordinate Transformation Methods

- (ScreenPoint)worldToScreen:(WGS84Coordinate)worldPos
{
	ScreenPoint point;
	MapOperationInterface* operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();		
	operationInterface->worldToScreen(point, worldPos);
	return ScreenPoint(point.getX(), point.getY()+(RENDERBUFFER_MAX_Y-backingHeight));
}

- (ScreenPoint)transformViewCoordInScreenCoord:(CGPoint)point
{
	return ScreenPoint(point.x, point.y-(RENDERBUFFER_MAX_Y-backingHeight));
}

- (void)applyRequestedTransformsToMap
{
	MapOperationInterface *operationInterface = APP_SESSION.mapLibAPI->getMapOperationInterface();	
	BOOL requestWasApplied = NO;
	
	if (needsToSetUsersPosition) {
		needsToSetUsersPosition = NO;
		[self setUsersPosition:neededUsersPosition];
		requestWasApplied = YES;
	}
	
	if (needsToSetWorldBox) {
		needsToSetWorldBox = NO;
		operationInterface->setWorldBox(worldBoxFirstCoord, worldBoxSecondCoord);
		requestWasApplied = YES;
	}
	
	if (requestWasApplied) {
		MapDrawingInterface *mapDrawingInterface = APP_SESSION.mapLibAPI->getMapDrawingInterface();	
		mapDrawingInterface->requestRepaint();	
	}
}

@end
