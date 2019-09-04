//
// Created by Aleksandr Karimov on 16/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRMailAuthParameters.h"

@interface MRMailAuthParameters (QueryItems)

- (NSArray<NSURLQueryItem *> *)mrsdk_queryItems;

@end