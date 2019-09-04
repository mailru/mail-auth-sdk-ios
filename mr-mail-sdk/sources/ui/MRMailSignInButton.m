//
//  MRMailSignInButton.m
//  mr-mail-sdk
//
//  Created by Nikolay Morev on 22/03/2018.
//  Copyright © 2018 Mail.Ru. All rights reserved.
//

#import "MRMailSignInButton.h"
#import "MRMailSDK.h"
#import "NSBundle+MRSDK.h"

@interface MRMailSignInButton ()

@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIImageView *selectedBackgroundImageView;
@property (nonatomic, weak) UIImageView *logoImageView;
@property (nonatomic, weak) UILabel *actionLabel;

@end

@implementation MRMailSignInButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIImage *backgroundImage = [UIImage imageNamed:@"SignInButtonBackground" inBundle:NSBundle.mrsdk_UIResourcesBundle compatibleWithTraitCollection:nil];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:backgroundImageView];
    _backgroundImageView = backgroundImageView;

    UIImage *selectedBackgroundImage = [UIImage imageNamed:@"SignInButtonSelectedBackground" inBundle:NSBundle.mrsdk_UIResourcesBundle compatibleWithTraitCollection:nil];
    UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
    selectedBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    selectedBackgroundImageView.hidden = YES;
    [self addSubview:selectedBackgroundImageView];
    _backgroundImageView = selectedBackgroundImageView;

    UIImage *logoImage = [UIImage imageNamed:@"SignInButtonLogo" inBundle:NSBundle.mrsdk_UIResourcesBundle compatibleWithTraitCollection:nil];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:logoImageView];
    _logoImageView = logoImageView;

    UILabel *actionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    actionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    actionLabel.textColor = [UIColor whiteColor];
    actionLabel.text = NSLocalizedStringFromTableInBundle(@"with Mail.Ru", @"MRMailSDKUI", NSBundle.mrsdk_UIResourcesBundle, @"Call to action text on Sign in Button");
    actionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:actionLabel];
    _actionLabel = actionLabel;

    [logoImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [logoImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [logoImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [logoImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

    [NSLayoutConstraint activateConstraints:
     @[ [self.leadingAnchor constraintEqualToAnchor:backgroundImageView.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:backgroundImageView.trailingAnchor],
        [self.topAnchor constraintEqualToAnchor:backgroundImageView.topAnchor],
        [self.bottomAnchor constraintEqualToAnchor:backgroundImageView.bottomAnchor],

        [self.leadingAnchor constraintEqualToAnchor:selectedBackgroundImageView.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:selectedBackgroundImageView.trailingAnchor],
        [self.topAnchor constraintEqualToAnchor:selectedBackgroundImageView.topAnchor],
        [self.bottomAnchor constraintEqualToAnchor:selectedBackgroundImageView.bottomAnchor],

        [self.centerYAnchor constraintEqualToAnchor:logoImageView.centerYAnchor],
        [logoImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],

        [self.centerYAnchor constraintEqualToAnchor:actionLabel.centerYAnchor],
        [actionLabel.leadingAnchor constraintEqualToAnchor:logoImageView.trailingAnchor constant:10],
        [self.trailingAnchor constraintEqualToAnchor:actionLabel.trailingAnchor constant:22],
        [actionLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:10],
        [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:actionLabel.bottomAnchor constant:10],

        [self.heightAnchor constraintGreaterThanOrEqualToConstant:44] ]];

    [self addTarget:self action:@selector(signInAction) forControlEvents:UIControlEventTouchUpInside];
    [self configureSelectedState];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self configureSelectedState];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self configureSelectedState];
}

- (void)configureSelectedState {
    BOOL selected = self.selected || self.highlighted;
    self.backgroundImageView.hidden = !selected;
    self.selectedBackgroundImageView.hidden = selected;
}

- (void)signInAction {
    [[MRMailSDK sharedInstance] authorize];
}

- (NSString *)accessibilityLabel {
    return NSLocalizedStringFromTableInBundle(@"Mail.Ru", @"MRMailSDKUI", [NSBundle bundleForClass:[self class]], @"Sign in button accessibility label");
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityHint {
    return NSLocalizedStringFromTableInBundle(@"Sign in with Mail.Ru", @"MRMailSDKUI", [NSBundle bundleForClass:[self class]], @"Sign in button accessibility hint");
}

@end
