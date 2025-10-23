#import "VaultStorageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VaultStorageManager ()

@property(nonatomic, strong) NSMutableArray<PasswordEntry *> *entries;
@property(nonatomic, strong) VaultStorage *storage;

@end

@implementation VaultStorageManager

- (instancetype)init {
    if (self = [super init]) {
        _storage = [[VaultStorage alloc] init];
        _entries = [NSMutableArray array];
    }
    return self;
}

- (VaultStorageResult)loadVaultWithPassword:(NSString *)password {
    NSArray<PasswordEntry *> *loadedEntries = nil;
    VaultStorageResult result = [self.storage loadEntries:&loadedEntries
                                             withPassword:password];

    if (result == VaultStorageResultSuccess) {
        self.entries = [loadedEntries mutableCopy];
    }

    return result;
}

- (NSArray<PasswordEntry *> *)allEntries {
    return [self.entries copy];
}

- (VaultStorageResult)addEntry:(PasswordEntry *)entry
                  withPassword:(NSString *)password {
    [self.entries addObject:entry];
    return [self saveVaultWithPassword:password];
}

- (VaultStorageResult)saveVaultWithPassword:(NSString *)password {
    return [self.storage saveEntries:self.entries withPassword:password];
}

- (VaultStorageResult)updateEntry:(PasswordEntry *)entry
                     withPassword:(NSString *)password {
    NSUInteger index = [self.entries
        indexOfObjectPassingTest:^BOOL(PasswordEntry *_Nonnull obj,
                                       NSUInteger idx, BOOL *_Nonnull stop) {
          return [obj.identifier isEqual:entry.identifier];
        }];

    if (index != NSNotFound) {
        self.entries[index] = entry;
        return [self saveVaultWithPassword:password];
    }

    return VaultStorageResultFailedToUpdate;
}

- (VaultStorageResult)deleteEntry:(PasswordEntry *)entry
                     withPassword:(NSString *)password {
    [self.entries removeObject:entry];
    return [self saveVaultWithPassword:password];
}

@end

NS_ASSUME_NONNULL_END
