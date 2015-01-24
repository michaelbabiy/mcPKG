//
//  MCSubmission+Create.h
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSubmission.h"

typedef void(^MCSubmissionSaveCompletionBlock)(BOOL success, NSError *error);

@interface MCSubmission (Create)

/**
 *  Method for extracting relevant data from Jotform.
 *  This method is also responsible for saving user data
 *  into Core Data.
 *
 *  Called from interested View Controllers.
 *
 *  @param content  of extracted from Jotform.
 *  @param formType can be ehter Free, Paid or Update.
 *  @param block    notfies when the saving into Core Data is complete.
 */
+ (void)submissionFromContent:(NSDictionary *)content completion:(MCSubmissionSaveCompletionBlock)completionBlock;

@end
