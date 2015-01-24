//
//  MCRawControlValidator.h
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCRawControlValidator : NSObject

+ (NSString *)validateID:(NSString *)packageName;
+ (NSString *)validateName:(NSString *)packageName;
+ (NSString *)validateDescription:(NSString *)packageDescription;
+ (NSString *)validateDepiction:(NSString *)packageID;
+ (BOOL)isValidDescription:(NSString *)packageDescription;
+ (NSString *)validateURLString:(NSString *)URLString;
+ (NSString *)validateDependency:(NSString *)dependency;
+ (NSString *)validateAuthorname:(NSString *)authorName;

@end
