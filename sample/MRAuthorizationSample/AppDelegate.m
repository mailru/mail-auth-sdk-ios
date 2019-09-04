//
//  AppDelegate.m
//  MRAuthorizationSample
//
//  Created by Aleksandr Karimov on 16/05/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import "AppDelegate.h"
#import <MRMailSDK/MRMailSDK.h>

static NSString *const kClientId = @"bddc421472584782aacd6d7549cbc31b";
static NSString *const kRedirectURI = @"sample-auth-callback://";
static NSString *const kReturnScheme = @"sample-auth-callback";

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initializeMailSdk];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    id annotation = options[UIApplicationOpenURLOptionsAnnotationKey];
    return [[MRMailSDK sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

#pragma mark - private

- (void)initializeMailSdk {
    MRMailSDK *mailSDK = [MRMailSDK sharedInstance];
    [mailSDK initializeWithClientID:kClientId 
                        redirectURI:kRedirectURI];
    mailSDK.returnScheme = kReturnScheme;
    mailSDK.internalAuthMode = kMRMailSDKInternalAuthMode_WebKit;
    mailSDK.proofKeyForCodeExchangeEnabled = YES;
    [mailSDK forceLogout];
}

@end
