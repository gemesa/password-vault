#import "PasswordEntry.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VaultStorageResult) {
    VaultStorageResultSuccess,
    VaultStorageResultFailedToRead,
    VaultStorageResultFailedToWrite,
    VaultStorageResultFailedToSerialize,
    VaultStorageResultFailedToDeserialize,
    VaultStorageResultFailedToDelete,
    VaultStorageResultFailedToEncrypt,
    VaultStorageResultFailedToDecrypt
};

@interface VaultStorage : NSObject

- (VaultStorageResult)saveEntries:(NSArray<PasswordEntry *> *)entries
                     withPassword:(NSString *)password;
- (VaultStorageResult)
     loadEntries:(NSArray<PasswordEntry *> *_Nullable *_Nullable)entries
    withPassword:(NSString *)password;
- (BOOL)vaultFileExists;
- (VaultStorageResult)deleteVaultFile;

@end

NS_ASSUME_NONNULL_END
