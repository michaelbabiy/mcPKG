//
//  MCCompletedViewController.m
//  mcPKG
//
//  Created by iC on 1/29/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCCompletedViewController.h"
#import "MCSubmissionAction.h"

@interface MCCompletedViewController () <UIAlertViewDelegate>

- (void)performGETRequest;
- (IBAction)deleteAllButtonSelected:(id)sender;

@end

@implementation MCCompletedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(performGETRequest)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setFetchedResultsControllerForEntity:kMCSubmissionEntityName
                                     predicate:[NSPredicate predicateWithFormat:@"submissionNew == %@", @NO]
                                          sort:@"submissionDate"];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *  This method is a bit unique as it checks for count of objects in the arrar in the 
 *  addition to checking for errors. Why? Contrary to whats happening when new submissions
 *  are queried, if there are no new packages, contens array will be empty (when queriying
 *  for NEW packages, even if there are no new packages, a "dummy" package will be returned.
 */
- (void)performGETRequest
{
    [MCWebAPi GETRequestForAllSubmissionsWithFilter:kJotFormAPIRequestFilterOld
                                              order:kJotFormAPIRequestSortOrderByCreatedAt
                                              limit:kJotFormAPIRequestLimitDefault
                                         completion:^(BOOL success, NSArray *contents, NSError *error) {
                                             if (!error && [contents count] > 0) {
                                                 for (NSDictionary *content in contents) {
                                                     [MCSubmission submissionFromContent:content
                                                                              completion:^(BOOL success, NSError *error) {
                                                                                  if (!error) {
                                                                                      [self.refreshControl endRefreshing];
                                                                                  }
                                                                              }];
                                                 }
                                             } else {
                                                 [self.refreshControl endRefreshing];
                                             }
                                         }];
}

- (IBAction)deleteAllButtonSelected:(id)sender
{
    [[[UIAlertView alloc]initWithTitle:@"Delete all completed?"
                               message:@"This action cannot be undone."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"OK", nil]show];
}

#pragma mark - Setup

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSubmissionCell *submissionCell = [tableView dequeueReusableCellWithIdentifier:@"MCCompletedCell"];
    [self configureCell:submissionCell forRowAtIndexPath:indexPath withSubmission:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return submissionCell;
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *searchPredicate = nil;
    if ([searchText length] > 0) {
        searchPredicate = [NSPredicate predicateWithFormat:@"packageName CONTAINS [cd] %@ && submissionNew == %@", searchText, @NO];
    } else {
        searchPredicate = [NSPredicate predicateWithFormat:@"submissionNew == %@", @NO];
    }
    self.fetchedResultsController.fetchRequest.predicate = searchPredicate;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [[[UIAlertView alloc]initWithTitle:@"Error Performing Search"
                                   message:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil]show];
    }
    [self.tableView reloadData];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSArray *markedComplete = [MCSubmission findAllWithPredicate:[NSPredicate predicateWithFormat:@"submissionNew == %@", @NO]];
        for (MCSubmission *submission in markedComplete) {
            [MCSubmissionAction deleteSubmission:submission completion:^(BOOL success, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }];
        }
    }
}

@end
