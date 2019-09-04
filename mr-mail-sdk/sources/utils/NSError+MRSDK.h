//
// Created by Aleksandr Karimov on 17/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (MRSDK)

+ (NSError *)mrsdk_uninitializedError;
+ (NSError *)mrsdk_incorrectClientIdError;
+ (NSError *)mrsdk_authorizationAlreadyInProgressError;
+ (NSError *)mrsdk_OAuthError;
+ (NSError *)mrsdk_networkError;
+ (NSError *)mrsdk_canceledByUserError;
+ (NSError *)mrsdk_unauthorizedApplicationError;
+ (NSError *)mrsdk_externalOAuthDisabledError;

+ (nullable NSError *)mrsdk_errorFromCode:(NSString *)code
                             withDescription:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
