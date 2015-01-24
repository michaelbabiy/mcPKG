//
//  MCDependencyViewController.h
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCFetchedResultsController.h"
@class MCRawControl;

@interface MCDependencyViewController : MCFetchedResultsController

@property (strong, nonatomic) MCRawControl *rawControl;

@end
