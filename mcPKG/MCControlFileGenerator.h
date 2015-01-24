//
//  MCControlFileGenerator.h
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCRawControl;

@interface MCControlFileGenerator : NSObject

+ (NSString *)generateControlFileFromMCRawContro:(MCRawControl *)rawControl;

@end
