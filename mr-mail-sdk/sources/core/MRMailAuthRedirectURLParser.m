//
//  MRMailAuthRedirectURLParser.m
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 24/07/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import "MRMailAuthRedirectURLParser.h"

#import "NSURL+MRSDK.h"
#import "NSError+MRSDK.h"

@interface MRMailAuthRedirectURLParser ()
@property (copy, nonatomic, readonly) NSString *redirectURI;
@end

@implementation MRMailAuthRedirectURLParser

- (instancetype)initWithRedirectURI:(NSString *)redirectURI {
    NSParameterAssert(redirectURI);
    self = [super init];
    if (self) {
        _redirectURI = [redirectURI copy];
    }
    return self;
}

- (BOOL)parseURL:(NSURL *)url code:(NSString **)code error:(NSError **)error {
    NSParameterAssert(url);
    NSString *hostName = url.mrsdk_urlWithoutQuery;
    if (![self.redirectURI isEqual:hostName]) {
        return NO;
    }
    NSDictionary<NSString *, NSString *> *queryParameters = url.mrsdk_GETParameters;
    NSString *internalCode = queryParameters[@"code"];
    if (internalCode.length > 0) {
        if (code) {
            *code = internalCode;
        }
    } else {
        NSString *errorCode = queryParameters[@"error"];
        NSError *internalError;
        if ([errorCode isEqualToString:@"access_denied"]) {
            internalError = NSError.mrsdk_canceledByUserError;
        } else {
            internalError = NSError.mrsdk_OAuthError;
        }
        if (error) {
            *error = internalError;
        }
    }
    return YES;
}

@end
