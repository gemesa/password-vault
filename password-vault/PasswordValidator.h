#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasswordValidator : NSObject

+ (Boolean)isPasswordValid:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
