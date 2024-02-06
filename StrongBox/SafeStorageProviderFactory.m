//
//  SafeStorageProviderFactory.m
//  Strongbox-iOS
//
//  Created by Mark on 12/10/2018.
//  Copyright © 2014-2021 Mark McGuill. All rights reserved.
//

#import "SafeStorageProviderFactory.h"

#if TARGET_OS_IPHONE
    #import "LocalDeviceStorageProvider.h"

    #ifndef IS_APP_EXTENSION
        #ifndef NO_SFTP_WEBDAV_SP
            #import "SFTPStorageProvider.h"
            #import "WebDAVStorageProvider.h"
        #endif
        #import "AppleICloudProvider.h"
        #import "FilesAppUrlBookmarkProvider.h"
    #endif

    #ifndef NO_3RD_PARTY_STORAGE_PROVIDERS
        #import "GoogleDriveStorageProvider.h"
        #import "DropboxV2StorageProvider.h"
    #endif

    #ifndef IS_APP_EXTENSION
        #import "Strongbox-Swift.h"
    #endif
#else
    #import "MacUrlSchemes.h"
    #import "MacFileBasedBookmarkStorageProvider.h"
    #import "SFTPStorageProvider.h"
    #import "WebDAVStorageProvider.h"
    
    #ifndef IS_APP_EXTENSION
        #import "Strongbox-Swift.h"

        #ifndef NO_3RD_PARTY_STORAGE_PROVIDERS
            #import "GoogleDriveStorageProvider.h"
            #import "DropboxV2StorageProvider.h"
        #endif
    #endif
#endif

@implementation SafeStorageProviderFactory

#ifndef IS_APP_EXTENSION

+ (id<SafeStorageProvider>)getStorageProviderFromProviderId:(StorageProvider)providerId {
#if TARGET_OS_IPHONE
    if (providerId == kLocalDevice) {
        return [LocalDeviceStorageProvider sharedInstance];
    }
    else if (providerId == kiCloud) {
        return [AppleICloudProvider sharedInstance];
    }
    else if(providerId == kFilesAppUrlBookmark) {
        return FilesAppUrlBookmarkProvider.sharedInstance;
    }
    else if ( providerId == kWiFiSync ) {
        return WiFiSyncStorageProvider.sharedInstance;
    }
#else
    if (providerId == kMacFile) {
        return MacFileBasedBookmarkStorageProvider.sharedInstance;
    }
#endif
#ifndef NO_3RD_PARTY_STORAGE_PROVIDERS
    else if (providerId == kGoogleDrive) {
        return [GoogleDriveStorageProvider sharedInstance];
    }
    else if (providerId == kDropbox)
    {
        return [DropboxV2StorageProvider sharedInstance];
    }
    else if ( providerId == kTwoDrive ) {
        return TwoDriveStorageProvider.sharedInstance;
    }
#endif
#ifndef NO_SFTP_WEBDAV_SP
    else if(providerId == kWebDAV) {
        return WebDAVStorageProvider.sharedInstance;
    }
    else if(providerId == kSFTP) {
        return SFTPStorageProvider.sharedInstance;
    }
#endif
    
    NSLog(@"WARNWARN: Unknown Storage Provider!");
    return nil;
}

#else

+ (id<SafeStorageProvider>)getStorageProviderFromProviderId:(StorageProvider)providerId {
    [NSException raise:@"Storage Provider Called From AutoFill!!" format:@"Very Bad"];
    return nil;
}

#endif

+ (NSString*)getStorageDisplayName:(METADATA_PTR )database {
    return [SafeStorageProviderFactory getDisplayNameForProvider:database.storageProvider database:database];
}

+ (NSString*)getStorageDisplayNameForProvider:(StorageProvider)provider {
    return [SafeStorageProviderFactory getDisplayNameForProvider:provider database:nil];
}

