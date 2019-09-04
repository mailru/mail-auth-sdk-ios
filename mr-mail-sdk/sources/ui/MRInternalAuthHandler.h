//
// Created by Aleksandr Karimov on 17/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRMailAuthParameters;

NS_ASSUME_NONNULL_BEGIN

@protocol MRInternalAuthHandlerDelegate <NSObject>
- (void)authHandlerShouldPresentViewController:(UIViewController *)controller;
- (void)authHandlerWillDismissViewController:(UIViewController *)controller;
- (void)authHandlerDidDismissViewController:(UIViewController *)controller;
- (void)authHandlerDidFinishWithCode:(NSString *)code;
- (void)authHandlerDidFailWithError:(NSError *)error;
@end

@protocol MRInternalAuthHandler <NSObject>

@property (nonatomic, weak, nullable) id<MRInternalAuthHandlerDelegate> delegate;

- (void)performAuthorizationWithURL:(NSURL *)url;
- (void)cancel;

- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

@end

NS_ASSUME_NONNULL_END
