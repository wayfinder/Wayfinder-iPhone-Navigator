/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PlaceDetailEditViewController.h"
#import "LocalizationHandler.h"

@implementation PlaceDetailEditViewController

@synthesize placeDetailOwner;

@synthesize activeCell;

@synthesize plainTextCell;
@synthesize plainTextField;
@synthesize multilineTextCell;
@synthesize multilineTextView;

- (id)initWithOwner:(id<PlaceDetailOwner>)owner {
	if (self = [super initWithNibName:@"PlaceDetailEditView" bundle:[NSBundle mainBundle]]) {
		self.placeDetailOwner = owner;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = [LocalizationHandler getString:@"[edit_detail]"];

	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHandler getString:@"[done_nav_button]"] style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
	[self navigationItem].rightBarButtonItem = rightBarButtonItem;
	[rightBarButtonItem release];
	
}

- (void)doneClicked:(id)sender {
	NSString *text = nil;
	switch ([self.placeDetailOwner getFieldType]) {
		case PlainTextField:
			text = plainTextField.text;
			break;
		case MultilineTextField:
			text = multilineTextView.text;
			break;
	}

	if ([text isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
														message:@"You need to enter a name before you can save a place" 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	[self.placeDetailOwner editDoneWithNewValue:text];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	switch ([self.placeDetailOwner getFieldType]) {
		case PlainTextField:
			self.activeCell = plainTextCell;
			plainTextField.text = [self.placeDetailOwner getOriginalValue];
			[plainTextField becomeFirstResponder];
			break;
		case MultilineTextField:
			self.activeCell = multilineTextCell;
			multilineTextView.text = [self.placeDetailOwner getOriginalValue];
			[multilineTextView becomeFirstResponder];
			break;
	}

    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.placeDetailOwner getFieldTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return activeCell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return activeCell.bounds.size.height;// indexPath.section == 0 ? 38.0 : 120.0;
}


- (void)dealloc {
	
	self.placeDetailOwner = nil;
	
	self.activeCell = nil;
	
	self.plainTextCell = nil;
	self.plainTextField = nil;
	self.multilineTextCell = nil;
	self.multilineTextView = nil;
	
    [super dealloc];
}

@end

