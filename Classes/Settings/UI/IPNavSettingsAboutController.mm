/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "LocalizationHandler.h"
#import "IPNavSettingsAboutController.h"

static CGRect kDisplayViewFrame = {0.0, 00.0, 320.0, 480.0};

@implementation IPNavSettingsAboutController

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	// create web fie for displaying about information
	_displayView = [[UIWebView alloc] initWithFrame:kDisplayViewFrame];
    return self;
}

- (void)dealloc {
	[_displayView release];
    [super dealloc];
}

- (void)loadView {
	[super loadView];
	
	[self.view addSubview:_displayView];
	[self.view sendSubviewToBack:_displayView];
	
	// load about.html request
	NSString *filepath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];	
	NSURL *fileurl = [NSURL fileURLWithPath:filepath];
	NSString *absoluteurlstr = fileurl.absoluteString;
	
	NSString *internalVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InternalReleaseVersion"];	
	NSString *versionString =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *debugString = BILLING_ENABLED ? @"0" : @"1";
	
	NSString *resolvedurlstr = [absoluteurlstr stringByAppendingFormat:@"?version=%@&debug=%@&rev=%@", versionString, debugString, internalVersionString];
	NSURL *resolvedurl = [NSURL URLWithString:resolvedurlstr];	
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:resolvedurl];

	[_displayView loadRequest:request];
	[request release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// set title
	self.title = [LocalizationHandler getString:@"[iPh_about_txt]"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

@end
