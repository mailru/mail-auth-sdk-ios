//
//  NSMutableURLRequest+MRSDK.h
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 17/06/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableURLRequest (MRSDK)

- (void)mrsdk_setHTTPBodyQueryItems:(NSArray<NSURLQueryItem *> *)queryItems;

- (BOOL)mrsdk_addBasicAccessAuthenticationHeaderFieldWithUsername:(NSString *)userName password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
