//
// Created by Aleksandr Karimov on 18/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import "MRWebViewAuthHandler.h"
#import "NSError+MRSDK.h"
#import "MRMailWebViewController.h"
#import "MRMailAuthRedirectURLParser.h"

@interface MRWebViewAuthHandler () <MRMailWebViewControllerDelegate>
@property (nonatomic, strong, readonly) MRMailAuthRedirectURLParser *redirectURLParser;
@property (nonatomic, strong) MRMailWebViewController *webViewController;
@end

@implementation MRWebViewAuthHandler

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
    MRMailWebViewController *webViewController = [[MRMailWebViewController alloc] initWithURL:url];
    webViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    self.webViewController = webViewController;
    [_delegate authHandlerShouldPresentViewController:navigationController];
}

- (void)cancel {
    self.webViewController.delegate = nil;
    [self.webViewController.navigationController dismissViewControllerAnimated:YES
                                                                    completion:nil];
    self.webViewController = nil;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication {
    return NO;
}

#pragma mark - MRMailWebViewControllerDelegate

- (BOOL)webViewControllerShouldStartLoadingRequest:(NSURLRequest *)request {
    NSString *code;
    NSError *error;
    if ([self.redirectURLParser parseURL:request.URL code:&code error:&error]) {
        [self dismissAuthController];
        id<MRInternalAuthHandlerDelegate> delegate = self.delegate;
        if (code) {
            [delegate authHandlerDidFinishWithCode:code];
        } else {
            [delegate authHandlerDidFailWithError:error];
        }
        return NO;
    }
    return YES;
}

- (void)webViewControllerDidFailLoadingWithError:(NSError *)error {
    if (self.webViewController) {
        NSError *sdkError = [NSError mrsdk_OAuthError];
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            if (error.code == NSURLErrorCancelled) {
                // не обрабатываем networking cancel, так как это может происходить перед новым запросом,
                // если предыдущий не был до конца завершен
                return;
            }
            sdkError = [NSError mrsdk_networkError];
        }
        else if ([error.domain isEqualToString:@"WebKitErrorDomain"]) {
            sdkError = [NSError mrsdk_networkError];
        }
        [self dismissAuthController];
        [_delegate authHandlerDidFailWithError:sdkError];
    }
}

- (void)webViewControllerDidPressCancelButton {
    [self dismissAuthController];
    [_delegate authHandlerDidFailWithError:[NSError mrsdk_canceledByUserError]];
}

#pragma mark - private

- (void)dismissAuthController {
    id<MRInternalAuthHandlerDelegate> delegate = self.delegate;
    UIViewController *viewController = self.webViewController.navigationController;
    [delegate authHandlerWillDismissViewController:viewController];
    [self.webViewController.navigationController dismissViewControllerAnimated:YES
                                                                    completion:^{
                                                                        [delegate authHandlerDidDismissViewController:viewController];
                                                                    }];
    self.webViewController = nil;
}

@end
