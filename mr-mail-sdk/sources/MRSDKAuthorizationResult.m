//
//  MRSDKAuthorizationResult.m
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 07/08/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import "MRSDKAuthorizationResult.h"

@implementation MRSDKAuthorizationResult

- (instancetype)initWithAuthorizationCode:(NSString *)authorizationCode codeVerifier:(NSString *)codeVerifier {
    self = [super init];
    if (self) {
        _type = MRSDKAuthorizationResultTypeCode;
        _authorizationCode = [authorizationCode copy];
        _codeVerifier = [codeVerifier copy];
    }
    return self;
}

- (instancetype)initWithRefreshToken:(NSString *)refreshToken accessToken:(NSString *)accessToken accessTokenExpirationDate:(NSDate *)accessTokenExpirationDate {
    self = [super init];
    if (self) {
        _type = MRSDKAuthorizationResultTypeToken;
        _refreshToken = [refreshToken copy];
        _accessToken = [accessToken copy];
        _accessTokenExpirationDate = [accessTokenExpirationDate copy];
    }
    return self;
}

@end
