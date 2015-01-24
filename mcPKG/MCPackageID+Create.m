//
//  MCPackageID+Create.m
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCPackageID+Create.h"

@implementation MCPackageID (Create)

+ (void)packageIDFromString:(NSString *)packageID completion:(MCPackageIDSaveCompletionBloc)completionBlock
{
    __block MCPackageID *aPackageID = nil;
    NSArray *matches = [MCPackageID findAllSortedBy:@"packageID"
                                          ascending:NO
                                      withPredicate:[NSPredicate predicateWithFormat:@"packageID == %@", packageID]
                                          inContext:[NSManagedObjectContext contextForCurrentThread]];
    if (!matches || [matches count] > 1 ) {
        // Error.
    } else if ([matches count] == 0) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            aPackageID = [MCPackageID createInContext:localContext];
            aPackageID.packageID = packageID;
        } completion:^(BOOL success, NSError *error) {
            if (!error) {
                completionBlock(YES, nil);
            } else {
                completionBlock(NO, error);
            }
        }];
    } else {
        completionBlock(YES, nil);
    }
}

@end
