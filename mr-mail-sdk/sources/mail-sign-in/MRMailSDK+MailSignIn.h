//
//  MRMailSDK+MailSignIn.h
//  mr-mail-sdk
//
//  Created by Evgeniy Yurtaev on 19/06/2019.
//  Copyright © 2019 Mail.Ru. All rights reserved.
//

#ifdef MRSDK_MAIL_SIGN_IN

#import "MRMailSDK.h"

NS_ASSUME_NONNULL_BEGIN

@class MRMSignInConfiguration;
@class MRMAccountInfo;

@interface MRMailSDK ()

@property (nonatomic, assign) BOOL usesMailApplicationCredentialsToNonInteractivelyLogin;

@property (nonatomic, null_resettable, strong) MRMSignInConfiguration *mailSignInConfiguration;

- (void)getMailApplicationLoggedInAccountInfosWithCompletionHandler:(void(^)(NSArray<MRMAccountInfo *> *_Nullable accountInfos, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END

#endif
