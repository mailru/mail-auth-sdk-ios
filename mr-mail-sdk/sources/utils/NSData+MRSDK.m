//
//  NSData+MRSDK.m
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 06/08/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSData+MRSDK.h"

@implementation NSData (MRSDK)

+ (NSData *)mrsdk_randomlyFilledDataWithLength:(NSUInteger)length {
    NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
    int result = SecRandomCopyBytes(kSecRandomDefault, data.length, data.mutableBytes);
    if (result != errSecSuccess) {
        return nil;
    }
    return data;
}

- (NSData *)mrsdk_SHA256Hash {
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, hash.mutableBytes);

    return hash;
}

- (NSData *)mrsdk_base64URLNoPaddingEncoded {
    NSString *base64String = [self base64EncodedStringWithOptions:kNilOptions];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@""];

    return (NSData *_Nonnull)[base64String dataUsingEncoding:NSUTF8StringEncoding];
}

@end