+ (NSString*)getDisplayNameForProvider:(StorageProvider)provider database:(METADATA_PTR _Nullable )database {
    NSString* _displayName;
    
    if (provider == kiCloud) {
        _displayName = NSLocalizedString(@"storage_provider_name_icloud", @"iCloud");
        if([_displayName isEqualToString:@"storage_provider_name_icloud"]) {
            _displayName = @"iCloud";
        }
    }
#if TARGET_OS_IPHONE
    else if (provider == kLocalDevice) {
        if (database) {
            _displayName = [LocalDeviceStorageProvider.sharedInstance isUsingSharedStorage:database] ?
            NSLocalizedString(@"autofill_safes_vc_storage_local_name", @"Local") :
            NSLocalizedString(@"autofill_safes_vc_storage_local_docs_name", @"Local (Documents)");
        }
        else {
            _displayName = NSLocalizedString(@"storage_provider_name_local_device", @"Local Device");
            if([_displayName isEqualToString:@"storage_provider_name_local_device"]) {
                _displayName = @"Local Device";
            }
        }
    }
    else if ( provider == kWiFiSync ) {
        return NSLocalizedString(@"storage_provider_name_wifi_sync", @"Wi-Fi Sync");
    }
#else
    else if (provider == kMacFile) {
        if (database) {
            if ( [database.fileUrl.scheme isEqualToString:kStrongboxSyncManagedFileUrlScheme] ) {
                _displayName = NSLocalizedString(@"storage_provider_name_mac_file_short", @"File");
            }
            else {
                _displayName = NSLocalizedString(@"storage_provider_name_mac_file_short", @"File");
                _displayName = [_displayName stringByAppendingString:@"*"];
            }
        }
        else {
            _displayName = NSLocalizedString(@"storage_provider_name_mac_file_short", @"File");
        }
    }
#endif
    else if (provider == kGoogleDrive) {
        _displayName = NSLocalizedString(@"storage_provider_name_google_drive", @"Google Drive");
        if([_displayName isEqualToString:@"storage_provider_name_google_drive"]) {
            _displayName = @"Google Drive";
        }
    }
    else if (provider == kDropbox) {
        _displayName = NSLocalizedString(@"storage_provider_name_dropbox", @"Dropbox");
        if([_displayName isEqualToString:@"storage_provider_name_dropbox"]) {
            _displayName = @"Dropbox";
        }
        return _displayName;
    }
    else if( provider == kTwoDrive ) {
        _displayName = NSLocalizedString(@"storage_provider_name_onedrive", @"OneDrive");
        if([_displayName isEqualToString:@"storage_provider_name_onedrive"]) {
            _displayName = @"OneDrive";
        }
    }
    else if(provider == kFilesAppUrlBookmark) {
        _displayName = NSLocalizedString(@"storage_provider_name_ios_files", @"iOS Files");
        if([_displayName isEqualToString:@"storage_provider_name_ios_files"]) {
            _displayName = @"iOS Files";
        }
    }
    else if(provider == kSFTP) {
        _displayName = NSLocalizedString(@"storage_provider_name_sftp", @"SFTP");
        if([_displayName isEqualToString:@"storage_provider_name_sftp"]) {
            _displayName = @"SFTP";
        }
    }
    else if(provider == kWebDAV) {
#if TARGET_OS_IPHONE
        _displayName = NSLocalizedString(@"storage_provider_name_webdav", @"WebDAV");
#else
        _displayName = @"DAV";
#endif
    }
    else {
        _displayName = @"SafeStorageProviderFactory::getDisplayName Unknown";
    }
    
    return _displayName;
}

+ (NSString*)getIconForProvider:(StorageProvider)provider {
    if (provider == kiCloud) {
        return @"cloud";
    }
#if TARGET_OS_IPHONE
    else if (provider == kLocalDevice) {
        return @"iphone_x";
    }
#else
    else if (provider == kMacFile) {
        return @"lock";
    }
#endif
    else if (provider == kGoogleDrive) {
        return @"google-drive-2021";
    }
    else if (provider == kDropbox) {
        return @"Dropbox-2021";
    }
    else if(provider == kTwoDrive) {
        return @"onedrive-2021";
    }
    else if(provider == kFilesAppUrlBookmark) {
        return @"lock";
    }
    else if(provider == kSFTP) {
        return @"cloud-sftp";
    }
    else if(provider == kWebDAV) {
        return @"cloud-webdav";
    }
    else {
        return @"SafeStorageProviderFactory::getIcon Unknown";
    }
}

#if TARGET_OS_IPHONE
+ (IMAGE_TYPE_PTR)getImageForProvider:(StorageProvider)provider {
    return [self getImageForProvider:provider database:nil];
}

+ (IMAGE_TYPE_PTR)getImageForProvider:(StorageProvider)provider database:(METADATA_PTR)database {
    if (provider == kWiFiSync) {
        UIImage* image = [UIImage systemImageNamed:@"externaldrive.fill.badge.wifi"];
        
        if (@available(iOS 15.0, *)) {
            BOOL isLive = NO;
            if ( database ) {
#ifndef IS_APP_EXTENSION
                NSString* serverName = [WiFiSyncStorageProvider.sharedInstance getWifiSyncServerNameFromDatabaseMetadata:database];
                if ( serverName ) {
                    isLive = [WiFiSyncBrowser.shared serverIsPresent:serverName];
                }
#endif
            }
            
            UIImageSymbolConfiguration* config = [UIImageSymbolConfiguration configurationWithPaletteColors:@[isLive ? UIColor.systemGreenColor : UIColor.systemGrayColor, UIColor.systemBlueColor]];
            
            return [image imageByApplyingSymbolConfiguration:config];
        }

        
        return image;
    }
    else {
        NSString* name = [self getIconForProvider:provider];
        return [UIImage imageNamed:name];
    }
}
#else
+ (IMAGE_TYPE_PTR)getImageForProvider:(StorageProvider)provider {
    if (provider == kiCloud) {
        return [NSImage imageWithSystemSymbolName:@"icloud.fill" accessibilityDescription:nil];
    }
    else if (provider == kMacFile) {
        if (@available(macOS 12.0, *)) {
            return [NSImage imageWithSystemSymbolName:@"lock.laptopcomputer" accessibilityDescription:nil];
        } else {
            return [NSImage imageNamed:@"lock"];
        }
    }
    else if (provider == kGoogleDrive) {
        return [NSImage imageNamed:@"google-drive-2021"];
    }
    else if (provider == kDropbox) {
        return [NSImage imageNamed:@"Dropbox-2021"];
    }
    else if(provider == kTwoDrive) {
        return [NSImage imageNamed:@"onedrive-2021"];
    }
    else if(provider == kFilesAppUrlBookmark) {
        return [NSImage imageNamed:@"lock"];
    }
    else if(provider == kSFTP) {
        return [NSImage imageNamed:@"cloud-sftp"];
    }
    else if(provider == kWebDAV) {
        return [NSImage imageNamed:@"cloud-webdav"];
    }
    else {
        NSLog(@"SafeStorageProviderFactory::getImageForProvider Unknown");
        return nil;
    }
}
#endif

@end

