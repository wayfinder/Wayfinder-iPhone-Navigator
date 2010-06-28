/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPNavNumericInputTableViewCell.h"

static CGRect kInputTextFieldFrame = {0.0, 6.0, 200.0, 30.0};

@implementation IPNavNumericInputTableViewCell

@synthesize inputTextField = _inputTextField;

- (id)initWithIdentifier:(NSString *)reuseIdentifier target:(id)target action:(SEL)action {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (!self) return nil;
	
	_valueUpdatedTarget = target;
	_valueUpdatedAction = action;	
	
	[self.textLabel setFont:[UIFont systemFontOfSize:14]];
	[self.textLabel setBackgroundColor:[UIColor clearColor]];
	
	_inputTextField = [[UITextField alloc] initWithFrame:kInputTextFieldFrame];
	[self.contentView addSubview:_inputTextField];
	_inputTextField.textAlignment = UITextAlignmentRight;
	_inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	_inputTextField.returnKeyType = UIReturnKeyDone;
	_inputTextField.borderStyle = UITextBorderStyleRoundedRect;
	_inputTextField.delegate = self;
    return self;
}

- (void)dealloc {
	[_inputTextField release];
    [super dealloc];
}

- (void)updateWithSettingInfo:(NSDictionary *)settingInfo {

	
	NSString *settingName = [settingInfo objectForKey:@"settingName"];
	NSNumber *settingValue	  = [settingInfo objectForKey:@"settingValue"];
	
	[self.textLabel setText:settingName];
	[_inputTextField setText:[settingValue stringValue]];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect inputFrame = kInputTextFieldFrame;
	inputFrame.origin.x = CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(inputFrame) - 10.0;
	
	[_inputTextField setFrame:inputFrame];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_valueUpdatedTarget performSelector:_valueUpdatedAction withObject:_inputTextField];
	[textField resignFirstResponder];	
	return NO;
}

@end
