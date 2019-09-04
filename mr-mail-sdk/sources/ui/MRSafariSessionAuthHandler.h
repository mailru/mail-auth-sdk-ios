//
//  MRSafariSessionAuthHandler.h
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 24/07/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
#import "MRInternalAuthHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class MRMailAuthRedirectURLParser;

API_AVAILABLE(ios(11.0))
@interface MRSafariSessionAuthHandler : NSObject <MRInternalAuthHandler>

- (instancetype)initWithRedirectURI:(NSString *)redirectURI redirectURLParser:(MRMailAuthRedirectURLParser *)redirectURLParser NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif
