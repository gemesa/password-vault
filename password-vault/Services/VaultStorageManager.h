#import "PasswordEntry.h"
#import "VaultStorage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VaultStorageManager : NSObject

- (NSArray<PasswordEntry *> *)allEntries;
- (VaultStorageResult)addEntry:(PasswordEntry *)entry
                  withPassword:(NSString *)password;
- (VaultStorageResult)updateEntry:(PasswordEntry *)entry
                     withPassword:(NSString *)password;
- (VaultStorageResult)deleteEntry:(PasswordEntry *)entry
                     withPassword:(NSString *)password;
- (VaultStorageResult)loadVaultWithPassword:(NSString *)password;
- (VaultStorageResult)saveVaultWithPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
