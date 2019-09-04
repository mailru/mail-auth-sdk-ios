//
// Created by Aleksandr Karimov on 18/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import "NSURL+MRSDK.h"

@implementation NSURL (MRSDK)

- (NSDictionary<NSString *, NSString *> *)mrsdk_GETParameters {
    NSMutableDictionary<NSString *, NSString *> *parameters = @{}.mutableCopy;
    NSURLComponents *components = [NSURLComponents componentsWithURL:self
                                             resolvingAgainstBaseURL:NO];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        parameters[item.name] = item.value;
    }];
    return parameters.count ? parameters.copy : nil;
}

- (NSString *)mrsdk_urlWithoutQuery {
    NSString *urlString = @"";
    NSString *scheme = [self scheme];
    if (scheme) {
        urlString = [scheme stringByAppendingString:@"://"];
    }
    NSString *host = [self host];
    if (host) {
        urlString = [urlString stringByAppendingString:host];
    }
    NSString *path = [self path];
    if (path) {
        urlString = [urlString stringByAppendingString:path];
    }
    return urlString;
}

@end