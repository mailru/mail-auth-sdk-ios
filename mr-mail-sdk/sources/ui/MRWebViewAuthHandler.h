//
// Created by Aleksandr Karimov on 18/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRInternalAuthHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class MRMailAuthRedirectURLParser;

@interface MRWebViewAuthHandler : NSObject<MRInternalAuthHandler>

- (instancetype)initWithRedirectURLParser:(MRMailAuthRedirectURLParser *)redirectURLParser NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
