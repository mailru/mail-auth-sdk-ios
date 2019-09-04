//
//  NSBundle+MRSDK.h
//  mr-mail-sdk
//
//  Created by Nikolay Morev on 22/03/2018.
//  Copyright © 2018 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (MRSDK)

@property (nonatomic, readonly, class) NSBundle *mrsdk_UIResourcesBundle;

@end

NS_ASSUME_NONNULL_END
