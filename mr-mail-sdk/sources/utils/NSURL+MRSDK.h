//
// Created by Aleksandr Karimov on 18/05/2017.
// Copyright (c) 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MRSDK)

- (NSString *)mrsdk_urlWithoutQuery;
- (NSDictionary<NSString *, NSString *> *)mrsdk_GETParameters;

@end
