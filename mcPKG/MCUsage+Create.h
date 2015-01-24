//
//  MCUsage+Create.h
//  mcPKG
//
//  Created by iC on 2/2/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCUsage.h"

typedef void(^MCUsageSaveCompletionBlock)(BOOL success, MCUsage *usage, NSError *error);

@interface MCUsage (Create)

/**
 *  Method for saving usdage data into Core Data.
 *
 *  @param data            returned from JotForm for user usage.
 *  @param completionBlock YES/NO, ERROR/NIL
 */
+ (void)usageFromData:(NSDictionary *)data
           completion:(MCUsageSaveCompletionBlock)completionBlock;

@end
