//
//  MRMailSDK.m
//  mr-mail-sdk
//
//  Created by Aleksandr Karimov on 16/05/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "MRMailSDK.h"
#import "UIApplication+MRSDK.h"
#import "NSMutableURLRequest+MRSDK.h"
#import "NSData+MRSDK.h"
#import "MRMailAuthRedirectURLParser.h"
#import "MRSDKOAuthTokenResponseParser.h"
#import "MRMailAuthParameters.h"
#import "MRMailAuthParameters+Protected.h"
#import "MRMailAuthParameters+QueryItems.h"
#import "NSError+MRSDK.h"
#import "MRInternalAuthHandler.h"
#import "MRWebViewAuthHandler.h"
#import "MRSafariAuthHandler.h"
#import "MRSafariSessionAuthHandler.h"
#import "MRMailSDK+Private.h"


static NSString *const MRMailScheme = @"mr-mail-oauth2";
static NSString *const MRMailClientID = @"mail-ios";
static NSString *const MRMailDomain = @"mail.ru";
static NSString *const MRMailHost = @"authorize";
static NSString *const MRDefaultScope = @"userinfo";
static NSString *const MRDefaultState = @"default-state";

static NSString *const MROAuth2BaseURL = @"https://o2.mail.ru/";
static NSString *const MROAuth2TestBaseURL = @"https://o2.test.mail.ru/";
static NSString *const MROAuth2AuthorizationURLPath = @"login";
static NSString *const MROAuth2TokenURLPath = @"token";

static NSString *const MRCodeChallengeMethod = @"S256";
static const NSUInteger MRCodeVerifierSizeInBytes = 32;

@interface MRMailSDK () <MRInternalAuthHandlerDelegate>

@property (nonatomic, strong) id<MRInternalAuthHandler> authHandler;
@property (nonatomic) BOOL authorizationIsInProgress;
@property (nonatomic, copy) NSString *codeVerifier;
@property (nonatomic, strong) NSURLSession *urlSession;

@property (nonatomic, copy, readwrite) NSString *clientID;
@property (nonatomic, copy, readwrite) NSString *redirectURI;
@property (nonatomic, getter=isInternalProofKeyForCodeExchangeEnabled, assign) NSNumber *internalProofKeyForCodeExchangeEnabled;

@end

@implementation MRMailSDK

#pragma mark - shared instance

+ (instancetype)sharedInstance {
    static MRMailSDK *sharedSdkInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSdkInstance = [[self alloc] init_];
    });
    return sharedSdkInstance;
}

#pragma mark - private init

- (instancetype)init_ {
    return [super init];
}

#pragma mark - public

- (BOOL)initializeWithClientID:(NSString *)clientID
                   redirectURI:(NSString *)redirectURI {
    NSCParameterAssert(clientID != nil);
    NSCParameterAssert(redirectURI != nil && ![redirectURI containsString:@"_"]);
    if (!clientID || !redirectURI || [redirectURI containsString:@"_"]) {
        return NO;
    }
    self.clientID = clientID;
    self.redirectURI = redirectURI;
    return YES;
}

- (void)authorize {
    NSAssert(self.isInitialized, @"MRMailSDK should be initialized");

    if ([self abortStartingAuthorizationIfNeeded]) {
        return;
    }

    self.authorizationIsInProgress = YES;

    [self authorizeNonInteractivelyWithCompletionHandler:^(NSString *authorizationCode) {
        id<MRMailSDKUIDelegate> delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(mrMailSDKWillDispatch:)]) {
            [delegate mrMailSDKWillDispatch:self];
        }

        if (authorizationCode) {
            [self handleAuthorizationCompletionWithCode:authorizationCode];
        } else {
            [self authorizeInteractively];
        }
    }];
}

- (void)authorizeInternally {
    self.usesMailApplication = NO;
    [self authorize];
}

- (void)cancelAuthorization {
    if (!self.authorizationIsInProgress) {
        return;
    }
    self.authorizationIsInProgress = NO;

    NSURLSession *urlSession = self.urlSession;
    self.urlSession = nil;
    [urlSession invalidateAndCancel];

    [self.authHandler cancel];
    [self completeWithError:NSError.mrsdk_canceledByUserError];
}

