#import "FirstViewController.h"
#import "MainViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *domainLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *favoritesSwitch;
@property (weak, nonatomic) IBOutlet UIButton *visitMyPageButton;

- (IBAction)visitMyPageAction:(id)sender;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Back";
    [self.favoritesSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    self.title = @"University";
    [self loadPage];
    // Do any additional setup after loading the view.
}
-(void)loadPage {
    self.nameLabel.text = _myCustomObjectToPass.universityName;
    self.domainLabel.text = _myCustomObjectToPass.domainName;
    self.locationLabel.text = _myCustomObjectToPass.country;
    
    if (_myCustomObjectToPass.imageData != nil) {
        [self.imageLogo setImage: [UIImage imageWithData:_myCustomObjectToPass.imageData]];
    }
    else {
        [self.imageLogo setImage: [UIImage imageNamed:@"Default_University"]];
    }
    self.favoritesSwitch.on = self.myCustomObjectToPass.isFavorite;
}

- (IBAction)visitMyPageAction:(id)sender {
    if (_myCustomObjectToPass.webPageUrlString != nil) {
        NSString *linkName = _myCustomObjectToPass.webPageUrlString;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkName] options:@{} completionHandler:nil];
    }
}

- (void)setState:(id)sender
{
    self.myCustomObjectToPass.isFavorite = !self.myCustomObjectToPass.isFavorite;
    self.favoritesSwitch.on = self.myCustomObjectToPass.isFavorite;
    if ([self.favouriteProtocol respondsToSelector:@selector(favouriteChangedStatusWithObject:)]) {
        [self.favouriteProtocol favouriteChangedStatusWithObject:self.myCustomObjectToPass];
    }
}
@end
