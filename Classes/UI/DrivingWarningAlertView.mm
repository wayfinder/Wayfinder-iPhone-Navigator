/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "DrivingWarningAlertView.h"
#import "LocalizationHandler.h"

@implementation DrivingWarningAlertView


- (id)init {

	self = [super init];
	
	_drivingWarningDisabled = [UIApplication drivingWarningDisabled];
	
	[self setTitle:[LocalizationHandler getString:@"iPh_safety_mess_title"]];
	NSString *warningMessage = [NSString stringWithFormat:@"%@\n\n%@\n\n\n\n", [LocalizationHandler getString:@"[disable_wifi_message]"], [LocalizationHandler getString:@"iPh_safety_mess_txt"]];

	[self setMessage:warningMessage];
	
	_checkboxButton = [[UIButton alloc] initWithFrame:CGRectMake(210.0, 242.0, 25.0, 25.0)];
	[_checkboxButton addTarget:self action:@selector(checkboxPressed) forControlEvents:UIControlEventTouchUpInside];
	[_checkboxButton setBackgroundImage:[UIImage imageNamed:@"checkbox_off.png"] forState:UIControlStateNormal];
	[_checkboxButton setBackgroundColor:[UIColor redColor]];
	
	_dontShowAgainLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 240.0, 200.0, 25.0)];
	[_dontShowAgainLabel setText:[LocalizationHandler getString:@"iPh_dont_show_cb_txt"]];
	[_dontShowAgainLabel setTextColor:[UIColor whiteColor]];
	[_dontShowAgainLabel setBackgroundColor:[UIColor clearColor]];
	
	[self addSubview:_checkboxButton];
	[self addSubview:_dontShowAgainLabel];
	
	[self addButtonWithTitle:[LocalizationHandler getString:@"iPh_ok_tk"]];
	[self setCancelButtonIndex:0];
	
	if (!self) return nil;
	
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}


- (void)dealloc {
	[_dontShowAgainLabel release];
	[_checkboxButton release];
    [super dealloc];
}

- (void)checkboxPressed {
	_drivingWarningDisabled = !_drivingWarningDisabled;
	
	[UIApplication disableDrivingWarning:_drivingWarningDisabled];
	
	if (_drivingWarningDisabled) {
		[_checkboxButton setBackgroundImage:[UIImage imageNamed:@"checkbox_on.png"] forState:UIControlStateNormal];
	} else {
		[_checkboxButton setBackgroundImage:[UIImage imageNamed:@"checkbox_off.png"] forState:UIControlStateNormal];
	}
}


@end
