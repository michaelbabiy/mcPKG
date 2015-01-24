//
//  MCAppDelegate.m
//  mcPKG
//
//  Created by iC on 1/27/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCSubmission+Create.h"
#import "MCWebAPi.h"
#import "MCParseConstants.h"

typedef void(^MCFetchCompletionHandlerBlock)(BOOL success);

@implementation MCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStack];
    [self.window setTintColor:[UIColor colorWithRed:0.318 green:0.725 blue:0.859 alpha:1.000]];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:21600]; // Every 6 hours...
    [Parse setApplicationId:kParseAPIApplicationID
                  clientKey:kParseAPIClientKey];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Setting applications badge count.
    [self setApplicationIconBadgeNumber];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [MCWebAPi GETRequestForAllSubmissionsWithFilter:kJotFormAPIRequestFilterNew
                                              order:kJotFormAPIRequestSortOrderByCreatedAt
                                              limit:kJotFormAPIRequestLimitDefault
                                         completion:^(BOOL success, NSArray *contents, NSError *error) {
                                             for (NSDictionary *content in contents) {
                                                 [MCSubmission submissionFromContent:content
                                                                          completion:^(BOOL success, NSError *error) {
                                                                              if (success) {
                                                                                  [self setApplicationIconBadgeNumber];
                                                                                  double delayInSeconds = 30.0;
                                                                                  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                                                  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                                      completionHandler(UIBackgroundFetchResultNewData);
                                                                                  });
                                                                              }
                                                                          }];
                                             }
                                         }];
}

- (void)setApplicationIconBadgeNumber
{
    NSArray *newPackages = [MCSubmission findAllWithPredicate:[NSPredicate predicateWithFormat:@"submissionNew == %@", @YES]];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0]; //[newPackage count]
}

@end
