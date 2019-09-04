//
//  NSMutableURLRequest+MRSDK.m
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 17/06/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import "NSMutableURLRequest+MRSDK.h"

// https://github.com/AFNetworking/AFNetworking/blob/685e31a31bb1ebce3fdb5a752e392dfd8263e169/AFNetworking/AFURLRequestSerialization.m#L47
static NSString *MRSDKAFPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];

    static NSUInteger const batchSize = 50;

    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;

    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);

        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];

        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];

        index += range.length;
    }

    return escaped;
}


@implementation NSMutableURLRequest (MRSDK)

- (void)mrsdk_setHTTPBodyQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    NSMutableArray<NSString *> *components = [[NSMutableArray alloc] initWithCapacity:queryItems.count];

    for (NSURLQueryItem *item in queryItems) {
        if (item.value) {
            [components addObject:[NSString stringWithFormat:@"%@=%@",
                MRSDKAFPercentEscapedStringFromString(item.name),
                MRSDKAFPercentEscapedStringFromString(item.value)]];
        } else {
            [components addObject:MRSDKAFPercentEscapedStringFromString(item.name)];
        }
    }
    NSString *bodyString = [components componentsJoinedByString:@"&"];
    self.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)mrsdk_addBasicAccessAuthenticationHeaderFieldWithUsername:(NSString *)userName password:(NSString *)password {
    NSParameterAssert(userName);
    NSParameterAssert(password);

    NSString *credentialString = [NSString stringWithFormat:@"%@:%@", userName, password];
    NSString *encodedCredential = [[credentialString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
    if (!encodedCredential) {
        return NO;
    }
    NSString *value = [NSString stringWithFormat:@"Basic %@", encodedCredential];
    [self addValue:value forHTTPHeaderField:@"Authorization"];

    return YES;
}

@end
