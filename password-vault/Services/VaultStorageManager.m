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

- (VaultStorageResult)loadVault {
    NSArray<PasswordEntry *> *loadedEntries = nil;
    VaultStorageResult result = [self.storage loadEntries:&loadedEntries];

    if (result == VaultStorageResultSuccess) {
        self.entries = [loadedEntries mutableCopy];
    }

    return result;
}

- (NSArray<PasswordEntry *> *)allEntries {
    return [self.entries copy];
}

- (VaultStorageResult)addEntry:(PasswordEntry *)entry {
    [self.entries addObject:entry];
    return [self saveVault];
}

- (VaultStorageResult)saveVault {
    return [self.storage saveEntries:self.entries];
}

- (VaultStorageResult)updateEntry:(PasswordEntry *)entry {
    NSUInteger index = [self.entries
        indexOfObjectPassingTest:^BOOL(PasswordEntry *_Nonnull obj,
                                       NSUInteger idx, BOOL *_Nonnull stop) {
          return [obj.identifier isEqual:entry.identifier];
        }];

    if (index != NSNotFound) {
        self.entries[index] = entry;
        return [self saveVault];
    }

    return VaultStorageResultSuccess;
}

- (VaultStorageResult)deleteEntry:(PasswordEntry *)entry {
    [self.entries removeObject:entry];
    return [self saveVault];
}

@end

NS_ASSUME_NONNULL_END
