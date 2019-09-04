//
//  MRSafariSessionAuthHandler.m
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 24/07/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
#import <SafariServices/SafariServices.h>

#import "MRSafariSessionAuthHandler.h"
#import "MRMailAuthRedirectURLParser.h"

#import "NSError+MRSDK.h"

@interface MRSafariSessionAuthHandler ()
@property (copy, nonatomic, readonly) NSString *redirectURI;
@property (strong, nonatomic, readonly) MRMailAuthRedirectURLParser *redirectURLParser;
@property (strong, nonatomic) SFAuthenticationSession *authenticationSession;
@end

@implementation MRSafariSessionAuthHandler

@synthesize delegate = _delegate;

- (instancetype)initWithRedirectURI:(NSString *)redirectURI redirectURLParser:(MRMailAuthRedirectURLParser *)redirectURLParser {
    NSParameterAssert(redirectURI);
    NSParameterAssert(redirectURLParser);
    self = [super init];
    if (self) {
        _redirectURI = [redirectURI copy];
        _redirectURLParser = redirectURLParser;
    }
    return self;
}

#pragma mark - MRInternalAuthHandler

- (void)performAuthorizationWithURL:(NSURL *)url {
    NSParameterAssert(url);
    NSAssert(!self.authenticationSession, @"Class not supports multiple simultaneously authorizations");

    NSString *scheme = [NSURL URLWithString:self.redirectURI].scheme;
    self.authenticationSession = [[SFAuthenticationSession alloc] initWithURL:url callbackURLScheme:scheme completionHandler:^(NSURL *callbackURL, NSError *error) {
        [self handleCallbackURL:callbackURL error:error];
    }];
    [self.authenticationSession start];
}

- (void)cancel {
    [self.authenticationSession cancel];
    self.authenticationSession = nil;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication {
    return NO;
}

#pragma mark - Private

- (void)handleCallbackURL:(NSURL *)url error:(NSError *)error {
    self.authenticationSession = nil;

    id<MRInternalAuthHandlerDelegate> delegate = self.delegate;
    if ([error.domain isEqualToString:SFAuthenticationErrorDomain] && error.code == SFAuthenticationErrorCanceledLogin) {
        [delegate authHandlerDidFailWithError:NSError.mrsdk_canceledByUserError];
        return;
    }

    NSString *code;
    NSError *parsedError;
    [self.redirectURLParser parseURL:url code:&code error:&parsedError];
    if (code) {
        [delegate authHandlerDidFinishWithCode:code];
    } else {
        [delegate authHandlerDidFailWithError:parsedError];
    }
}

@end

#endif
