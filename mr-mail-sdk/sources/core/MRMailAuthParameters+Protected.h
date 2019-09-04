//
// Created by Aleksandr Karimov on 16/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRMailAuthParameters.h"

@interface MRMailAuthParameters ()

@property (nonatomic, copy, readwrite) NSString *clientId;
@property (nonatomic, copy, readwrite) NSString *state;
@property (nonatomic, copy, readwrite) NSString *scopes;
@property (nonatomic, copy, readwrite) NSString *redirectUri;
@property (nonatomic, copy) NSString *loginHint;
@property (nonatomic, copy) NSString *codeChallenge;
@property (nonatomic, copy) NSString *challengeMethod;

@end
