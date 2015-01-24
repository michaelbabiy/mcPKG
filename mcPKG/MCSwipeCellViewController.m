//
//  MCSwipeCellViewController.m
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSwipeCellViewController.h"
#import "MCSubmissionAction.h"
#import "MCRawControlValidator.h"

@interface MCSwipeCellViewController ()

@end

@implementation MCSwipeCellViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView *)viewWithImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void)configureCell:(MCSubmissionCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withSubmission:(MCSubmission *)submission
{
    [cell setDefaultColor:[UIColor colorWithWhite:0.890 alpha:1.000]];
    
    if ([submission.submissionFormID isEqualToString:kJotFormUpdatePackageSubmissionForm]) {
        
        // This will search for developers name based on the MacCiti Key provided.
        NSArray *results = [MCDeveloper findAllWithPredicate:[NSPredicate predicateWithFormat:@"maccitiKey == %@", submission.maccitiKey]];
        MCDeveloper *developer = [results firstObject];
        NSString *updateAuthor = [NSString stringWithFormat:@"%@ %@", developer.firstName, developer.lastName];
        if ([updateAuthor length] != 0) {
            cell.authorNameLabel.text = updateAuthor;
        } else {
            cell.authorNameLabel.text = submission.maccitiKey;
        }
        
        cell.submissionNameLabel.text = [MCRawControlValidator validateName:submission.packageName];
        cell.submissionDescriptionLabel.text = submission.packageChangeLog;
        cell.submissionDateLabel.text = [NSDateFormatter localizedStringFromDate:submission.submissionDate
                                                                       dateStyle:NSDateFormatterShortStyle
                                                                       timeStyle:NSDateFormatterNoStyle];
    } else if ([submission.submissionFormID isEqualToString:kJotFormPaidPackageSubmissionForm] || [submission.submissionFormID isEqualToString:kJotFormFreePackageSubmissionForm]) {
        cell.authorNameLabel.text = [MCRawControlValidator validateName:submission.authorName];
        cell.submissionNameLabel.text = [MCRawControlValidator validateName:submission.packageName];
        cell.submissionDescriptionLabel.text = submission.packageDescription;
        cell.submissionDateLabel.text = [NSDateFormatter localizedStringFromDate:submission.submissionDate
                                                                       dateStyle:NSDateFormatterShortStyle
                                                                       timeStyle:NSDateFormatterNoStyle];
    }
    
    if ([submission.submissionNew boolValue]) {
        cell.submissionStatusView.image = [UIImage imageNamed:@"status"];
    } else {
        cell.submissionStatusView.image = nil;
    }
    
    /**
     *  Setting up cell actions based on cell passed along.
     */
    if ([cell.reuseIdentifier isEqualToString:@"MCCompletedCell"]) {
        [cell setSwipeGestureWithView:[self viewWithImage:@"cross"]
                                color:MC_TABLE_VIEW_CELL_RED_COLOR
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState1
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                          [MCSubmissionAction deleteSubmission:submission completion:^(BOOL success, NSError *error) {
                              if (error) {
                                  // NSLog(@"Error: %@", [error localizedDescription]);
                              }
                          }];
                      }];
        
        [cell setSwipeGestureWithView:[self viewWithImage:@"mailbox"]
                                color:MC_TABLE_VIEW_CELL_BLUE_COLOR
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState3
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                          [MCSubmissionAction markSubmissionNew:submission completion:^(BOOL success, NSError *error) {
                              if (error) {
                                  // NSLog(@"Error: %@", [error localizedDescription]);
                              }
                          }];
                      }];
    } else {
        [cell setSwipeGestureWithView:[self viewWithImage:@"check"]
                                color:MC_TABLE_VIEW_CELL_GREEN_COLOR
                                 mode:MCSwipeTableViewCellModeExit//MCSwipeTableViewCellModeSwitch
                                state:MCSwipeTableViewCellState1
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                          [MCSubmissionAction markSubmissionCompleted:submission completion:^(BOOL success, NSError *error) {
                              if (error) {
                                  // NSLog(@"Error: %@", [error localizedDescription]);
                              }
                          }];
                      }];
        
        [cell setSwipeGestureWithView:[self viewWithImage:@"cross"]
                                color:MC_TABLE_VIEW_CELL_RED_COLOR
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState2
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                          [MCSubmissionAction deleteSubmission:submission completion:^(BOOL success, NSError *error) {
                              if (error) {
                                  // NSLog(@"Error: %@", [error localizedDescription]);
                              }
                          }];
                      }];
    }
}

@end
