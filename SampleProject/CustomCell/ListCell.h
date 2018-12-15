#import <UIKit/UIKit.h>

@class ListObject;

@interface ListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

@property (nonatomic, strong) ListObject *listObject;

+ (NSString *)reusableIdentifier;

@end
