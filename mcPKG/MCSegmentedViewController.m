//
//  MCSegmentedViewController.m
//  mcPKG
//
//  Created by iC on 1/27/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSegmentedViewController.h"
#import "MCOptionsViewController.h"
#import "MCCompletedViewController.h"

@interface MCSegmentedViewController () <MCOptionsViewControllerDelegate>

@end

@implementation MCSegmentedViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImage *paidPackageImage = [UIImage imageNamed:@"paid-package-icon"];
    UIImage *freePackageImage = [UIImage imageNamed:@"free-package-icon"];
    UIImage *updatePackageImage = [UIImage imageNamed:@"update-package-icon"];
    
    UITableViewController *paidPackageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MCPaidSubmissionViewController"];
    UITableViewController *freePackageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MCFreeSubmissionViewController"];
    UITableViewController *updatePackageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MCUpdateSubmissionViewController"];
    
    UIBarButtonItem *optionsBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(optionsButtonSelected:)];
    
    UIBarButtonItem *completedBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"complete-mark"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(completedButtonSelected:)];
    
//    UIBarButtonItem *completedBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
//                                                                                           target:self
//                                                                                           action:@selector(completedButtonSelected:)];

    
    self.navigationItem.leftBarButtonItem = optionsBarButtonItem;
    self.navigationItem.rightBarButtonItem = completedBarButtonItem;
    
    self.viewController = [[NSMutableArray alloc]initWithObjects:paidPackageVC, freePackageVC, updatePackageVC, nil];
    self.segmentItems = [NSMutableArray arrayWithObjects:paidPackageImage, freePackageImage, updatePackageImage, nil];
}

- (void)optionsButtonSelected:(id)sender
{
    [self performSegueWithIdentifier:@"MCOptionsViewController" sender:self];
}

- (void)completedButtonSelected:(id)sender
{
    [self performSegueWithIdentifier:@"MCCompletedViewController" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MCOptionsViewController"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        MCOptionsViewController *optionsViewController = (MCOptionsViewController *)navigationController.viewControllers.firstObject;
        optionsViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"MCCompletedViewController"]) {
        //
    }
}

#pragma mark - Options View Controller Delegate

- (void)optionsViewControllerDidFinish:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
