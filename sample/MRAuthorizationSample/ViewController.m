//
//  ViewController.m
//  MRAuthorizationSample
//
//  Created by Aleksandr Karimov on 16/05/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <MRMailSDK/MRMailSDK.h>
#import <MRMailSDK/MRMailSDK+Private.h>

#import "ViewController.h"

@interface ViewController () <MRMailSDKUIDelegate, MRMailSDKDelegate>

@property (nonatomic, weak) IBOutlet UILabel *resultLabel;
@property (nonatomic, weak) IBOutlet UISwitch *switchHostsControl;
@property (nonatomic, weak) IBOutlet UISwitch *switchSafariControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MRMailSDK.sharedInstance.delegate   = self;
    MRMailSDK.sharedInstance.uiDelegate = self;
}

- (IBAction)didPressAuthorizeButton:(id)sender {
    MRMailSDK.sharedInstance.usesMailApplication = YES;
    MRMailSDK.sharedInstance.loginHint = nil;

    [MRMailSDK.sharedInstance forceLogout];
    [MRMailSDK.sharedInstance authorize];
}

- (IBAction)didPressInternalAuthorizeButton:(id)sender {
    MRMailSDK.sharedInstance.usesMailApplication = NO;
    MRMailSDK.sharedInstance.loginHint = nil;

    [MRMailSDK.sharedInstance forceLogout];
    [MRMailSDK.sharedInstance authorize];
}

- (IBAction)didChangeValueInTestHostsSwitchControl:(id)sender {
    MRMailSDK.sharedInstance.useTestHosts = self.switchHostsControl.on;
}

- (IBAction)didChangeValueInSafariSwitchControl:(id)sender {
    MRMailSDK.sharedInstance.internalAuthMode = self.switchSafariControl.on ?
            kMRMailSDKInternalAuthMode_Safari : kMRMailSDKInternalAuthMode_WebKit;
}

#pragma mark - MRMailSDKDelegate

- (void)mrMailSDK:(MRMailSDK *)sdk authorizationDidFinishWithResult:(MRSDKAuthorizationResult *)result {
    [self processSuccessWithCode:result.authorizationCode];
}

- (void)mrMailSDK:(MRMailSDK *)sdk authorizationDidFailWithError:(NSError *)error {
    [self processFailWithError:error];
}

#pragma mark - MRMailSDKUIDelegate

- (void)mrMailSDK:(MRMailSDK *)sdk shouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
}

- (void)mrMailSDK:(MRMailSDK *)sdk willDismissViewController:(UIViewController *)controller {

}

- (void)mrMailSDK:(MRMailSDK *)sdk didDismissViewController:(UIViewController *)controller {

}

#pragma mark - private

- (void)processFailWithError:(NSError *)error {
    self.resultLabel.text = [NSString stringWithFormat:@"ошибка - %ld (%@)", (long)error.code, error.userInfo[NSHelpAnchorErrorKey]];
}

- (void)processSuccessWithCode:(NSString *)code {
    self.resultLabel.text = @"успех - код получен";
}

@end
