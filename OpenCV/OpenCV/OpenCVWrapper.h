#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;
+ (UIImage *)cvInpaint:(UIImage *)inputImage maskImage:(UIImage *) mask;

@end

NS_ASSUME_NONNULL_END
