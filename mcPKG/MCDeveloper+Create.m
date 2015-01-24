//
//  MCDeveloper+Create.m
//  mcPKG
//
//  Created by iC on 1/31/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCDeveloper+Create.h"
#import "MCParseConstants.h"

@implementation MCDeveloper (Create)

+ (void)developerFromParseObject:(PFObject *)object completion:(MCDeveloperSaveCompletionBlock)completionBlock
{
    __block MCDeveloper *developer = nil;
    NSArray *matches = [MCDeveloper findAllSortedBy:@"firstName"
                                          ascending:NO
                                      withPredicate:[NSPredicate predicateWithFormat:@"maccitiKey == %@", [object valueForKey:kDeveloperMacCitiKey]]
                                          inContext:[NSManagedObjectContext contextForCurrentThread]];
    if (!matches || [matches count] > 1) {
        // Error.
    } else if ([matches count] == 0) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            developer = [MCDeveloper createInContext:localContext];
            developer.firstName = [object valueForKey:kDeveloperFirstNameKey];
            developer.lastName = [object valueForKey:kDeveloperLastNameKey];
            developer.developerID = [object valueForKey:kDeveloperIDKey];
            developer.accountNumber = [object valueForKey:kDeveloperAccountNumberKey];
            developer.maccitiKey = [object valueForKey:kDeveloperMacCitiKey];
            developer.twitterHandle = [object valueForKey:kDeveloperTwitterHandle];
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
