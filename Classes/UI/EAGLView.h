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
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "IPhoneOpenGLESDrawer.h"

#import "Nav2API.h"
#import "MapOperationInterface.h"
#import "LocationHandler.h"
#import "WGS84Coordinate.h"
#import "PlaceBase.h"

#define MAX_ZOOM_LEVEL 22000.0

@class OverlayView;
@class OverlayItemDescriptionView;

using namespace WFAPI;

typedef enum PositionIndicatorType {
	currentPositionNonGPS,
	currentPositionGPS,
	driving2D,
	driving3D,
	none
} PositionIndicatorType;

typedef struct MapConfiguration {
	WGS84Coordinate usersPosition;
	WGS84Coordinate mapsCenter;
	double angle;	
	BOOL centerUserPosition;
	BOOL use3DMap;
	double zoomLevel;
	PositionIndicatorType indicatorType;
} MapConfiguration;
	
/*
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.
 Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface EAGLView : UIView {
	
@public 
	
	WGS84Coordinate usersPosition;
	WGS84Coordinate mapsCenter;
	double angle;
	BOOL panningEnabled;
	BOOL zoomingEnabled;
	BOOL centerUserPosition;
	BOOL use3DMap;
	double zoomLevel;
	PositionIndicatorType indicatorType;	
	
@private
	
    GLint backingWidth;				// Pixel width of the backbuffer.    	
    GLint backingHeight;			// Pixel height of the backbuffer.   
	
    GLuint depthRenderbuffer;		// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist).	
	IPhoneOpenGLESDrawer *glDrawer;
	GLuint viewRenderbuffer;
	GLuint viewFramebuffer;
	EAGLContext *context;
	
    CGPoint initialTouchLocation;	// Point where the touch event started.
    CGFloat startingDistance;	    // Distance in pixels between the two fingers of the initial touch event (is applicable).
    CGFloat lastTouchDistance;		// Keeps track of the distance when pinching.			
    int numTouches;					// Number of touches generated by the user.
	
	OverlayView *overlayView;
	OverlayItemDescriptionView *_descriptionView;

	// Variables used in case when we have to set properties on the EAGLView but the render buffer size is still not set. These properties will be set right after the render buffer is initialized.
	BOOL needsToSetWorldBox;
	BOOL needsToSetUsersPosition;
	WGS84Coordinate worldBoxFirstCoord;
	WGS84Coordinate worldBoxSecondCoord;
	WGS84Coordinate neededUsersPosition;
}

@property (nonatomic, assign) WGS84Coordinate usersPosition;
@property (nonatomic, assign) WGS84Coordinate mapsCenter;
@property (nonatomic, assign) double angle;
@property (nonatomic, assign) BOOL panningEnabled;
@property (nonatomic, assign) BOOL zoomingEnabled;
@property (nonatomic, assign) BOOL centerUserPosition;
@property (nonatomic, assign) BOOL use3DMap;
@property (nonatomic, assign) double zoomLevel;
@property (nonatomic, assign) PositionIndicatorType indicatorType;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

//@property (nonatomic, retain) EAGLContext *context;
//@property (nonatomic, assign) GLuint viewRenderbuffer;
//@property (nonatomic, assign) GLuint viewFramebuffer;
//@property (nonatomic, assign) GLuint depthRenderbuffer;
@property (nonatomic, readonly) IPhoneOpenGLESDrawer *glDrawer;

@property (nonatomic, assign) CGPoint initialTouchLocation;
@property (nonatomic, assign) CGFloat startingDistance;
@property (nonatomic, assign) CGFloat lastTouchDistance;
@property (nonatomic, assign) int numTouches;

@property (nonatomic, retain) OverlayView *overlayView;
@property (nonatomic, retain) OverlayItemDescriptionView *descriptionView;

@property (nonatomic, assign) BOOL needsToSetWorldBox;
@property (nonatomic, assign) BOOL needsToSetUsersPosition;

- (void)drawView;

- (void)addOverlayView;

- (void)initMapDrawer;

- (BOOL)createFramebufferIfNeeded;

- (void)destroyFramebuffer;

- (MapConfiguration)getMapConfiguration;

- (void)setMapConfiguration:(MapConfiguration)conf;

+ (MapConfiguration)getDefaultMapConfiguration;

- (void)showDescriptionForItem:(PlaceBase *)item withTarget:(id)target selector:(SEL)selector;

- (void)setNeedsSetWorldBoxToFirstCoord:(WGS84Coordinate)firstCoord secondCoord:(WGS84Coordinate) secondCoord;

- (ScreenPoint)worldToScreen:(WGS84Coordinate)worldPos;

- (ScreenPoint)transformViewCoordInScreenCoord:(CGPoint)point;

- (void)applyRequestedTransformsToMap;

- (void)relocateCopyrightMessageAtTop:(BOOL)top andOffset:(int)offset;

- (void)setNeedsSetUsersPosition:(WGS84Coordinate)newValue;

@end