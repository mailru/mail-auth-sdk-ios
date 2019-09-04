//
//  MRMailWebViewController.h
//  mr-mail-sdk
//
//  Created by Aleksandr Karimov on 18/05/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRInternalAuthHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MRMailWebViewControllerDelegate <NSObject>
- (BOOL)webViewControllerShouldStartLoadingRequest:(NSURLRequest *)request;
- (void)webViewControllerDidFailLoadingWithError:(nullable NSError *)error;
- (void)webViewControllerDidPressCancelButton;
@end

@interface MRMailWebViewController : UIViewController

@property (nonatomic, weak, nullable) id<MRMailWebViewControllerDelegate> delegate;
@property (nonatomic, readonly, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
