//
//  MCRawControl.h
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCRawControl : NSObject

@property (strong, nonatomic) NSString *packageID;
@property (strong, nonatomic) NSString *packageName;
@property (strong, nonatomic) NSString *packageVersion;
@property (strong, nonatomic) NSString *packageArchitecture;
@property (strong, nonatomic) NSString *packageDependency;
@property (strong, nonatomic) NSString *packageDescription;
@property (strong, nonatomic) NSString *packageMaintainer;
@property (strong, nonatomic) NSString *packageSection;
@property (strong, nonatomic) NSString *packageDepiction;
@property (assign, nonatomic) BOOL packageIsPaid;

@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSString *authorEmail;

@property (strong, nonatomic) NSString *screenshotsDownloadURLString;
@property (strong, nonatomic) NSString *packageDownloadURLString;

@property (strong, nonatomic) NSString *submissionID;

- (instancetype)initWithName:(NSString *)name
                 description:(NSString *)description
                      author:(NSString *)author
                       email:(NSString *)email
                      isPaid:(BOOL)isPaid
screenshotsDownloadURLString:(NSString *)sURLString
    packageDownloadURLString:(NSString *)pURLString
                submissionID:(NSString *)submissionID;

@end
