#import "PasswordEntry.h"
#import "VaultStorage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VaultStorageManager : NSObject

- (NSArray<PasswordEntry *> *)allEntries;
- (VaultStorageResult)addEntry:(PasswordEntry *)entry;
- (VaultStorageResult)updateEntry:(PasswordEntry *)entry;
- (VaultStorageResult)deleteEntry:(PasswordEntry *)entry;
- (VaultStorageResult)loadVault;
- (VaultStorageResult)saveVault;

@end

NS_ASSUME_NONNULL_END
