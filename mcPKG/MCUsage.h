//
//  MCUsage.h
//  mcPKG
//
//  Created by iC on 2/2/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MCUsage : NSManagedObject

@property (nonatomic, retain) NSString * submissionsCount;
@property (nonatomic, retain) NSString * usageData;

@end
