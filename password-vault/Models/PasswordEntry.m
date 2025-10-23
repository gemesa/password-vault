#import "PasswordEntry.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PasswordEntry

- (instancetype)initWithTitle:(NSString *)title
                     username:(NSString *)username
                     password:(NSString *)password
                        notes:(nullable NSString *)notes {
    if (self = [super init]) {
        _identifier = [NSUUID UUID];
        _title = title;
        _username = username;
        _password = password;
        _notes = notes;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSUUID *)identifier
                             title:(NSString *)title
                          username:(NSString *)username
                          password:(NSString *)password
                             notes:(nullable NSString *)notes {
    if (self = [super init]) {
        _identifier = identifier;
        _title = title;
        _username = username;
        _password = password;
        _notes = notes;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:@"id"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.username forKey:@"username"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.notes forKey:@"notes"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _identifier = [coder decodeObjectOfClass:[NSUUID class] forKey:@"id"];
        _title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        _username = [coder decodeObjectOfClass:[NSString class]
                                        forKey:@"username"];
        _password = [coder decodeObjectOfClass:[NSString class]
                                        forKey:@"password"];
        _notes = [coder decodeObjectOfClass:[NSString class] forKey:@"notes"];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
