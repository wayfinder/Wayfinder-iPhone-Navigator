/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "BillingViewController.h"
#import "IPNavSettingsManager.h"
#import "UIApplication-Additions.h"
#import "NSURL-Additions.h"
#import "NetworkTunnel.h"
#import "AppSession.h"

@implementation BillingViewController

- (id)initWithURL:(NSURL *)url {
	self = [super init];
	if (!self) return nil;
	
	// initiate busy view	
	_busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[_busyIndicator setFrame:CGRectMake(150.0, 190.0, 20.0, 20.0)];
	
	// initiate the web display view
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
	[_webView setDelegate:self];
	
	_currentURL = [url retain];
	_mainHost = [[NSString alloc] initWithFormat:@"%@://%@",[url scheme], [url host]];
	
	// start url request
	[[NetworkTunnel sharedInstance] registerRequester:self forURLData:url firstCall:YES];
	
	return self;
}

- (void)dealloc {
	[_busyIndicator release];
	[_currentURL release];
	[_webView release];
	[_mainHost release];
    [super dealloc];
}

- (void)loadView {
	[super loadView];
	[self.view addSubview:_webView];
	[_webView addSubview:_busyIndicator];
	
	[self.navigationItem setHidesBackButton:YES animated:NO];
	
	[_busyIndicator startAnimating];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark NetworkTunnelRequester methods

- (void)requestFinishedWithData:(NSString *)data {
	
	NSLog(@"loading data :%@", data);
	
	// load received data into the web control
	[_webView loadHTMLString:data baseURL:[NSURL fileURLWithPath:[UIApplication getDocumentsPath]]];
}

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	
	[self showBusyIndicator];
	
	NSURL *url = [request URL];
	NSLog(@"url : %@", url);	
	// if the url is the one requested through the tunnel we allow the web view to start loading
	if ([url isEqual:_currentURL]) return YES;
	
	NSString *urlPath = [url relativePath];
	NSString *testPath = [[NSURL fileURLWithPath:[UIApplication getDocumentsPath]] relativePath];
	
	if ([urlPath isEqualToString:testPath]) return YES;
	
	NSString *scheme = [url	scheme];
	NSString *host   = [url host];
		
	if ([scheme isEqualToString:@"wf"] && [host isEqualToString:@"startup"]) {

		WFActionType actionType = WFNoAction;
		
		// get action type we need to perform
		NSString *actionValue = [url valueForParam:@"action"];
		if ([actionValue isEqualToString:@"setuin"]) {
			actionType = WFSetUINAction;
		} else if ([actionValue isEqualToString:@"exit"]) {
			exit(101);
		}
		
		if (WFSetUINAction == actionType) {
			// get uin
			NSString *uin = [url valueForParam:@"uin"];
			[[IPNavSettingsManager sharedInstance] setUIN:uin];
			// retry connecting 
			[APP_SESSION startupMapLibAPI];
		}
		WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.navController popViewControllerAnimated:YES];
		
	} else if ([scheme isEqualToString:@"wf"] && [host isEqualToString:@"mainmenu"]) {
		// go to main menu
		WFNavigationAppDelegate *appDelegate = (WFNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.navController popToRootViewControllerAnimated:YES];
	}
	
	// if not we should redirect the request through the tunnel
	
	if ((![[url scheme] isEqualToString:@"http"] && ![[url scheme] isEqualToString:@"https"]) || (nil == [url scheme])) {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", _mainHost, [[url absoluteString] lastPathComponent] ]];
	}
	
	[[NetworkTunnel sharedInstance] registerRequester:self forURLData:url firstCall:NO];
	if (_currentURL) [_currentURL release];
	_currentURL = [url retain];
	
	return NO;
}

- (void)showBusyIndicator {
	[_busyIndicator setHidden:NO];
}

- (void)hideBusyIndicator {
	[_busyIndicator setHidden:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self hideBusyIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

@end
