//
// Created by Aleksandr Karimov on 19/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import "MRSafariAuthHandler.h"
#import "NSError+MRSDK.h"
#import <SafariServices/SafariServices.h>
#import "MRMailAuthRedirectURLParser.h"

@interface MRSafariAuthHandler () <SFSafariViewControllerDelegate>
@property (nonatomic, strong, readonly) MRMailAuthRedirectURLParser *redirectURLParser;
@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic, strong) NSURL *url;
@end

@implementation MRSafariAuthHandler
#pragma mark - MRInternalAuthHandler

@synthesize delegate = _delegate;

- (instancetype)initWithRedirectURLParser:(MRMailAuthRedirectURLParser *)redirectURLParser {
    NSParameterAssert(redirectURLParser);
    self = [super init];
    if (self) {
        _redirectURLParser = redirectURLParser;
    }
    return self;
}

- (void)performAuthorizationWithURL:(NSURL *)url {
    self.url = url;
    SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:url];
    viewController.delegate = self;
    self.safariViewController = viewController;
    [_delegate authHandlerShouldPresentViewController:viewController];
}

- (void)cancel {
    self.safariViewController.delegate = nil;
    [self.safariViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
    self.safariViewController = nil;
    self.url = nil;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication {
    if (![sourceApplication isEqualToString:@"com.apple.SafariViewService"]) {
        return NO;
    }
    NSString *code;
    NSError *error;
    if ([self.redirectURLParser parseURL:url code:&code error:&error]) {
        [self dismissViewController];
        id<MRInternalAuthHandlerDelegate> delegate = self.delegate;
        if (code) {
            [delegate authHandlerDidFinishWithCode:code];
        } else {
            [delegate authHandlerDidFailWithError:error];
        }
        return YES;
    }
    return NO;
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // пользователь нажал Done button
    [self dismissViewController];
    [_delegate authHandlerDidFailWithError:[NSError mrsdk_canceledByUserError]];

}

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    if (!didLoadSuccessfully) {
        [self dismissViewController];
        [_delegate authHandlerDidFailWithError:[NSError mrsdk_networkError]];
    }
}

#pragma mark - private

- (void)dismissViewController {
    id<MRInternalAuthHandlerDelegate> delegate = self.delegate;
    UIViewController *viewController = self.safariViewController;
    [delegate authHandlerWillDismissViewController:viewController];
    [self.safariViewController dismissViewControllerAnimated:YES
                                                  completion:^{
                                                      [delegate authHandlerDidDismissViewController:viewController];
                                                  }];
    self.safariViewController = nil;
    self.url = nil;
}

@end
