#import "VaultStorage.h"
#import "password_vault-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@implementation VaultStorage

- (NSString *)vaultFilePath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(
                                  NSDocumentDirectory, NSUserDomainMask, YES)
                                  .firstObject;
    return [documentsPath stringByAppendingPathComponent:@"vault.dat"];
}

- (BOOL)vaultFileExists {
    NSString *path = [self vaultFilePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (VaultStorageResult)saveEntries:(NSArray<PasswordEntry *> *)entries
                     withPassword:(NSString *)password {
    NSString *path = [self vaultFilePath];

    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:entries
                                         requiringSecureCoding:YES
                                                         error:&error];

    if (!data) {
        NSLog(@"Failed to serialize entries: %@", error.description);
        return VaultStorageResultFailedToSerialize;
    }

    NSData *encryptedData = [VaultEncryption encryptWithData:data
                                                    password:password
                                                       error:&error];
    if (!encryptedData) {
        NSLog(@"Failed to encrypt data: %@", error.localizedDescription);
        return VaultStorageResultFailedToEncrypt;
    }

    BOOL success = [encryptedData writeToFile:path atomically:YES];

    if (!success) {
        NSLog(@"Failed to write the vault file to path: %@", path);
        return VaultStorageResultFailedToWrite;
    }

    return VaultStorageResultSuccess;
}

- (VaultStorageResult)
     loadEntries:(NSArray<PasswordEntry *> *_Nullable *_Nullable)entries
    withPassword:(NSString *)password {
    NSString *path = [self vaultFilePath];

    if (![self vaultFileExists]) {
        if (entries) {
            *entries = @[];
        }
        return VaultStorageResultSuccess;
    }

    NSData *encryptedData = [NSData dataWithContentsOfFile:path];

    if (!encryptedData) {
        NSLog(@"Failed to read vault file from path: %@", path);
        return VaultStorageResultFailedToRead;
    }

    NSError *error = nil;
    NSData *data = [VaultEncryption decryptWithEncryptedData:encryptedData
                                                    password:password
                                                       error:&error];
    if (!data) {
        NSLog(@"Failed to decrypt data: %@", error.localizedDescription);
        return VaultStorageResultFailedToDecrypt;
    }

    NSSet *classes =
        [NSSet setWithObjects:[NSArray class], [PasswordEntry class], nil];

    NSArray<PasswordEntry *> *loadedEntries =
        [NSKeyedUnarchiver unarchivedObjectOfClasses:classes
                                            fromData:data
                                               error:&error];

    if (!loadedEntries) {
        NSLog(@"Failed to deserialize entries: %@", error.description);
        return VaultStorageResultFailedToDeserialize;
    }

    if (entries) {
        *entries = loadedEntries;
    }

    return VaultStorageResultSuccess;
}

- (VaultStorageResult)deleteVaultFile {
    NSString *path = [self vaultFilePath];

    if (![self vaultFileExists]) {
        return VaultStorageResultSuccess;
    }

    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path
                                                              error:&error];

    if (!success) {
        NSLog(@"Failed to delete vault file: %@", error.description);
        return VaultStorageResultFailedToDelete;
    }

    return VaultStorageResultSuccess;
}

@end

NS_ASSUME_NONNULL_END
