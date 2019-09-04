//
//  MRSDKOAuthTokenResponseParser.h
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 07/08/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MRSDKAuthorizationResult;

@interface MRSDKOAuthTokenResponseParser : NSObject

- (BOOL)getAuthorizationResult:(out MRSDKAuthorizationResult *_Nullable *_Nullable)authorizationResult
                      apiError:(out NSError **)error
         fromTokenResponseData:(NSData *)responseData;

@end

NS_ASSUME_NONNULL_END
