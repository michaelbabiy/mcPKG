//
//  MCOptionsViewController.m
//  mcPKG
//
//  Created by iC on 1/29/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCOptionsViewController.h"
#import "MCSubmission.h"
#import "MCPackageID.h"
#import "MCDeveloper.h"
#import "MCWebAPi.h"
#import "MCUsage+Create.h"

@interface MCOptionsViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *submissionsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *usageDataLabel;

- (void)setUsageDetails:(MCUsage *)usage;
- (void)resetMCPKGButtonSelected:(id)sender;
- (IBAction)doneButtonSelected:(id)sender;
- (IBAction)refreshUsageButtonSelected:(id)sender;
- (IBAction)requestDetailsForMacCitiKey:(UILongPressGestureRecognizer *)sender;

@end

@implementation MCOptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUsageDetails:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)screenshotsDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories.firstObject;
    NSString *screenshotsDirectory = [documentDirectory stringByAppendingPathComponent:@"Screenshots"];
    return screenshotsDirectory;
}

- (void)setUsageDetails:(MCUsage *)usage
{
    if (!usage) {
        NSArray *results = [MCUsage findAll];
        if ([results count] > 0) {
            usage = [results firstObject];
        }
    }
    
    if (usage.submissionsCount) {
        self.submissionsCountLabel.text = [NSString stringWithFormat:@"Submissions: %@", usage.submissionsCount];
        self.usageDataLabel.text = [NSString stringWithFormat:@"Usage: %0.2fGB out of 10GB available.", [usage.usageData doubleValue] / 1073741824.0];
    }
}

- (void)resetMCPKGButtonSelected:(id)sender
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        [MCSubmission deleteAllMatchingPredicate:nil];
        [MCPackageID deleteAllMatchingPredicate:nil];
        [MCDeveloper deleteAllMatchingPredicate:nil];
    } completion:^(BOOL success, NSError *error) {
        if (!error) {
            [MagicalRecord cleanUp];
            [MagicalRecord setupCoreDataStack];
            [[NSFileManager defaultManager]removeItemAtPath:[self screenshotsDirectory]
                                                      error:nil];
            [[[UIAlertView alloc]initWithTitle:@"Success"
                                       message:@"mcPKG app has been reset successfully."
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil, nil]show];
        }
    }];
}

- (IBAction)doneButtonSelected:(id)sender
{
    [self.delegate optionsViewControllerDidFinish:self];
}

- (IBAction)refreshUsageButtonSelected:(id)sender
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.hidesWhenStopped = YES;
    [activityIndicatorView startAnimating];
    UIBarButtonItem *activityBarButton = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = activityBarButton;
    [MCWebAPi GETRequestForMonthlyUserUsageWithCompletionHandler:^(BOOL success, NSDictionary *content, NSError *error) {
        if (!error) {
            [MCUsage usageFromData:content completion:^(BOOL success, MCUsage *usage, NSError *error) {
                if (!error) {
                    [self setUsageDetails:usage];
                    [activityIndicatorView stopAnimating];
                    self.navigationItem.rightBarButtonItem = self.doneButton;
                }
            }];
        }
    }];
}

- (IBAction)requestDetailsForMacCitiKey:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
            [mailComposeViewController setSubject:@"MacCiti Key"];
            [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"Hey,\n\nTo generate your MacCiti Key, I need the following info:\n\n1. First and Last Name\n\n2. Cydia Dev ID (usually your PayPal account)\n\n3. Cydia account number (can be found in Cydia / Manage Account)\n\n4. Twitter username\n\nThanks!"]isHTML:NO];
            [mailComposeViewController setMailComposeDelegate:self];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                // First cell, first section.
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self resetMCPKGButtonSelected:nil];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                [self refreshUsageButtonSelected:nil];
                break;
                
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSaved:
            [self dismissViewControllerAnimated:YES completion:^{
                [[[UIAlertView alloc]initWithTitle:@"Email Saved"
                                           message:@"Email was not sent. Saved in drafts."
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil, nil]show];
            }];
            break;
        case MFMailComposeResultSent:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultFailed:
            [self dismissViewControllerAnimated:YES completion:^{
                [[[UIAlertView alloc]initWithTitle:@"Error Sending Email"
                                           message:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil, nil]show];
            }];
            break;
    }
}

@end
