//
//  MCFetchedResultsController.m
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCFetchedResultsController.h"

@interface MCFetchedResultsController () <NSFetchedResultsControllerDelegate>

@end

@implementation MCFetchedResultsController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setFetchedResultsControllerForEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sort:(id)sortOrder
{
    // Before setting fetched results controller, releasing the old one. With ARC, probably not needed.
    [self setFetchedResultsController:nil];
    
    if ([entityName isEqualToString:kMCSubmissionEntityName]) {
        [self setFetchedResultsController:[MCSubmission fetchAllSortedBy:sortOrder
                                                               ascending:NO
                                                           withPredicate:predicate
                                                                 groupBy:nil
                                                                delegate:self
                                                               inContext:[NSManagedObjectContext contextForCurrentThread]]];
    } else if ([entityName isEqualToString:kMCPackageIDEntityName]) {
        [self setFetchedResultsController:[MCPackageID fetchAllSortedBy:sortOrder
                                                              ascending:YES
                                                          withPredicate:predicate
                                                                groupBy:nil
                                                               delegate:self
                                                              inContext:[NSManagedObjectContext contextForCurrentThread]]];
    } else if ([entityName isEqualToString:kMCDeveloperEntityName]) {
        [self setFetchedResultsController:[MCDeveloper fetchAllSortedBy:sortOrder
                                                              ascending:YES
                                                          withPredicate:predicate
                                                                groupBy:nil
                                                               delegate:self
                                                              inContext:[NSManagedObjectContext contextForCurrentThread]]];
    }
}

#pragma mark - Fetched Results Controller

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
