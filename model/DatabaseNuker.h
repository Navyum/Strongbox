//
//  DatabaseNuke.h
//  Strongbox
//
//  Created by Strongbox on 07/05/2024.
//  Copyright © 2024 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDatabasePreferences.h"

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseNuker : NSObject

+ (void)nuke:(METADATA_PTR)database;

@end

NS_ASSUME_NONNULL_END
