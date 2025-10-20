#import "PasswordValidator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PasswordValidator

+ (Boolean)isPasswordValid:(NSString *)password {
    return [self isLongEnough:password] && [self isStrongEnough:password];
}

// In practice, a strong password should be longer.
+ (Boolean)isLongEnough:(NSString *)password {
    return password.length >= 6;
};

// In practice, a strong password should be more complex.
+ (Boolean)isStrongEnough:(NSString *)password {
    Boolean letter =
        [password
            rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]]
            .location != NSNotFound;
    Boolean number =
        [password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]]
            .location != NSNotFound;
    return letter && number;
};

@end

NS_ASSUME_NONNULL_END
