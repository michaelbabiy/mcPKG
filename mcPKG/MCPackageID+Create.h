//
//  MCPackageID+Create.h
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCPackageID.h"

typedef void(^MCPackageIDSaveCompletionBloc)(BOOL success, NSError *error);

@interface MCPackageID (Create)

/**
 *  Method for extracting relevant data from ZodTTD.com.
 *  This method is also responsible for saving package IDs
 *  into Core Data.
 *
 *  Called from interested View Controllers.
 *
 *  @param packageID ID of the package to be saved.
 *  @param block    notfies when the saving into Core Data is complete.
 */
+ (void)packageIDFromString:(NSString *)packageID completion:(MCPackageIDSaveCompletionBloc)completionBlock;

@end
