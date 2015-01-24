//
//  MCUsage+Create.m
//  mcPKG
//
//  Created by iC on 2/2/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCUsage+Create.h"

@implementation MCUsage (Create)

+ (void)usageFromData:(NSDictionary *)data completion:(MCUsageSaveCompletionBlock)completionBlock
{
    __block MCUsage *usage = nil;
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        [MCUsage deleteAllMatchingPredicate:nil];
    } completion:^(BOOL success, NSError *error) {
        if (!error) {
            [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                usage = [MCUsage createInContext:localContext];
                usage.submissionsCount = [data valueForKey:@"submissions"];
                usage.usageData = [data valueForKey:@"uploads"];
            } completion:^(BOOL success, NSError *error) {
                if (!error) {
                    completionBlock(YES, usage, nil);
                } else {
                    completionBlock(NO, nil, error);
                }
            }];
        }
    }];
}

@end
