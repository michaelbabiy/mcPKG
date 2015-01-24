//
//  MCDevelopersViewController.m
//  mcPKG
//
//  Created by iC on 1/31/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCDevelopersViewController.h"
#import "MCParseConstants.h"
#import "MCDeveloper+Create.h"
#import "MCMacCitiKeyViewController.h"

@interface MCDevelopersViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

- (void)executeGETRequest;
- (IBAction)deleteButtonSelected:(id)sender;

@end

@implementation MCDevelopersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(executeGETRequest)
                  forControlEvents:UIControlEventValueChanged];
    
    [self setFetchedResultsControllerForEntity:kMCDeveloperEntityName
                                     predicate:nil
                                          sort:@"firstName"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)executeGETRequest
{
    PFQuery *developerQuery = [PFQuery queryWithClassName:kDeveloperClass];
    [developerQuery setLimit:1000];
    [developerQuery orderByDescending:@"createdAt"];
    [developerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [MCDeveloper developerFromParseObject:object
                                           completion:^(BOOL success, NSError *error) {
                                               if (!error) {
                                                   [self.refreshControl endRefreshing];
                                                   [self.navigationItem setRightBarButtonItem:self.deleteButton];
                                               }
                                           }];
            }
        }
    }];
}

- (IBAction)deleteButtonSelected:(id)sender
{
    [[[UIAlertView alloc]initWithTitle:@"Delete all developers?"
                               message:@"This action will only delete local copies and will re-sync with Parse automatically."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"Delete", nil]show];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MCMacCitiKeyViewController"]) {
        MCMacCitiKeyViewController *maccitiKeyViewController = (MCMacCitiKeyViewController *)segue.destinationViewController;
        MCDeveloper *developer = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        maccitiKeyViewController.developer = developer;
    }
}

#pragma mark - Fetched Results Controller

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *developerCell = [tableView dequeueReusableCellWithIdentifier:@"MCDeveloperCell"];
    MCDeveloper *developer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    developerCell.textLabel.text = [NSString stringWithFormat:@"%@ %@", developer.firstName, developer.lastName];
    developerCell.detailTextLabel.text = [NSString stringWithFormat:@"mcID: %@", developer.maccitiKey];
    return developerCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCDeveloper *developer = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [localContext deleteObject:developer];
        } completion:^(BOOL success, NSError *error) {
            if (!error) {
                PFQuery *developerQuery = [PFQuery queryWithClassName:kDeveloperClass];
                [developerQuery whereKey:kDeveloperMacCitiKey containsString:developer.maccitiKey];
                [developerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error && [objects count] > 0) {
                        PFObject *object = objects.firstObject;
                        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error) {
                                // Deleted...
                            }
                        }];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *searchPredicate = nil;
    if ([searchText length] > 0) {
        searchPredicate = [NSPredicate predicateWithFormat:@"developerID CONTAINS [cd] %@ || firstName CONTAINS [cd] %@ || lastName CONTAINS [cd] %@ || maccitiKey CONTAINS [cd] %@",
                           searchText,
                           searchText,
                           searchText,
                           searchText];
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

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.hidesWhenStopped = YES;
        [activityIndicatorView startAnimating];
        UIBarButtonItem *activityBarButton = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
        self.navigationItem.rightBarButtonItem = activityBarButton;
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [MCDeveloper deleteAllMatchingPredicate:nil];
        } completion:^(BOOL success, NSError *error) {
            if (!error) {
                [self executeGETRequest];
            }
        }];
    }
}

@end
