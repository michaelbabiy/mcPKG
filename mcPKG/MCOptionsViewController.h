//
//  MCOptionsViewController.h
//  mcPKG
//
//  Created by iC on 1/29/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MessageUI;

@protocol MCOptionsViewControllerDelegate <NSObject>

- (void)optionsViewControllerDidFinish:(id)sender;

@end

@interface MCOptionsViewController : UITableViewController

@property (weak, nonatomic) id <MCOptionsViewControllerDelegate> delegate;

@end
