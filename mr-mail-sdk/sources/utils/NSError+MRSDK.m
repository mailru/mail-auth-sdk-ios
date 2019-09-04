//
// Created by Aleksandr Karimov on 17/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import "NSError+MRSDK.h"
#import "MRMailSDKConstants.h"

@implementation NSError (MRSDK)

#pragma mark - public


+ (NSError *)mrsdk_uninitializedError {
    return [self mrsdk_errorWithCode:kMRSDKUninitializedErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_incorrectClientIdError {
    return [self mrsdk_errorWithCode:kMRSDKIncorrectClientIdErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_authorizationAlreadyInProgressError {
    return [self mrsdk_errorWithCode:kMRSDKAuthorizationAlreadyInProgressErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_OAuthError {
    return [self mrsdk_errorWithCode:kMRSDKOAuthErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_networkError {
    return [self mrsdk_errorWithCode:kMRSDKNetworkErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_canceledByUserError {
    return [self mrsdk_errorWithCode:kMRSDKCanceledByUserErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_unauthorizedApplicationError {
    return [self mrsdk_errorWithCode:kMRSDKUnauthorizedApplicationErrorCode
                            userInfo:nil];
}

+ (NSError *)mrsdk_externalOAuthDisabledError {
    return [self mrsdk_errorWithCode:kMRSDKExternalOAuthDisabledErrorCode
                            userInfo:nil];
}

+ (instancetype)mrsdk_errorFromCode:(NSString *)code
                    withDescription:(NSString *)description {
    __auto_type codesMap = @{ @"network-error" : @(kMRSDKNetworkErrorCode),
                              @"oauth-error" : @(kMRSDKOAuthErrorCode),
                              @"already-in-progress" : @(kMRSDKAuthorizationAlreadyInProgressErrorCode),
                              @"canceled-by-user" : @(kMRSDKCanceledByUserErrorCode),
                              @"unauthorized-application" : @(kMRSDKUnauthorizedApplicationErrorCode),
                              @"oauth-disabled" : @(kMRSDKExternalOAuthDisabledErrorCode),
                              @"incorrect-client-id" : @(kMRSDKIncorrectClientIdErrorCode),
                              @"refuse-oauth" : @(kMRSDKExternalOAuthRefuseErrorCode)};
    if (!codesMap[code]) {
        return nil;
    }
    return [self mrsdk_errorWithCode:[codesMap[code] integerValue]
                            userInfo:@{ NSHelpAnchorErrorKey : description ?: code }];
}

#pragma mark - private

+ (NSError *)mrsdk_errorWithCode:(NSInteger)code
                        userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:kMRMailSDKErrorDomain
                               code:code
                           userInfo:userInfo];
}

@end
