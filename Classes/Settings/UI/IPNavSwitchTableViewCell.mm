/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "IPNavSwitchTableViewCell.h"

@implementation IPNavSwitchTableViewCell

@synthesize valueSwitch = _valueSwitch;

- (id)initWithIdentifier:(NSString *)identifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (!self) return nil;
	
	[self.textLabel setFont:[UIFont systemFontOfSize:14]];
	[self.textLabel setBackgroundColor:[UIColor clearColor]];
	
	_valueSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:_valueSwitch];
	
	return self;
}

- (void)dealloc {
	[_valueSwitch release];
	
    [super dealloc];
}

- (void)updateWithSettingInfo:(NSDictionary *)settingInfo {
	NSString *settingName = [settingInfo objectForKey:@"settingName"];
	BOOL settingValue	  = [(NSNumber *)[settingInfo objectForKey:@"settingValue"] boolValue];
	
	[self.textLabel setText:settingName];
	[_valueSwitch setOn:settingValue animated:NO];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect switchFrame = _valueSwitch.bounds;
	CGRect labelFrame = self.textLabel.bounds;
	CGRect cellFrame = self.contentView.frame;
	
	switchFrame.origin.y = round(abs(CGRectGetHeight(cellFrame) - CGRectGetHeight(switchFrame)) / 2);
	switchFrame.origin.x = CGRectGetWidth(cellFrame) - CGRectGetWidth(switchFrame) - 10.0;
	// UISwitch ignores the size values of a frame, it uses only the origin values
	_valueSwitch.frame = switchFrame;
	
	labelFrame.origin.x = 10.0;
	labelFrame.size.width = round(CGRectGetWidth(cellFrame) / 2);
	self.textLabel.frame = labelFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:YES];
}

@end
