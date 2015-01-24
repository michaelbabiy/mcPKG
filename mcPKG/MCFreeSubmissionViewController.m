//
//  MCFreeSubmissionViewController.m
//  mcPKG
//
//  Created by iC on 1/27/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCFreeSubmissionViewController.h"
#import "MCDescriptionViewController.h"
#import "MCRawControl.h"

@interface MCFreeSubmissionViewController () <UISearchBarDelegate>

@property (strong, nonatomic) MCRawControl *rawControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (void)executeGETRequest;

@end

@implementation MCFreeSubmissionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self executeGETRequest];
    [self.refreshControl addTarget:self
                            action:@selector(executeGETRequest)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setFetchedResultsControllerForEntity:kMCSubmissionEntityName
                                     predicate:[NSPredicate predicateWithFormat:@"submissionFormID == %@ && submissionNew == %@", kJotFormFreePackageSubmissionForm, @YES]
                                          sort:@"submissionDate"];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]animated:YES];
    [self.tableView reloadData];
    
    // Setting rawControl to nil to avoid accumulating instances.
    self.rawControl = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)executeGETRequest
{
    [MCWebAPi GETRequestForAllSubmissionsWithFilter:kJotFormAPIRequestFilterNew
                                              order:kJotFormAPIRequestSortOrderByCreatedAt
                                              limit:kJotFormAPIRequestLimitDefault
                                         completion:^(BOOL success, NSArray *contents, NSError *error) {
                                             for (NSDictionary *content in contents) {
                                                 [MCSubmission submissionFromContent:content
                                                                          completion:^(BOOL success, NSError *error) {
                                                                              if (!error) {
                                                                                  [self.refreshControl endRefreshing];
                                                                              }
                                                                          }];
                                             }
                                         }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MCDescriptionViewController"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MCSubmission *submission = [self.fetchedResultsController objectAtIndexPath:indexPath];
        MCDescriptionViewController *descriptionViewController = (MCDescriptionViewController *)segue.destinationViewController;
        self.rawControl = [[MCRawControl alloc]initWithName:submission.packageName
                                                description:submission.packageDescription
                                                     author:submission.authorName
                                                      email:submission.authorEmail
                                                     isPaid:NO
                               screenshotsDownloadURLString:submission.screenshotDownloadURLString
                                   packageDownloadURLString:submission.packageDownloadURLString
                                               submissionID:submission.submissionID];
        descriptionViewController.rawControl = self.rawControl;
    }
}

#pragma mark - Setup

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSubmissionCell *submissionCell = [tableView dequeueReusableCellWithIdentifier:@"MCSubmissionCell"];
    [self configureCell:submissionCell forRowAtIndexPath:indexPath withSubmission:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return submissionCell;
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *searchPredicate = nil;
    if ([searchText length] > 0) {
        searchPredicate = [NSPredicate predicateWithFormat:@"packageName CONTAINS [cd] %@ && submissionFormID == %@", searchText, kJotFormFreePackageSubmissionForm];
    } else {
        searchPredicate = [NSPredicate predicateWithFormat:@"submissionFormID == %@", kJotFormFreePackageSubmissionForm];
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

@end
