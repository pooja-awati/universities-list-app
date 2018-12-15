@class MainViewController;

#import <UIKit/UIKit.h>
#import "ListObject.h"
#import "FavoriteChangeHandling.h"

NS_ASSUME_NONNULL_BEGIN

@interface FirstViewController : UIViewController
@property UIImage* sourceImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageLogo;
@property (strong, nonatomic) ListObject *myCustomObjectToPass;
@property (weak, nonatomic) id <FavoriteChangeHandling> favouriteProtocol;

@end

NS_ASSUME_NONNULL_END
