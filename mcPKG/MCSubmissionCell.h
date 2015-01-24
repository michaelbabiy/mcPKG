//
//  MCSubmissionCell.h
//  mcPKG
//
//  Created by iC on 1/24/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

@interface MCSubmissionCell : MCSwipeTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *submissionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *submissionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *submissionDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *submissionStatusView;

@end
