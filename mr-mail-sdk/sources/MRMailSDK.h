//
//  MRMailSDK.h
//  mr-mail-sdk
//
//  Created by Aleksandr Karimov on 16/05/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MRMailSDKConstants.h"
#import "MRSDKAuthorizationResult.h"

@class MRMailSDK;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MRMailSDKInternalAuthMode) {
    kMRMailSDKInternalAuthMode_Safari = 0, // use SKSafariViewController for internal authorization
    kMRMailSDKInternalAuthMode_WebKit      // use WKWebView for internal authorization
};

@protocol MRMailSDKDelegate <NSObject>

@optional
/**
 * Notifies about authorization was completed and returns authorization result
 */
- (void)mrMailSDK:(MRMailSDK *)sdk authorizationDidFinishWithResult:(MRSDKAuthorizationResult *)result;

/**
 * Notifies about error occurred during authorization
 * @param sdk - reference to MRMailSDK instance
 * @param error - NSError
 */
- (void)mrMailSDK:(MRMailSDK *)sdk authorizationDidFailWithError:(NSError *)error;

- (void)mrMailSDK:(MRMailSDK *)sdk authorizationDidFinishWithCode:(NSString *)code __attribute__((deprecated("Use `mrMailSDK:authorizationDidFinishWithResult:` instead")));

@end

@protocol MRMailSDKUIDelegate <NSObject>

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window.
 @param controller view controller that must be shown to user
 */
- (void)mrMailSDK:(MRMailSDK *)sdk shouldPresentViewController:(UIViewController *)controller;

@optional
/**
 * Called when a controller presented by SDK will be dismissed.
 */
- (void)mrMailSDK:(MRMailSDK *)sdk willDismissViewController:(UIViewController *)controller;

/**
 * Called when a controller presented by SDK did dismiss.
 */
- (void)mrMailSDK:(MRMailSDK *)sdk didDismissViewController:(UIViewController *)controller;

/**
 * The SDK flow has finished selecting how to proceed, and the UI should no longer display
 * a spinner or other "please wait" element.
 */
- (void)mrMailSDKWillDispatch:(MRMailSDK *)sdk;

@end

@interface MRMailSDK : NSObject

/**
 * Returns a shared MRMailSDK instance.
 */
+ (instancetype)sharedInstance;

/**
 * Configure required SDK parameters
 * @param clientID -  Client ID of the application (https://o2.mail.ru/docs/)
 * @param redirectURI - Redirect url in case of success authorization (https://o2.mail.ru/docs/), SHOULDN'T CONTAIN UNDERSCORE SYMBOLS
 * @return YES in success case, otherwise NO
 */
- (BOOL)initializeWithClientID:(NSString *)clientID
                   redirectURI:(NSString *)redirectURI;

/**
 * Flag means that authorization process is in progress
 */
@property (nonatomic, readonly) BOOL authorizationIsInProgress;
/**
 * The expected result type
 * default value – Code
 */
@property (nonatomic, assign) MRSDKAuthorizationResultType resultType;
/**
 * Client ID of the application (https://o2.mail.ru/docs/).
 * This property is REQUIRED for authorization.
 */
@property (nonatomic, copy, readonly) NSString *clientID;
/**
 * Client Secret of the application (https://o2.mail.ru/docs/)
 * This property is REQUIRED for authorization with Token result
 */
@property (nonatomic, nullable, copy) NSString *clientSecret;
/**
 * Redirect url in case of success authorization (https://o2.mail.ru/docs/).
 * This property is REQUIRED for authorization.
 */
@property (nonatomic, copy, readonly) NSString *redirectURI;

/**
 * returnScheme will be opened as result of MRMail (external) authorization
 * This property is OPTIONAL. If you set it, set it before calling authorize
 * If it is not set ONLY INTERNAL AUTHORIZATION IS AVAILABLE
 */
@property (nonatomic, copy) NSString *returnScheme;

/**
 * Scope of the token (https://o2.mail.ru/docs/).
 * This property is OPTIONAL. If you set it, set it before calling authorize
 */
@property (nonatomic, copy, nullable) NSArray<NSString *> *scopes;
/**
 * Flag enables PKCE (https://tools.ietf.org/html/rfc7636)
 * Default value - False for code authorization code result and True otherwize
 */
@property (nonatomic, getter=isProofKeyForCodeExchangeEnabled, assign) BOOL proofKeyForCodeExchangeEnabled;

/**
 * Additional string for redirect_uri (https://o2.mail.ru/docs/).
 * This property is OPTIONAL. If you set it, set it before calling authorize
 */
@property (nonatomic, copy, nullable) NSString *state;

/**
 * Flag enables authorization through mail application if it was installed
 * Default value - True
 */
@property (nonatomic, assign) BOOL usesMailApplication;

/**
 * Setup mode for for internal authorization
 * Default value - kMRMailSDKInternalAuthMode_Safari
 * If you set it, set it before calling authorize
 */
@property (nonatomic, assign) MRMailSDKInternalAuthMode internalAuthMode;

/**
 * The login hint that will be prefilled if possible
 */
@property (nonatomic, nullable, copy) NSString *loginHint;

/**
 * The object to be notified with sdk events (authorization is finished or failed).
 */
@property (nonatomic, weak, nullable) id<MRMailSDKDelegate> delegate;

/**
 * The object to be notified with UI events related to presentation.
 */
@property (nonatomic, weak, nullable) id<MRMailSDKUIDelegate> uiDelegate;

/**
 * Start authorization process.
 */
- (void)authorize;

/**
 * Cancel current authorization process
 */
- (void)cancelAuthorization;

/**
 * Clear all stored cookies and values for authorized accounts.
 */
- (void)forceLogout;

/**
 * This method should be called from your UIApplicationDelegate's application:openURL:options:
 * Returns YES if MRMailSDK handled this URL.
 */
- (BOOL)handleURL:(NSURL *)url
sourceApplication:(nullable NSString *)sourceApplication
       annotation:(nullable id)annotation;

/**
 * Start internal authorization (without MRMail application).
 */
- (void)authorizeInternally __attribute__((deprecated("use `usesMailApplicationUserAgent` flag instead")));

// Disable methods for instance creation, use sharedInstance instead
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
