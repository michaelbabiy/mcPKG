//
//  RandomPassword.h
//  QuickPassword
//
//  Created by Michael Babiy on 11/10/12.
//  Copyright (c) 2012 Pixel Delirious, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCRandomPassword : NSObject

+ (NSString *)generateKeyFromString:(NSString *)string;

@end
