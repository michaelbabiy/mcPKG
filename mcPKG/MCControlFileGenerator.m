//
//  MCControlFileGenerator.m
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCControlFileGenerator.h"
#import "MCRawControl.h"

@implementation MCControlFileGenerator

+ (NSString *)generateControlFileFromMCRawContro:(MCRawControl *)rawControl
{
    NSString *packageID = [NSString stringWithFormat:@"Package: com.macciti.%@", rawControl.packageID];
    NSString *packageName = [NSString stringWithFormat:@"Name: %@", rawControl.packageName];
    NSString *packageVersion = [NSString stringWithFormat:@"Version: %@", rawControl.packageVersion];
    NSString *packageArchitecture = [NSString stringWithFormat:@"Architecture: %@", rawControl.packageArchitecture];
    NSString *packageDependency = [NSString stringWithFormat:@"Depends: %@", rawControl.packageDependency];
    NSString *packageDescription = [NSString stringWithFormat:@"Description: %@", rawControl.packageDescription];
    NSString *packageMaintainer = [NSString stringWithFormat:@"Maintainer: %@", rawControl.packageMaintainer];
    NSString *packageAuthor = [NSString stringWithFormat:@"Author: %@ <%@>", rawControl.authorName, rawControl.authorEmail];
    NSString *packageSection = [NSString stringWithFormat:@"Section: %@", rawControl.packageSection];
    NSString *packageDepiction = [NSString stringWithFormat:@"Depiction: %@", rawControl.packageDepiction];
    
    NSString *controlFile = nil;
    
    if (rawControl.packageIsPaid) {
        controlFile = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
                       packageID, packageName, packageVersion,
                       packageArchitecture, packageDependency,
                       packageDescription, packageMaintainer,
                       packageAuthor, packageSection, packageDepiction, @"tag: cydia::commercial"];
    } else {
        controlFile = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
                       packageID, packageName, packageVersion,
                       packageArchitecture, packageDependency,
                       packageDescription, packageMaintainer,
                       packageAuthor, packageSection, packageDepiction];
    }
    
    return controlFile;
}

@end
