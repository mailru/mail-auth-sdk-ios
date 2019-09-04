//
//  NSData+MRSDK.h
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 06/08/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (MRSDK)

@property (nonatomic, readonly, copy) NSData *mrsdk_SHA256Hash;

@property (nonatomic, readonly, copy) NSData *mrsdk_base64URLNoPaddingEncoded;

+ (nullable NSData *)mrsdk_randomlyFilledDataWithLength:(NSUInteger)length;

@end

NS_ASSUME_NONNULL_END
