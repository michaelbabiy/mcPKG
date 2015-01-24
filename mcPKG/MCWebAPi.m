//
//  MCWebAPi.m
//  mcPKG
//
//  Created by iC on 1/24/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCWebAPi.h"

#define MC_PACKAGE_ID_HTML_CHARACTERS @"<[^>]+>"

@implementation MCWebAPi

+ (void)GETRequestForForm:(NSString *)form filter:(kJotFormAPIRequestFilter)filter order:(kJotFormAPIRequestSortOrder)order limit:(kJotFormAPIRequestLimit)limit completion:(MCFormAPIGETRequestCompletionBlock)completionBlock
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@form/%@/submissions?apikey=%@&limit=%i&orderby=%@",
                                  kJotFormAPIBaseURLString,
                                  form,
                                  kJotFormAPIUserAPIKey,
                                  limit,
                                  [self order:order]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURLString parameters:[self filter:filter]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *response = (NSDictionary *)responseObject;
             NSArray *contents = response[@"content"];
             completionBlock(YES, contents, nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             completionBlock(NO, nil, error);
         }];
}

+ (void)GETRequestForAllSubmissionsWithFilter:(kJotFormAPIRequestFilter)filter order:(kJotFormAPIRequestSortOrder)order limit:(kJotFormAPIRequestLimit)limit completion:(MCFormAPIGETRequestCompletionBlock)completionBlock
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@user/submissions?apikey=%@&limit=%i&orderby=%@",
                                  kJotFormAPIBaseURLString,
                                  kJotFormAPIUserAPIKey,
                                  limit,
                                  [self order:order]];
    
    NSLog(@"%@", requestURLString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURLString parameters:[self filter:filter]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *response = (NSDictionary *)responseObject;
             NSArray *contents = response[@"content"];
             completionBlock(YES, contents, nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             completionBlock(NO, nil, error);
         }];
}

+ (void)DELETERequestForSubmission:(NSString *)submission completion:(MCFormAPIDELETERequestCompletionBlock)completionBlock
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@submission/%@?apiKey=%@",
                                  kJotFormAPIBaseURLString,
                                  submission,
                                  kJotFormAPIUserAPIKey];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager DELETE:requestURLString parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                completionBlock(YES, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                completionBlock(NO, error);
            }];
};

+ (void)POSTRequestForSubmission:(NSString *)submission parameters:(NSDictionary *)parameters completion:(MCFormAPIDELETERequestCompletionBlock)completionBlock
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@submission/%@?apiKey=%@",
                                  kJotFormAPIBaseURLString,
                                  submission,
                                  kJotFormAPIUserAPIKey];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:requestURLString parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              completionBlock(YES, nil);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completionBlock(NO, error);
          }];
}

+ (void)GETRequestForPackageIDContaining:(NSString *)searchTerm completion:(MCFormAPIGETRequestCompletionBlock)completionBlock
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc]initWithSessionConfiguration:sessionConfiguration];
    
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", kZodTTDBaseURLString, searchTerm];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request
                                                                            progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                                NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                                                NSString *documentsDirectory = documentsDirectories.firstObject;
                                                                                NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:documentsDirectory];
                                                                                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                                if (!error) {
                                                                                    dispatch_queue_t processingQ = dispatch_queue_create("processingQ", NULL);
                                                                                    dispatch_async(processingQ, ^{
                                                                                        NSString *packageIDString = [NSString stringWithContentsOfFile:filePath.path
                                                                                                                                              encoding:NSUTF8StringEncoding error:nil];
                                                                                        NSArray *packageIDs = [self packageIDsFromString:packageIDString];
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            completionBlock(YES, packageIDs, nil);
                                                                                        });
                                                                                    });
                                                                                } else {
                                                                                    completionBlock(NO, nil, error);
                                                                                }
                                                                            }];
    [downloadTask resume];
}

+ (void)GETREquestForPackageFileWithURL:(NSURL *)fileURL packageDirectoryPath:(NSString *)packageDirectory observer:(id)observer completion:(MCFormAPIGETRequestCompletionBlock)completionBlock
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc]initWithSessionConfiguration:sessionConfiguration];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request
                                                                            progress:&progress
                                                                         destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                             NSURL *packageDir = [NSURL fileURLWithPath:packageDirectory];
                                                                             return [packageDir URLByAppendingPathComponent:[response suggestedFilename]];
                                                                         } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                             if (!error) {
                                                                                 [progress removeObserver:observer forKeyPath:@"fractionCompleted"];
                                                                                 completionBlock(YES, nil, nil);
                                                                             } else {
                                                                                 completionBlock(NO, nil, error);
                                                                             }
                                                                         }];
    [downloadTask resume];
    [progress addObserver:observer forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
}

+ (void)GETRequestForMonthlyUserUsageWithCompletionHandler:(MCFormUsageAPIRequestCompletionBlock)completionBlock
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@user/usage?apikey=%@", kJotFormAPIBaseURLString, kJotFormAPIUserAPIKey];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURLString parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *response = (NSDictionary *)responseObject;
             NSDictionary *content = response[@"content"];
             completionBlock(YES, content, nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             completionBlock(NO, nil, error);
         }];
}

#pragma mark - Helper Methods

+ (NSArray *)packageIDsFromString:(NSString *)string
{
    NSString *packageIDString = [string stringByReplacingOccurrencesOfString:MC_PACKAGE_ID_HTML_CHARACTERS
                                                                  withString:@""
                                                                     options:NSRegularExpressionSearch
                                                                       range:NSMakeRange(0, string.length)];
    packageIDString = [packageIDString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    packageIDString = [packageIDString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [packageIDString componentsSeparatedByString:@","];
}

+ (NSString *)order:(kJotFormAPIRequestSortOrder)order
{
    switch (order) {
        case kJotFormAPIRequestSortOrderByID:
            return @"id";
            break;
        case kJotFormAPIRequestSortOrderByUsername:
            return @"username";
            break;
        case kJotFormAPIRequestSortOrderByTitle:
            return @"title";
            break;
        case kJotFormAPIRequestSortOrderByStatus:
            return @"status";
            break;
        case kJotFormAPIRequestSortOrderByCreatedAt:
            return @"created_at";
            break;
        case kJotFormAPIRequestSortOrderByUpdatedAt:
            return @"updated_at";
            break;
        case kJotFormAPIRequestSortOrderByNew:
            return @"new";
            break;
        case kJotFormAPIRequestSortOrderByCount:
            return @"count";
            break;
        case kJotFormAPIRequestSortOrderBySlug:
            return @"slug";
            break;
        default:
            return @"created_at";
            break;
    }
}

+ (NSDictionary *)filter:(kJotFormAPIRequestFilter)filter
{
    switch (filter) {
        case kJotFormAPIRequestFilterNone:
            return nil;
            break;
        case kJotFormAPIRequestFilterNew:
            return @{@"filter" : @{@"new" : @"1"}};
            break;
        case kJotFormAPIRequestFilterOld:
            return @{@"filter" : @{@"new" : @"0"}};
            break;
        default:
            return nil;
            break;
    }
}

@end
