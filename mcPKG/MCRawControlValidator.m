//
//  MCRawControlValidator.m
//  mcPKG
//
//  Created by iC on 1/20/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCRawControlValidator.h"

static NSString * const kMacCitiPackageIDPrefix = @"com.macciti.";

#define MC_PACKAGE_ID_REGEX @"[a-z0-9+-]{2,30}"
#define MC_PACKAGE_ID_INVALID_CHARACTERS @"['/()!?., $%=_*^#@<>{}:;]"
#define MC_PACKAGE_NAME_INVALID_CHARACTERS @"['/()!?.,$%=_*^#@<>{}:;]" // The only difference between this and MC_PACKAGE_ID_INVALID_CHARACTERS is ALLOWED SPACE.

#define MC_PACKAGE_DESCRIPTION_REGEX @"^[A-Z0-9a-z ,.-]+$" // Only letters and numbers + space and...
#define MC_PACKAGE_DESCRIPTION_INVALID_CHARACTERS @"['+&/()!?$%=_*^#@<>{}:;]"

#define MC_EMPTY_SPACE_STRING @" "
#define MC_EMPTY_STRING @""

@implementation MCRawControlValidator

#pragma mark - Setup

+ (NSArray *)invalidStrings
{
    static NSArray *invalidString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invalidString = [[NSArray alloc]initWithObjects:
                         @"\r\n",
                         @"\n",
                         @"    ",
                         @"   ",
                         @"  ",
                         @" 039 ",
                         @"quot", nil];
    });
    return invalidString;
}

+ (NSString *)removeSpecialCharacters:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&amp;"
                                               withString:@"and"];
    
    string = [string stringByReplacingOccurrencesOfString:@"  "
                                               withString:MC_EMPTY_SPACE_STRING];
    
    return string;
}

#pragma mark - Validator Methods

+ (NSString *)validateID:(NSString *)packageName
{
    NSString *lowerCaseString = [packageName lowercaseString];
    NSString *packageID = [lowerCaseString stringByReplacingOccurrencesOfString:MC_PACKAGE_ID_INVALID_CHARACTERS
                                                                     withString:MC_EMPTY_STRING
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, lowerCaseString.length)];
    
    NSPredicate *packageIDTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MC_PACKAGE_ID_REGEX];
    if ([packageIDTest evaluateWithObject:packageID]) {
        return packageID;
    } else {
        return packageID;
        [[[UIAlertView alloc]initWithTitle:@"Warning!"
                                   message:@"Package ID didn't pass the validation. Please look into this."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil]show];
    }
}

+ (NSString *)validateName:(NSString *)packageName
{
    packageName = [self removeSpecialCharacters:packageName];
    packageName = [packageName stringByReplacingOccurrencesOfString:MC_PACKAGE_NAME_INVALID_CHARACTERS
                                                         withString:MC_EMPTY_STRING
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, packageName.length)];
    return packageName;
}

+ (NSString *)validateDescription:(NSString *)packageDescription
{
    packageDescription = [packageDescription stringByReplacingOccurrencesOfString:MC_PACKAGE_DESCRIPTION_INVALID_CHARACTERS
                                                                       withString:MC_EMPTY_SPACE_STRING
                                                                          options:NSRegularExpressionSearch
                                                                            range:NSMakeRange(0, packageDescription.length)];
    for (NSString *invalidString in [self invalidStrings]) {
        packageDescription = [packageDescription stringByReplacingOccurrencesOfString:invalidString
                                                                           withString:MC_EMPTY_SPACE_STRING];
    }
    
    // This will make sure the first letter in the description is always capital.
    // Dedicated to coccco theme designer. He never capitalizes his first letters.
    if (packageDescription.length > 1) {
        NSString *firstCapChar = [[packageDescription substringToIndex:1] capitalizedString];
        packageDescription = [packageDescription stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    }
    
    // This makes sure the description I see is no longer than 499 characters.
    // I dont need need to see more considering that I need only 60 characters/max.
    if ([packageDescription length] > 300) {
        packageDescription = [packageDescription substringToIndex:299];
    }
    
    return packageDescription;
}

+ (BOOL)isValidDescription:(NSString *)packageDescription
{
    NSPredicate *packageIDTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MC_PACKAGE_DESCRIPTION_REGEX];
    if ([packageIDTest evaluateWithObject:packageDescription]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)validateDepiction:(NSString *)packageID
{
    return [NSString stringWithFormat:@"http://www.macciti.com/pages/%@/index.php", packageID];
}

+ (NSString *)validateURLString:(NSString *)URLString
{
    if ([URLString rangeOfString:@" "].location != NSNotFound) {
        URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    return URLString;
}

+ (NSString *)validateDependency:(NSString *)dependency
{
    if ([dependency rangeOfString:@"winterboard"].location != NSNotFound) {
        dependency = @"winterboard";
    } else if ([dependency rangeOfString:@"bytafont2"].location != NSNotFound) {
        dependency = @"com.bytafont.bytafont2";
    } else if ([dependency rangeOfString:@"groovylocktweak"].location != NSNotFound) {
        dependency = @"com.groovycarrot.groovylock";
    }
    return dependency;
}

+ (NSString *)validateAuthorname:(NSString *)authorName
{
    authorName = [self removeSpecialCharacters:authorName];
    // This is to make sure these letters are not added to the authors name.
    // They cause "Author" field to be all messed up and giberish. 
    authorName = [authorName stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
    authorName = [authorName stringByReplacingOccurrencesOfString:@"á" withString:@"a"];
    
    return authorName;
}

@end
