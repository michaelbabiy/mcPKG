//
//  MCSubmission+Create.m
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSubmission+Create.h"

static NSString * const kJotFormFreePackageSubmissionForm = @"";
static NSString * const kJotFormPaidPackageSubmissionForm = @"";
static NSString * const kJotFormUpdatePackageSubmissionForm = @"";

@implementation MCSubmission (Create)

+ (void)submissionFromContent:(NSDictionary *)content completion:(MCSubmissionSaveCompletionBlock)completionBlock
{
    /**
     *  This check is abslutely necessary. Here is why.
     *  I am only querying for NEW submissions from JotForm. If JotForm returns
     *  0 (as in no new submissions), JotForm will also "give" me a "test" rsponse
     *  that has tons of "bad" data that will crash the app when trying to save to 
     *  Core Data. Crazy stuff. Why they do it, I am not sure.
     */
    if ([[content objectForKey:@"id"]isEqualToString:@"#SampleSubmissionID"]) {
        completionBlock(NO, nil);
        return;
    }
    
    NSArray *matches = [MCSubmission findAllSortedBy:@"submissionDate"
                                           ascending:NO
                                       withPredicate:[NSPredicate predicateWithFormat:@"submissionID == %@", content[@"id"]]
                                           inContext:[NSManagedObjectContext contextForCurrentThread]];
    if (!matches || [matches count] > 1) {
        // Error.
    } else if ([matches count] == 0) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            MCSubmission *submission = [MCSubmission createInContext:localContext];
            
            // Shared between submissions.
            submission.submissionDate = [self dateFromAPIString:[content objectForKey:@"created_at"]];
            submission.submissionFlag = [[content objectForKey:@"flag"]isEqualToString:@"0"] ? @0 : @1;
            submission.submissionFormID = [content objectForKey:@"form_id"];
            submission.submissionID = [content objectForKey:@"id"];
            submission.submissionIP = [content objectForKey:@"ip"];
            submission.submissionNew = [NSNumber numberWithInt:[[content objectForKey:@"new"]intValue]];
            submission.submissionStatus = [content objectForKey:@"status"];
            if (![[content objectForKey:@"updated_at"]isKindOfClass:[NSNull class]]) {
                submission.submissionUpdateDate = [self dateFromAPIString:[content objectForKey:@"updated_at"]];
            }
            
            if ([[content objectForKey:@"form_id"] isEqualToString:kJotFormFreePackageSubmissionForm]) {
                
                // Free submission.
                submission.isNewDeveloper = nil;
                submission.authorEmail = [[[content objectForKey:@"answers"]objectForKey:@"3"]objectForKey:@"answer"];
                submission.authorName = [[[content objectForKey:@"answers"]objectForKey:@"1"]objectForKey:@"answer"];
                submission.packageName = [[[content objectForKey:@"answers"]objectForKey:@"4"]objectForKey:@"answer"];
                submission.packageVersion = [[[content objectForKey:@"answers"]objectForKey:@"5"]objectForKey:@"answer"];
                submission.cydiaDevID = nil;
                submission.packagePrice = nil;
                submission.packageDescription = [[[content objectForKey:@"answers"]objectForKey:@"7"]objectForKey:@"answer"];
                submission.screenshotDownloadURLString = [[[[content objectForKey:@"answers"]objectForKey:@"8"]objectForKey:@"answer"]firstObject];
                submission.authorTwitterHandle = [[[content objectForKey:@"answers"]objectForKey:@"10"]objectForKey:@"answer"];
                submission.authorFullName = nil;
                submission.authorCountry = nil;
                submission.authorPayPal = nil;
                submission.cydiaAccountNumber = nil;
                submission.packageCompatibility = [[[content objectForKey:@"answers"]objectForKey:@"6"]objectForKey:@"answer"];
                submission.packageDownloadURLString = [[[[content objectForKey:@"answers"]objectForKey:@"14"]objectForKey:@"answer"]firstObject];
                submission.packageChangeLog = nil;
                submission.maccitiKey = nil;
                
            } else if ([[content objectForKey:@"form_id"] isEqualToString:kJotFormPaidPackageSubmissionForm]) {
                
                // Paid submission.
                submission.isNewDeveloper = [[[[content objectForKey:@"answers"]objectForKey:@"1"]objectForKey:@"answer"]isEqualToString:@"Yes"] ? @YES : @NO;
                submission.authorEmail = [[[content objectForKey:@"answers"]objectForKey:@"3"]objectForKey:@"answer"];
                submission.authorName = [[[content objectForKey:@"answers"]objectForKey:@"4"]objectForKey:@"answer"];
                submission.packageName = [[[content objectForKey:@"answers"]objectForKey:@"5"]objectForKey:@"answer"];
                submission.packageVersion = [[[content objectForKey:@"answers"]objectForKey:@"6"]objectForKey:@"answer"];
                submission.cydiaDevID = [[[content objectForKey:@"answers"]objectForKey:@"7"]objectForKey:@"answer"];
                submission.packagePrice = [[[content objectForKey:@"answers"]objectForKey:@"8"]objectForKey:@"answer"];
                submission.packageDescription = [[[content objectForKey:@"answers"]objectForKey:@"9"]objectForKey:@"answer"];
                submission.screenshotDownloadURLString = [[[[content objectForKey:@"answers"]objectForKey:@"10"]objectForKey:@"answer"]firstObject];
                submission.authorTwitterHandle = [[[content objectForKey:@"answers"]objectForKey:@"12"]objectForKey:@"answer"];
                submission.authorFullName = [[[content objectForKey:@"answers"]objectForKey:@"13"]objectForKey:@"prettyFormat"];
                submission.authorCountry = [[[content objectForKey:@"answers"]objectForKey:@"14"]objectForKey:@"answer"];
                submission.authorPayPal = [[[content objectForKey:@"answers"]objectForKey:@"15"]objectForKey:@"answer"];
                submission.cydiaAccountNumber = [[[content objectForKey:@"answers"]objectForKey:@"16"]objectForKey:@"answer"];
                submission.packageCompatibility = [[[content objectForKey:@"answers"]objectForKey:@"17"]objectForKey:@"answer"];
                submission.packageDownloadURLString = [[[[content objectForKey:@"answers"]objectForKey:@"18"]objectForKey:@"answer"]firstObject];
                submission.packageChangeLog = nil;
                submission.maccitiKey = nil;
                
            } else if ([[content objectForKey:@"form_id"] isEqualToString:kJotFormUpdatePackageSubmissionForm]) {
                
                // Update...
                submission.isNewDeveloper = nil;
                submission.authorEmail = nil;
                submission.authorName = nil;
                submission.packageName = [[[content objectForKey:@"answers"]objectForKey:@"1"]objectForKey:@"answer"];
                submission.packageVersion = [[[content objectForKey:@"answers"]objectForKey:@"3"]objectForKey:@"answer"];
                submission.cydiaDevID = nil;
                submission.packagePrice = nil;
                submission.packageDescription = nil;
                submission.screenshotDownloadURLString = nil;
                submission.authorTwitterHandle = nil;
                submission.authorFullName = nil;
                submission.authorCountry = nil;
                submission.authorPayPal = nil;
                submission.cydiaAccountNumber = nil;
                submission.packageCompatibility = nil;
                submission.packageDownloadURLString = [[[[content objectForKey:@"answers"]objectForKey:@"7"]objectForKey:@"answer"]firstObject];
                submission.packageChangeLog = [[[content objectForKey:@"answers"]objectForKey:@"4"]objectForKey:@"answer"];
                submission.maccitiKey = [[[content objectForKey:@"answers"]objectForKey:@"6"]objectForKey:@"answer"];
            }
            
        } completion:^(BOOL success, NSError *error) {
            if (!error) {
                completionBlock(YES, nil);
            } else {
                completionBlock(NO, error);
            }
        }];
    } else {
        // Exist, simply return.
        completionBlock(YES, nil);
    }
}

#pragma mark - Helper Methods

+ (NSDate *)dateFromAPIString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter dateFromString:dateString];
}

@end
