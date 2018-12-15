#import <Foundation/Foundation.h>
#import "ListObject.h"

@protocol FavoriteChangeHandling <NSObject>
- (void) favouriteChangedStatusWithObject:(ListObject*)listObject;
@end

