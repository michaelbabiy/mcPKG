//
//  MCRawControl.m
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCRawControl.h"
#import "MCRawControlValidator.h"

@implementation MCRawControl

- (instancetype)initWithName:(NSString *)name
                 description:(NSString *)description
                      author:(NSString *)author
                       email:(NSString *)email
                      isPaid:(BOOL)isPaid
screenshotsDownloadURLString:(NSString *)sURLString
    packageDownloadURLString:(NSString *)pURLString
                submissionID:(NSString *)submissionID
{
    self = [super init];
    if (self) {
        _packageID = [MCRawControlValidator validateID:name];
        _packageName = [MCRawControlValidator validateName:name];
        _packageVersion = @"1.0";
        _packageArchitecture = @"iphoneos-arm";
        _packageDependency = nil;
        _packageDescription = [MCRawControlValidator validateDescription:description];
        _packageMaintainer = @"iC <apt@macciti.com>";
        _packageSection = nil;
        _packageDepiction = [MCRawControlValidator validateDepiction:_packageID];
        _packageIsPaid = isPaid;
        _authorName = [MCRawControlValidator validateAuthorname:author];
        _authorEmail = email;
        _screenshotsDownloadURLString = [MCRawControlValidator validateURLString:sURLString];
        _packageDownloadURLString = [MCRawControlValidator validateURLString:pURLString];
        _submissionID = submissionID;
    }
    return self;
}

- (instancetype)init
{
    [[NSException exceptionWithName:@"INIT ERROR"
                             reason:@"Use initWithName: description: author: email: isPaid:"
                           userInfo:nil]raise];
    return nil;
}

@end
