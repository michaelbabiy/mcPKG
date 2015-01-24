//
//  MCFetchedResultsController.h
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCSubmission+Create.h"
#import "MCPackageID+Create.h"
#import "MCDeveloper+Create.h"

static NSString * const kMCSubmissionEntityName = @"MCSubmission";
static NSString * const kMCPackageIDEntityName = @"MCPackageID";
static NSString * const kMCDeveloperEntityName = @"MCDeveloper";

@interface MCFetchedResultsController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

/**
 *  Setting fethced results controller is required in order to populate
 *  table view with data from Core Data.
 *
 *  @param entityName to query. Use actual antity names.
 *  @param predicate  for each Core Data query.
 *  @param sortOrder  for each query.
 */
- (void)setFetchedResultsControllerForEntity:(NSString *)entityName
                                   predicate:(NSPredicate *)predicate
                                        sort:(id)sortOrder;

@end
