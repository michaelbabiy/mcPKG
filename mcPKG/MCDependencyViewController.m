//
//  MCDependencyViewController.m
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCDependencyViewController.h"
#import "MCSaveViewController.h"
#import "MCWebAPi.h"

#import "MCRawControl.h"
#import "MCRawControlValidator.h"

@interface MCDependencyViewController ()

- (void)executeGETRequest;

@end

@implementation MCDependencyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(executeGETRequest)
                  forControlEvents:UIControlEventValueChanged];
    
    [self setFetchedResultsControllerForEntity:kMCPackageIDEntityName
                                     predicate:nil
                                          sort:@"packageID"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)executeGETRequest
{
    [MCWebAPi GETRequestForPackageIDContaining:kZodTTDDefaultSearchTerm
                                    completion:^(BOOL success, NSArray *contents, NSError *error) {
                                        if (!error) {
                                            for (NSString *packageID in contents) {
                                                [MCPackageID packageIDFromString:packageID
                                                                      completion:^(BOOL success, NSError *error) {
                                                                          if (!error) {
                                                                              [self.refreshControl endRefreshing];
                                                                          }
                                                                      }];
                                            }
                                        }
    }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MCSaveViewController"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MCPackageID *packageID = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.rawControl.packageDependency = [MCRawControlValidator validateDependency:packageID.packageID];
        MCSaveViewController *saveViewController = (MCSaveViewController *)segue.destinationViewController;
        saveViewController.rawControl = self.rawControl;
    }
}

#pragma mark - Setup

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *packageIDCell = [tableView dequeueReusableCellWithIdentifier:@"PackageIDCell"];
    MCPackageID *packageID = [self.fetchedResultsController objectAtIndexPath:indexPath];
    packageIDCell.textLabel.text = packageID.packageID;
    return packageIDCell;
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *searchPredicate = nil;
    if ([searchText length] > 0) {
        searchPredicate = [NSPredicate predicateWithFormat:@"packageID CONTAINS [cd] %@", searchText];
    } else {
        searchPredicate = [NSPredicate predicateWithFormat:@"packageID CONTAINS [cd] %@", @"macciti"];
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
