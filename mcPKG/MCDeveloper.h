//
//  MCDeveloper.h
//  mcPKG
//
//  Created by iC on 2/2/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MCDeveloper : NSManagedObject

@property (nonatomic, retain) NSString * accountNumber;
@property (nonatomic, retain) NSString * developerID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * maccitiKey;
@property (nonatomic, retain) NSString * twitterHandle;

@end
