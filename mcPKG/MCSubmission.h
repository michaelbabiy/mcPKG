//
//  MCSubmission.h
//  mcPKG
//
//  Created by iC on 1/24/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MCSubmission : NSManagedObject

@property (nonatomic, retain) NSString * authorCountry;
@property (nonatomic, retain) NSString * authorEmail;
@property (nonatomic, retain) NSString * authorFullName;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * authorPayPal;
@property (nonatomic, retain) NSString * authorTwitterHandle;
@property (nonatomic, retain) NSString * cydiaAccountNumber;
@property (nonatomic, retain) NSString * cydiaDevID;
@property (nonatomic, retain) NSNumber * isNewDeveloper;
@property (nonatomic, retain) NSString * maccitiKey;
@property (nonatomic, retain) NSString * packageChangeLog;
@property (nonatomic, retain) NSString * packageCompatibility;
@property (nonatomic, retain) NSString * packageDescription;
@property (nonatomic, retain) NSString * packageDownloadURLString;
@property (nonatomic, retain) NSString * packageName;
@property (nonatomic, retain) NSString * packagePrice;
@property (nonatomic, retain) NSString * packageVersion;
@property (nonatomic, retain) NSString * screenshotDownloadURLString;
@property (nonatomic, retain) NSDate * submissionDate;
@property (nonatomic, retain) NSNumber * submissionFlag;
@property (nonatomic, retain) NSString * submissionFormID;
@property (nonatomic, retain) NSString * submissionID;
@property (nonatomic, retain) NSString * submissionIP;
@property (nonatomic, retain) NSNumber * submissionNew;
@property (nonatomic, retain) NSString * submissionStatus;
@property (nonatomic, retain) NSDate * submissionUpdateDate;

@end