- (void)forceLogout {
    [self cancelAuthorization];
    // clear stored OAuth2 cookies
    NSHTTPCookieStorage *storage = NSHTTPCookieStorage.sharedHTTPCookieStorage;
    [storage.cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if ([cookie.domain containsString:MRMailDomain]) {
            [storage deleteCookie:cookie];
        }
    }];
    WKWebsiteDataStore *dataStore = WKWebsiteDataStore.defaultDataStore;
    [dataStore fetchDataRecordsOfTypes:WKWebsiteDataStore.allWebsiteDataTypes
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> *dataRecords) {
                         [dataRecords enumerateObjectsUsingBlock:^(WKWebsiteDataRecord *record, NSUInteger idx, BOOL *stop) {
                             if ([record.displayName containsString:MRMailDomain]) {
                                 [dataStore removeDataOfTypes:record.dataTypes
                                               forDataRecords:@[record] 
                                            completionHandler:^{}];
                             }
                         }];
                     }];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    NSCAssert(self.isInitialized, @"MRMailSDK should be initialized");
    if (!self.isInitialized) {
        return NO;
    }
    if (!self.authorizationIsInProgress) {
        NSError *error = [NSError mrsdk_unauthorizedApplicationError];
        [self.delegate mrMailSDK:self authorizationDidFailWithError:error];
        return NO;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url
                                             resolvingAgainstBaseURL:NO];
    if ([self.authHandler handleURL:url sourceApplication:sourceApplication]) {
        return YES;
    }
    if ([components.scheme isEqualToString:self.returnScheme]) {
        [self processReceivedMailAppResults:components.queryItems];
        return YES;
    }
    return NO;
}

- (void)setInternalAuthMode:(MRMailSDKInternalAuthMode)internalAuthMode {
    if (_internalAuthMode == internalAuthMode) {
        return;
    }
    _internalAuthMode = internalAuthMode;
    _authHandler = nil;
}

- (BOOL)isProofKeyForCodeExchangeEnabled {
    BOOL isEnabled = NO;
    if (self.internalProofKeyForCodeExchangeEnabled != nil) {
        isEnabled = self.internalProofKeyForCodeExchangeEnabled.boolValue;
    } else {
        isEnabled = self.resultType != MRSDKAuthorizationResultTypeCode;
    }
    return isEnabled;
}

- (void)setProofKeyForCodeExchangeEnabled:(BOOL)proofKeyForCodeExchangeEnabled {
    self.internalProofKeyForCodeExchangeEnabled = @(proofKeyForCodeExchangeEnabled);
}


#pragma mark - MRInternalAuthHandlerDelegate

- (void)authHandlerShouldPresentViewController:(UIViewController *)controller {
    [_uiDelegate mrMailSDK:self shouldPresentViewController:controller];
}

- (void)authHandlerDidFinishWithCode:(NSString *)code {
    [self handleAuthorizationCompletionWithCode:code];
}

- (void)authHandlerDidFailWithError:(NSError *)error {
    [self completeWithError:error];
}

- (void)authHandlerWillDismissViewController:(UIViewController *)controller {
    id<MRMailSDKUIDelegate> delegate = self.uiDelegate;
    if ([delegate respondsToSelector:@selector(mrMailSDK:willDismissViewController:)]) {
        [delegate mrMailSDK:self willDismissViewController:controller];
    }
}

- (void)authHandlerDidDismissViewController:(UIViewController *)controller {
    id<MRMailSDKUIDelegate> delegate = self.uiDelegate;
    if ([delegate respondsToSelector:@selector(mrMailSDK:willDismissViewController:)]) {
        [delegate mrMailSDK:self didDismissViewController:controller];
    }
}

#pragma mark - private

- (BOOL)isInitialized {
    NSCAssert(self.clientID && self.redirectURI, @"SDK is not initialized, call initialize before work with SDK");
    return self.clientID && self.redirectURI;
}

- (void)authorizeInteractively {
    if (self.proofKeyForCodeExchangeEnabled) {
        self.codeVerifier = [self generateCodeVerifier];
    }
    if (self.usesMailApplication && self.isExternalAuthAvailable) {
        [[UIApplication mrsdk_sharedApplication] openURL:self.openInMailURL];
    } else {
        [self performInternalAuthorization];
    }
}

- (BOOL)isExternalAuthAvailable {
    return self.returnScheme && [[UIApplication mrsdk_sharedApplication] canOpenURL:self.openInMailURL];
}

- (BOOL)abortStartingAuthorizationIfNeeded {
    NSError *error = nil;
    if (!self.isInitialized) {
        error = [NSError mrsdk_uninitializedError];
    } else if (self.authorizationIsInProgress) {
        error = [NSError mrsdk_authorizationAlreadyInProgressError];
    } else if (self.resultType == MRSDKAuthorizationResultTypeToken && self.clientSecret == nil) {
        error = [NSError errorWithDomain:kMRMailSDKErrorDomain code:kMRSDKUninitializedErrorCode userInfo:@{
            NSHelpAnchorErrorKey: @"Client secret is required for authorization with token result",
        }];
    }
    if (error) {
        [self.delegate mrMailSDK:self authorizationDidFailWithError:error];
    }
    return (error != nil);
}

