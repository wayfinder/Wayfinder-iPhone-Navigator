#import <UIKit/UIKit.h>

#import "PlaceDetailOwner.h"

@interface PlaceDetailEditViewController : UITableViewController {
	id<PlaceDetailOwner> placeDetailOwner;
	
	UITableViewCell *activeCell;
	
	IBOutlet UITableViewCell *plainTextCell;
	IBOutlet UITextField *plainTextField;
	IBOutlet UITableViewCell *multilineTextCell;
	IBOutlet UITextView *multilineTextView;

}

@property (nonatomic, retain) id<PlaceDetailOwner> placeDetailOwner;

@property (nonatomic, retain) UITableViewCell *activeCell;

@property (nonatomic, retain) UITableViewCell *plainTextCell;
@property (nonatomic, retain) UITextField *plainTextField;
@property (nonatomic, retain) UITableViewCell *multilineTextCell;
@property (nonatomic, retain) UITextView *multilineTextView;

- (id)initWithOwner:(id<PlaceDetailOwner>)owner;

@end
