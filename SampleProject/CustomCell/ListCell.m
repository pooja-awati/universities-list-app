#import "ListCell.h"
#import "ListObject.h"

@interface ListCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) UIImage *image;
@end

@implementation ListCell

+ (NSString *)reusableIdentifier {
    return NSStringFromClass(ListCell.class);
}

- (void)setListObject:(ListObject *)listObject {
    _listObject = listObject;
    self.fullName = [NSString stringWithFormat:@"%@", _listObject.universityName];
    self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.fullName];
    self.country = _listObject.country;
    self.countryLabel.attributedText = [[NSAttributedString alloc] initWithString:self.country];
}


@end
