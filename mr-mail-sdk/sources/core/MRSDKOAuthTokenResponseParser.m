//
//  MRSDKOAuthTokenResponseParser.m
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 07/08/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import "MRSDKOAuthTokenResponseParser.h"
#import "MRSDKAuthorizationResult.h"
#import "MRMailSDKConstants.h"

#import "NSError+MRSDK.h"

@implementation MRSDKOAuthTokenResponseParser

- (BOOL)getAuthorizationResult:(out MRSDKAuthorizationResult **)authorizationResult apiError:(out NSError **)apiError fromTokenResponseData:(NSData *)responseData {
    NSParameterAssert(responseData);

    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:NULL];
    if (![responseJSON isKindOfClass:NSDictionary.class]) {
        return NO;
    }

    MRSDKAuthorizationResult *parsedAuthorizationResult = [self authorizationResultFromResponse:responseJSON];
    if (parsedAuthorizationResult) {
        if (authorizationResult) {
            *authorizationResult = parsedAuthorizationResult;
        }
        return YES;
    }

    NSError *parsedApiError = [self errorFromResponse:responseJSON];
    if (parsedApiError) {
        if (apiError) {
            *apiError = parsedApiError;
        }
        return YES;
    }

    return NO;
}

#pragma mark - Private

- (NSError *)errorFromResponse:(NSDictionary *)response {
    NSNumber *apiErrorCode = [self objectWithClass:NSNumber.class key:@"error_code" fromResponse:response];
    if (apiErrorCode == nil) {
        return nil;
    }
    NSString *helpAnchor = [self objectWithClass:NSString.class key:@"error_description" fromResponse:response];
    if (!helpAnchor) {
        helpAnchor = [self objectWithClass:NSString.class key:@"error" fromResponse:response] ?: apiErrorCode.stringValue;
    }
    NSInteger sdkErrorCode = 0;
    switch (apiErrorCode.integerValue) {
        case 1:
            sdkErrorCode = kMRSDKIncorrectClientIdErrorCode;
            break;
        default:
            sdkErrorCode = kMRSDKOAuthErrorCode;
    }
    return [NSError errorWithDomain:kMRMailSDKErrorDomain code:sdkErrorCode userInfo:@{
        NSHelpAnchorErrorKey: helpAnchor,
    }];
}

- (MRSDKAuthorizationResult *)authorizationResultFromResponse:(NSDictionary *)response {
    NSString *refreshToken = [self objectWithClass:NSString.class key:@"refresh_token" fromResponse:response];
    if (!refreshToken) {
        return nil;
    }
    NSString *accessToken = [self objectWithClass:NSString.class key:@"access_token" fromResponse:response];
    if (!accessToken) {
        return nil;
    }
    NSNumber *expiresIn = [self objectWithClass:NSNumber.class key:@"expires_in" fromResponse:response];
    NSDate *expirationDate;
    if (expiresIn != nil) {
        expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn.doubleValue];
    }

    return [[MRSDKAuthorizationResult alloc] initWithRefreshToken:refreshToken accessToken:accessToken accessTokenExpirationDate:expirationDate];
}

- (id)objectWithClass:(Class)objectClass key:(NSString *)key fromResponse:(NSDictionary *)response {
    id object = response[key];
    if (![object isKindOfClass:objectClass]) {
        return nil;
    }
    return object;
}

@end
