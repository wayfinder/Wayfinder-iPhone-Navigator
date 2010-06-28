#import "AsynchronousStatus.h"

using namespace WFAPI;

#define PERSISTENT_HANDLER_FOR_ALL_REQUESTS 0x0FFFFFFF
#define DUMMY_REQUEST_ID 0x0FFFFFFE

@protocol BaseHandler

// although implementation of this is mandatory, it will never be invoked on GeocodingHandlers, ImageHandlers or LocationHandlers
// -> all errors on these go directly to ErrorHandler::handleErrorWithStatus...
- (void)errorWithStatus:(AsynchronousStatus *)status;

//@optional
- (void)requestCancelled:(NSNumber *)requestID;

@end

// test comment for default branch