- (MRMailAuthParameters *)authorizationParameters {
    MRMailAuthParameters *authParameters = [MRMailAuthParameters new];
    authParameters.clientId = self.clientID;
    authParameters.redirectUri = self.redirectURI;
    authParameters.scopes = self.scopes.count > 0 ? [self.scopes componentsJoinedByString:@" "] : MRDefaultScope;
    authParameters.state = self.state ?: MRDefaultState;
    authParameters.loginHint = self.loginHint;

    if (self.codeVerifier) {
        authParameters.codeChallenge = [self codeChallengeWithCodeVerifier:self.codeVerifier];
        authParameters.challengeMethod = MRCodeChallengeMethod;
    }

    return authParameters;
}

- (void)processReceivedMailAppResults:(NSArray<NSURLQueryItem *> *)items {
    __block NSString *code = nil;
    __block NSString *errorCode = nil;
    __block NSString *errorDescription = nil;
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.name isEqualToString:@"code"]) {
            code = item.value;
        }
        else if ([item.name isEqualToString:@"error"]) {
            errorCode = item.value;
        }
        else if ([item.name isEqualToString:@"error-description"]) {
            errorDescription = item.value;
        }
    }];
    if (code) {
        [self handleAuthorizationCompletionWithCode:code];
    }
    else if (errorCode) {
        NSError *error = [NSError mrsdk_errorFromCode:errorCode withDescription:errorDescription];
        if (error.code == kMRSDKUnauthorizedApplicationErrorCode ||
            error.code == kMRSDKExternalOAuthDisabledErrorCode ||
            error.code == kMRSDKExternalOAuthRefuseErrorCode) {
            // external авторизация в MRMail для данного приложения не разрешена либо приложение не может в данный момент авторизовать,
            // пробуем сделать internal авторизацию
            [self performInternalAuthorization];
        }
        else {
            [self completeWithError:error];
        }
    }
}

- (void)authorizeNonInteractivelyWithCompletionHandler:(void(^)(NSString *authorizationCode))comletionHandler {
    comletionHandler(nil);
}

- (void)performInternalAuthorization {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.OAuth2AuthorizationURL resolvingAgainstBaseURL:YES];
    NSArray<NSURLQueryItem *> *queryItems = self.authorizationParameters.mrsdk_queryItems;
    components.queryItems = [queryItems arrayByAddingObject:[NSURLQueryItem queryItemWithName:@"response_type" value:@"code"]];
    [self.authHandler performAuthorizationWithURL:components.URL];
}

- (id<MRInternalAuthHandler>)authHandler {
    if (!_authHandler) {
        id<MRInternalAuthHandler> authHandler;
        MRMailAuthRedirectURLParser *redirectURLParser = [[MRMailAuthRedirectURLParser alloc] initWithRedirectURI:self.redirectURI];

        if (self.internalAuthMode == kMRMailSDKInternalAuthMode_WebKit) {
            authHandler = [[MRWebViewAuthHandler alloc] initWithRedirectURLParser:redirectURLParser];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        } else if (@available(iOS 11.0, *)) {
            authHandler = [[MRSafariSessionAuthHandler alloc] initWithRedirectURI:self.redirectURI redirectURLParser:redirectURLParser];
#endif
        } else {
            authHandler = [[MRSafariAuthHandler alloc] initWithRedirectURLParser:redirectURLParser];
        }
        authHandler.delegate = self;
        _authHandler = authHandler;
    }
    return _authHandler;
}

- (void)handleAuthorizationCompletionWithCode:(NSString *)authorizationCode {
    if (self.resultType == MRSDKAuthorizationResultTypeCode) {
        MRSDKAuthorizationResult *result = [[MRSDKAuthorizationResult alloc] initWithAuthorizationCode:authorizationCode codeVerifier:self.codeVerifier];
        [self completeWithAuthorizationResult:result];
    } else {
        [self requestTokenWithAuthorizationCode:authorizationCode];
    }
}

#pragma mark - Private: Token Request

- (void)requestTokenWithAuthorizationCode:(NSString *)authorizationCode {
    NSURLRequest *request = [self tokenRequestWithAuthorizationCode:authorizationCode];

    self.urlSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration delegate:nil delegateQueue:NSOperationQueue.mainQueue];
    NSURLSessionTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (self.urlSession == nil) {
            return;
        }
        if (error) {
            [self completeWithError:NSError.mrsdk_networkError];
            return;
        }
        if (!data) {
            [self completeWithError:NSError.mrsdk_OAuthError];
            return;
        }
        [self handleTokenResponseData:data];
    }];
    [task resume];
}

- (void)handleTokenResponseData:(NSData *)responseData {
    MRSDKAuthorizationResult *authorizationResult;
    NSError *apiError;

    MRSDKOAuthTokenResponseParser *parser = [[MRSDKOAuthTokenResponseParser alloc] init];
    BOOL isParsed = [parser getAuthorizationResult:&authorizationResult apiError:&apiError fromTokenResponseData:responseData];
    if (isParsed && authorizationResult) {
        [self completeWithAuthorizationResult:authorizationResult];
    } else {
        [self completeWithError:(apiError ?: NSError.mrsdk_OAuthError)];
    }
}

