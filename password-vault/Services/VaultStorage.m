#import "VaultStorage.h"

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

- (VaultStorageResult)saveEntries:(NSArray<PasswordEntry *> *)entries {
    NSString *path = [self vaultFilePath];

    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:entries
                                         requiringSecureCoding:YES
                                                         error:&error];

    if (!data) {
        NSLog(@"Failed to serialize entries: %@", error.description);
        return VaultStorageResultFailedToSerialize;
    }

    BOOL success = [data writeToFile:path atomically:YES];

    if (!success) {
        NSLog(@"Failed to write the vault file to path: %@", path);
        return VaultStorageResultFailedToWrite;
    }

    return VaultStorageResultSuccess;
}

- (VaultStorageResult)loadEntries:
    (NSArray<PasswordEntry *> *_Nullable *_Nullable)entries {
    NSString *path = [self vaultFilePath];

    if (![self vaultFileExists]) {
        if (entries) {
            *entries = @[];
        }
        return VaultStorageResultSuccess;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];

    if (!data) {
        NSLog(@"Failed to read vault file from path: %@", path);
        return VaultStorageResultFailedToRead;
    }

    NSSet *classes =
        [NSSet setWithObjects:[NSArray class], [PasswordEntry class], nil];

    NSError *error = nil;

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
