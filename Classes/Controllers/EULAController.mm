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
#import "EULAController.h"
#import "DrivingWarningAlertView.h"


@implementation EULAController

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	_eulaDisplay = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 428.0)];
	[_eulaDisplay setDelegate:self];
	
	return self;
}

- (void)dealloc {
	[_eulaDisplay release];
    [super dealloc];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	[self.view addSubview:_eulaDisplay];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
		
	UIBarButtonItem *notAcceptedButton = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHandler getString:@"iPh_reject_tk"]
																		  style:UIBarButtonItemStylePlain
																		 target:self 
																		 action:@selector(exitApplication)];
	
	self.navigationItem.leftBarButtonItem = notAcceptedButton;
	[notAcceptedButton release];
	
	UIBarButtonItem *acceptedButton = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHandler getString:@"iPh_accept_tk"]
																	   style:UIBarButtonItemStylePlain 
																	  target:self 
																	  action:@selector(nextStep)];
	
	self.navigationItem.rightBarButtonItem = acceptedButton;
	[acceptedButton release];
	
	NSString *title = [LocalizationHandler getString:@"iPh_terms_conditions_txt"];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 320.0)];
	[titleLabel setText:title];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont systemFontOfSize:16.0]];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	
	[self.navigationItem setTitleView:titleLabel];
	[titleLabel release];
	
	// load about.html request
	NSString *path = [[UIApplication getDocumentsPath] stringByAppendingPathComponent:@"eula_nav_iphone"];

	NSData *eulaData = [[NSData alloc] initWithContentsOfFile:path];
	if (eulaData) {
		[_eulaDisplay loadData:eulaData MIMEType:@"text/plain" textEncodingName:@"utf-8" baseURL:nil];
	} else {
		NSLog(@"!!! EULA not available");
	}
	
	[eulaData release];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)exitApplication {
	[UIApplication acceptEULA:NO];
	exit(0);
}

- (void)nextStep {
	[UIApplication acceptEULA:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate related methods
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}


@end
