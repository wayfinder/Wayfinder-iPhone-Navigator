/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "InvocationRequest.h"


@implementation InvocationRequest

@synthesize retries;
@synthesize receiver;
@synthesize method;
@synthesize parameters;

- (id)initWithReceiver:(id)recv andMethod:(SEL)mtd andParameters:(NSArray *)params {
	if (self = [super init]) {
		self.retries = 0;
		self.receiver = recv;
		self.method = mtd;
		self.parameters = params;
		NSLog(@"Incovation request init...");
	}
	return self;
}

- (void)dealloc {
	NSLog(@"Invocation request dealloc...");
	self.receiver = nil;
	self.parameters = nil;
	[super dealloc];
}

- (NSNumber *)retry {
	++retries;
	NSMethodSignature *sig = [[receiver class] instanceMethodSignatureForSelector:method];
	NSInvocation *myInvocation = [NSInvocation invocationWithMethodSignature:sig];
	[myInvocation setTarget:receiver];
	[myInvocation setSelector:method];
	
	for (int i = 0; i < [parameters count]; ++i) {
		id obj = [parameters objectAtIndex:(i)];
		[myInvocation setArgument:&obj atIndex:i + 2];
	}
	
	NSNumber *result;
	NSLog(@"Invoking %s...", method);
	[myInvocation retainArguments];
	[myInvocation invoke];
	[myInvocation getReturnValue:&result];
	
	return result;
}

@end
