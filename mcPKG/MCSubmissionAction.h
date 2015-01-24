//
//  MCSubmissionAction.h
//  mcPKG
//
//  Created by iC on 1/29/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MessageUI;
@class MCSubmission;

typedef void(^MCSubmissionProcessingCompletionBlock)(BOOL success, NSError *error);

@interface MCSubmissionAction : NSObject

/**
 *  Methods for both marking the submission complete and deleting one.
 *  The implementation will deal with JotForm (delete, mark complete)
 *  as well as Core Data.
 *
 *  @param submission to be deleted / marked as complete.
 */
+ (void)markSubmissionNew:(MCSubmission *)submission completion:(MCSubmissionProcessingCompletionBlock)completionBlock;
+ (void)markSubmissionCompleted:(MCSubmission *)submission completion:(MCSubmissionProcessingCompletionBlock)completionBlock;
+ (void)deleteSubmission:(MCSubmission *)submission completion:(MCSubmissionProcessingCompletionBlock)completionBlock;

@end
