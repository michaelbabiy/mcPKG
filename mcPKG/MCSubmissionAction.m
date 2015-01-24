//
//  MCSubmissionAction.m
//  mcPKG
//
//  Created by iC on 1/29/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSubmissionAction.h"
#import "MCSubmission.h"
#import "MCWebAPi.h"

@implementation MCSubmissionAction

+ (void)markSubmissionNew:(MCSubmission *)submission completion:(MCSubmissionProcessingCompletionBlock)completionBlock
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        submission.submissionNew = @YES;
    } completion:^(BOOL success, NSError *error) {
        if (!error) {
            NSDictionary *paramters = @{@"submission[new]": @1};
            [MCWebAPi POSTRequestForSubmission:submission.submissionID parameters:paramters completion:^(BOOL success, NSError *error) {
                if (error) {
                    completionBlock(NO, error);
                } else {
                    completionBlock(YES, nil);
                }
            }];
        } else {
            completionBlock(NO, error);
        }
    }];
}

+ (void)markSubmissionCompleted:(MCSubmission *)submission completion:(MCSubmissionProcessingCompletionBlock)completionBlock
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        submission.submissionNew = @NO;
    } completion:^(BOOL success, NSError *error) {
        if (!error) {
            NSDictionary *paramters = @{@"submission[new]": @0};
            [MCWebAPi POSTRequestForSubmission:submission.submissionID parameters:paramters completion:^(BOOL success, NSError *error) {
                if (error) {
                    completionBlock(NO, error);
                } else {
                    completionBlock(YES, nil);
                }
            }];
        } else {
            completionBlock(NO, error);
        }
    }];
}

+ (void)deleteSubmission:(MCSubmission *)submission completion:(MCSubmissionProcessingCompletionBlock)completionBlock
{
    /**
     *  Need to create a pointer to the submission that needs to be deleted because
     *  submission pointer will be nil after its deleted from Core Data.
     */
    NSString *submissionID = submission.submissionID;
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext deleteObject:submission];
    } completion:^(BOOL success, NSError *error) {
        if (!error) {
            [MCWebAPi DELETERequestForSubmission:submissionID completion:^(BOOL success, NSError *error) {
                if (error) {
                    completionBlock(NO, error);
                } else {
                    completionBlock(YES, nil);
                }
            }];
        } else {
            completionBlock(NO, error);
        }
    }];
}

@end
