//
//  MCSwipeCellViewController.h
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCFetchedResultsController.h"
#import "MCSubmissionCell.h"

#import "MCWebAPi.h"

#define MC_TABLE_VIEW_CELL_GREEN_COLOR [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
#define MC_TABLE_VIEW_CELL_RED_COLOR [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
#define MC_TABLE_VIEW_CELL_YELLOW_COLOR [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
#define MC_TABLE_VIEW_CELL_BLUE_COLOR [UIColor colorWithRed:0.318 green:0.725 blue:0.859 alpha:1.000]

@interface MCSwipeCellViewController : MCFetchedResultsController

/**
 *  Method for configuring swipable cell. Each VC interested in implementing swipable
 *  cell should subclass this clas..
 *
 *  @param cell       used for setting cell's properties.
 *  @param indexPath  of the cell.
 *  @param submission entity to extract relevant data for cell at index path
 */
- (void)configureCell:(MCSubmissionCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
       withSubmission:(MCSubmission *)submission;

@end
