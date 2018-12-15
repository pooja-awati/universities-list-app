#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ListObject : NSObject
@property(nonatomic,strong) NSString *universityName;
@property(nonatomic,strong) NSString *domainName;
@property(nonatomic,strong) NSString *country;
@property(nonatomic,strong) NSString *webPageUrlString;
@property(nonatomic,strong) NSData *imageData;
@property(nonatomic,assign) BOOL isFavorite;

@end


