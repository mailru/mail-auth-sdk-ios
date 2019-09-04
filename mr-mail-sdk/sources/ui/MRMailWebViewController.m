//
//  MRMailWebViewController.m
//  mr-mail-sdk
//
//  Created by Aleksandr Karimov on 18/05/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import "MRMailWebViewController.h"
#import <WebKit/WebKit.h>

@interface MRMailWebViewController () <WKNavigationDelegate>
@property (nonatomic, readwrite, strong) NSURL *url;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation MRMailWebViewController

@synthesize delegate = _delegate;

#pragma mark - init

- (instancetype)initWithURL:(NSURL *)url {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.url = url;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureWebView];
    [self configureNavigationItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - action

- (void)didPressDismissButton:(id)sender {
    [self.delegate webViewControllerDidPressCancelButton];
}

#pragma mark - WKNavigationDelegate

- (void)                webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL shouldStartLoading = !_delegate || [_delegate webViewControllerShouldStartLoadingRequest:navigationAction.request];
    decisionHandler(shouldStartLoading ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

- (void)             webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
                   withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)  webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
        withError:(NSError *)error {
    [self.delegate webViewControllerDidFailLoadingWithError:error];
}

#pragma mark - private

- (void)configureWebView {
    WKWebView *view = [[WKWebView alloc] init];
    view.navigationDelegate = self;

    [self.view addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    [constraints addObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                    options:0
                                                    metrics:nil
                                                      views:bindings]];
    [constraints addObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                    options:0
                                                    metrics:nil
                                                      views:bindings]];
    [self.view addConstraints:constraints];
    self.webView = view;
}

- (void)configureNavigationItems {
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
                                                                                   action:@selector(didPressDismissButton:)];
    self.navigationItem.rightBarButtonItem = dismissButton;
}

@end
