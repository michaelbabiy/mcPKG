//
//  MCDeveloper+Create.h
//  mcPKG
//
//  Created by iC on 1/31/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCDeveloper.h"

typedef void(^MCDeveloperSaveCompletionBlock)(BOOL success, NSError *error);

@interface MCDeveloper (Create)

/**
 *  Method for creating / saving developers info into Core Data.
 *
 *  @param object          from Parse that contains all developer info.
 *  @param completionBlock YES/NO, ERROR/nil.
 */
+ (void)developerFromParseObject:(PFObject *)object
                      completion:(MCDeveloperSaveCompletionBlock)completionBlock;

@end
