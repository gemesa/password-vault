#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasswordEntry : NSObject <NSSecureCoding>

@property(nonatomic, strong, readonly) NSUUID *identifier;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong, nullable) NSString *notes;

- (instancetype)initWithTitle:(NSString *)title
                     username:(NSString *)username
                     password:(NSString *)password
                        notes:(nullable NSString *)notes;

@end

NS_ASSUME_NONNULL_END
