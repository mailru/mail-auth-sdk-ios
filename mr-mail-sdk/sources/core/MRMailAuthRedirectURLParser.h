//
//  MRMailAuthRedirectURLParser.h
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 24/07/2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRMailAuthRedirectURLParser : NSObject

- (instancetype)initWithRedirectURI:(NSString *)redirectURI NS_DESIGNATED_INITIALIZER;

- (BOOL)parseURL:(NSURL *)url code:(out NSString *_Nullable *_Nullable)code error:(out NSError *_Nullable *_Nullable)error;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
