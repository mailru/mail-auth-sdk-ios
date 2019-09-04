//
// Created by Aleksandr Karimov on 16/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRMailAuthParameters : NSObject

@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, copy, readonly) NSString *state;
@property (nonatomic, copy, readonly) NSString *scopes;
@property (nonatomic, copy, readonly) NSString *redirectUri;
@property (nonatomic, copy, readonly) NSString *loginHint;
@property (nonatomic, copy, readonly) NSString *codeChallenge;
@property (nonatomic, copy, readonly) NSString *challengeMethod;

@end