- (NSURLRequest *)tokenRequestWithAuthorizationCode:(NSString *)authorizationCode {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.OAuth2TokenURL];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if (self.clientID && self.clientSecret) {
        [request mrsdk_addBasicAccessAuthenticationHeaderFieldWithUsername:self.clientID password:self.clientSecret];
    }

    NSMutableArray<NSURLQueryItem *> *bodyParameters = [NSMutableArray arrayWithArray:@[
        [NSURLQueryItem queryItemWithName:@"code" value:authorizationCode],
        [NSURLQueryItem queryItemWithName:@"grant_type" value:@"authorization_code"],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:self.redirectURI],
    ]];
    if (self.codeVerifier) {
        [bodyParameters addObject:[NSURLQueryItem queryItemWithName:@"code_verifier" value:self.codeVerifier]];
    }
    [request mrsdk_setHTTPBodyQueryItems:bodyParameters];

    return request;
}

#pragma mark - Private: Proof Key for Code Exchange

- (NSString *)generateCodeVerifier {
    NSData *randomData = [NSData mrsdk_randomlyFilledDataWithLength:MRCodeVerifierSizeInBytes];
    if (!randomData) {
        return nil;
    }
    return [[NSString alloc] initWithData:randomData.mrsdk_base64URLNoPaddingEncoded encoding:kNilOptions];
}

- (NSString *)codeChallengeWithCodeVerifier:(NSString *)codeVerifier {
    NSData *verifierData = [codeVerifier dataUsingEncoding:NSUTF8StringEncoding];
    if (!verifierData) {
        return nil;
    }
    NSData *hashedVerifierData = verifierData.mrsdk_SHA256Hash.mrsdk_base64URLNoPaddingEncoded;

    return [[NSString alloc] initWithData:hashedVerifierData encoding:NSUTF8StringEncoding];
}

#pragma mark - Private: URLs

- (NSURL *)OAuth2AuthorizationURL {
    return (NSURL *_Nonnull)[NSURL URLWithString:MROAuth2AuthorizationURLPath relativeToURL:self.OAuth2BaseURL];
}

- (NSURL *)OAuth2TokenURL {
    return (NSURL *_Nonnull)[NSURL URLWithString:MROAuth2TokenURLPath relativeToURL:self.OAuth2BaseURL];
}

- (NSURL *)OAuth2BaseURL {
    NSString *urlString = self.useTestHosts ? MROAuth2TestBaseURL : MROAuth2BaseURL;
    return (NSURL *_Nonnull)[NSURL URLWithString:urlString];
}

- (NSURL *)openInMailURL {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = MRMailScheme;
    components.host = MRMailHost;

    NSArray<NSURLQueryItem *> *queryItems = self.authorizationParameters.mrsdk_queryItems;
    if (self.returnScheme) {
        queryItems = [queryItems arrayByAddingObject:[NSURLQueryItem queryItemWithName:@"return_scheme" value:self.returnScheme]];
    }
    components.queryItems = queryItems;

    return components.URL;
}

#pragma mark - Private: Completion Handlers

- (void)completeWithAuthorizationResult:(MRSDKAuthorizationResult *)authorizationResult {
    [self cleanUp];

    id<MRMailSDKDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(mrMailSDK:authorizationDidFinishWithResult:)]) {
        [delegate mrMailSDK:self authorizationDidFinishWithResult:authorizationResult];
    } else if ([delegate respondsToSelector:@selector(mrMailSDK:authorizationDidFinishWithCode:)]) {
        if (authorizationResult.type == MRSDKAuthorizationResultTypeCode && !authorizationResult.codeVerifier) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [delegate mrMailSDK:self authorizationDidFinishWithCode:authorizationResult.authorizationCode];
#pragma clang diagnostic pop
        } else {
            if (authorizationResult.type == MRSDKAuthorizationResultTypeCode) {
                NSLog(@"[MRMailSDK] Use `mrMailSDK:authorizationDidFinishWithResult:` to get the code verifier");
            } else {
                NSLog(@"[MRMailSDK] Use `mrMailSDK:authorizationDidFinishWithResult:` to get the token result");
            }
            [self completeWithError:NSError.mrsdk_uninitializedError];
        }
    }
}

- (void)completeWithError:(NSError *)error {
    [self cleanUp];
    [self.delegate mrMailSDK:self authorizationDidFailWithError:error];
}

- (void)cleanUp {
    self.urlSession = nil;
    self.codeVerifier = nil;
    self.authorizationIsInProgress = NO;
}

@end
