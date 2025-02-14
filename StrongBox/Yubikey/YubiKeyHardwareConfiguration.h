//
//  YubiKeyHardwareConfiguration.h
//  Strongbox
//
//  Created by Mark on 07/02/2020.
//  Copyright © 2014-2021 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, YubiKeyHardwareMode) {
    kNoYubiKey,
    kNfc,
    kMfi,
    kVirtual,
};

typedef NS_ENUM (NSInteger, YubiKeyHardwareSlot) {
    kSlot1,
    kSlot2,
};

NS_ASSUME_NONNULL_BEGIN

@interface YubiKeyHardwareConfiguration : NSObject

+ (instancetype)defaults;
- (instancetype)clone;

+ (instancetype)fromJsonSerializationDictionary:(NSDictionary*)jsonDictionary;
- (NSDictionary *)getJsonSerializationDictionary;

@property YubiKeyHardwareMode mode;
@property YubiKeyHardwareSlot slot;
@property (nullable) NSString* virtualKeyIdentifier;

@end

NS_ASSUME_NONNULL_END
