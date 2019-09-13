//
// Created by Aleksandr Karimov on 16/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import "UIApplication+MRSDK.h"

@implementation UIApplication (MRSDK)

#pragma mark - public

+ (UIApplication *)mrsdk_sharedApplication {
    if (!self.mrsdk_isAppExtension && [UIApplication respondsToSelector:@selector(sharedApplication)]) {
        return [UIApplication performSelector:@selector(sharedApplication)];
    }
    return nil;
}

#pragma mark - private

+ (BOOL)mrsdk_isAppExtension {
    return [[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"];
}

@end
