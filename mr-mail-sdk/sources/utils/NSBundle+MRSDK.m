//
//  NSBundle+MRSDK.m
//  mr-mail-sdk
//
//  Created by Nikolay Morev on 22/03/2018.
//  Copyright © 2018 Mail.Ru. All rights reserved.
//

#import "NSBundle+MRSDK.h"
#import "MRMailSDK.h"

@implementation NSBundle (MRSDK)

+ (instancetype)mrsdk_UIResourcesBundle {
    NSBundle *classBundle = [NSBundle bundleForClass:[MRMailSDK class]];
    NSURL *bundleURL = [classBundle URLForResource:@"MRMailSDKUI" withExtension:@"bundle"];
    if (!bundleURL) {
        return classBundle;
    }
    return [NSBundle bundleWithURL:bundleURL];
}

@end
