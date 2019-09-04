//
// Created by Aleksandr Karimov on 16/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import "MRMailAuthParameters+QueryItems.h"

@implementation MRMailAuthParameters (QueryItems)

- (NSArray<NSURLQueryItem *> *)mrsdk_queryItems {
    NSMutableArray<NSURLQueryItem *> *items = @[].mutableCopy;
    void(^addItem)(NSString *, NSString *) = ^(NSString *value, NSString *name) {
        if (value) {
            [items addObject:[NSURLQueryItem queryItemWithName:name value:value]];
        }
    };
    addItem(self.clientId, @"client_id");
    addItem(self.scopes, @"scope");
    addItem(self.redirectUri, @"redirect_uri");
    addItem(self.state, @"state");
    addItem(self.loginHint, @"login");
    addItem(self.codeChallenge, @"code_challenge");
    addItem(self.challengeMethod, @"code_challenge_method");

    return items;
}

@end
