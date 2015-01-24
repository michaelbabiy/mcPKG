//
//  MCWebAPi.h
//  mcPKG
//
//  Created by iC on 1/24/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kJotFormAPIUserAPIKey = @"API_KEY";
static NSString * const kJotFormAPIBaseURLString = @"https://api.jotform.com/";

static NSString * const kJotFormFreePackageSubmissionForm = @"000";
static NSString * const kJotFormPaidPackageSubmissionForm = @"000";
static NSString * const kJotFormUpdatePackageSubmissionForm = @"000";

static NSString * const kZodTTDDefaultSearchTerm = @"search";
static NSString * const kZodTTDBaseURLString = @"http:www.example.com";

typedef enum
{
    kJotFormAPIRequestSortOrderByID = 0,
    kJotFormAPIRequestSortOrderByUsername = 1,
    kJotFormAPIRequestSortOrderByTitle = 2,
    kJotFormAPIRequestSortOrderByStatus = 3,
    kJotFormAPIRequestSortOrderByCreatedAt = 4,
    kJotFormAPIRequestSortOrderByUpdatedAt = 5,
    kJotFormAPIRequestSortOrderByNew = 6,
    kJotFormAPIRequestSortOrderByCount = 7,
    kJotFormAPIRequestSortOrderBySlug = 8,
}kJotFormAPIRequestSortOrder;

typedef enum
{
    kJotFormAPIRequestFilterNone = 0,
    kJotFormAPIRequestFilterNew = 1,
    kJotFormAPIRequestFilterOld = 2,
}kJotFormAPIRequestFilter;

typedef enum
{
    kJotFormAPIRequestLimitDebug = 1,
    kJotFormAPIRequestLimitDefault = 100,
    kJotFormAPIRequestLimitMax = 1000,
}kJotFormAPIRequestLimit;

/**
 *  Completion block to be executed when
 *  the request is completed.
 *
 *  @param success is set to ether YES or NO
 *  based on the response from Jotform.
 *
 *  @return nothing.
 */
typedef void(^MCFormAPIGETRequestCompletionBlock)(BOOL success, NSArray *contents, NSError *error);

typedef void(^MCFormAPIDELETERequestCompletionBlock)(BOOL success, NSError *error);

/**
 *  Usage is returned as Dictionary, not array.
 *
 *  @param success YES if request was executed successfully.
 *  @param content containing information about the usage.
 *  @param error   containing description of the error returned.
 *
 *  @return nothing.
 */
typedef void(^MCFormUsageAPIRequestCompletionBlock)(BOOL success, NSDictionary *content, NSError *error);

@interface MCWebAPi : NSObject

/**
 *  Method responsible for performing GET requests to
 *  Jotform and passing the data to CoreData for saving.
 *
 *  @param form            ID to query forsubmissions.
 *  @param filter          specifies if Jotform should return all, only new or only old submissions.
 *  @param order           specifies the order of submissions returned from Jotform.
 *  @param limit           of results to be returned.
 *  @param completionBlock BOOL, ARRAY, ERROR.
 */
+ (void)GETRequestForForm:(NSString *)form
                   filter:(kJotFormAPIRequestFilter)filter
                    order:(kJotFormAPIRequestSortOrder)order
                    limit:(kJotFormAPIRequestLimit)limit
               completion:(MCFormAPIGETRequestCompletionBlock)completionBlock;

/**
 *  While the method above allows for creater control (as in, give me this form data),
 *  this method returns more value for the buck. First of all, it will request for all new
 *  submissions (paid, free, updates). It will also be used for background fetch.
 *
 *  @param filter          specifies if Jotform should return all, only new or only old submissions.
 *  @param order           specifies the order of submissions returned from Jotform.
 *  @param limit           of results to be returned.
 *  @param completionBlock BOOL, ARRAY, ERROR.
 */
+ (void)GETRequestForAllSubmissionsWithFilter:(kJotFormAPIRequestFilter)filter
                                        order:(kJotFormAPIRequestSortOrder)order
                                        limit:(kJotFormAPIRequestLimit)limit
                                   completion:(MCFormAPIGETRequestCompletionBlock)completionBlock;

/**
 *  Method for performing DELETE request for specified submission.
 *
 *  @param submission      ID to be deleted.
 *  @param completionBlock executed when the request is complete.
 */
+ (void)DELETERequestForSubmission:(NSString *)submission
                        completion:(MCFormAPIDELETERequestCompletionBlock)completionBlock;

/**
 *  Method for performing POST request for specified submisison.
 *  This is manly used to mark submission complete.
 *
 *  @param submission      ID to be marked as complete.
 *  @param completionBlock executed when the request is complete.
 */
+ (void)POSTRequestForSubmission:(NSString *)submission
                      parameters:(NSDictionary *)parameters
                      completion:(MCFormAPIDELETERequestCompletionBlock)completionBlock;

/**
 *  Method responsible for making GET requests for package IDs
 *  to ZodTTD.com.
 *
 *  @param searchTerm      defaults to "macciti" and will return all paid package IDs.
 *  @param completionBlock returns BOOL, ARRAY of IDs, ERROR.
 */
+ (void)GETRequestForPackageIDContaining:(NSString *)searchTerm
                              completion:(MCFormAPIGETRequestCompletionBlock)completionBlock;

/**
 *  MEthod for downloading files anf reposrting progress using NSProgress clas..
 *
 *  @param fileURL          of the file to be downloaded.
 *  @param packageDirectory path where the file should be saved.
 *  @param observer         class / VC that makes the call. The class will need to implement - observeValueForKeyPath:ofObject:change:context:
 *  @param completionBlock  returns BOOL, ERROR.
 */
+ (void)GETREquestForPackageFileWithURL:(NSURL *)fileURL
                   packageDirectoryPath:(NSString *)packageDirectory
                               observer:(id)observer
                             completion:(MCFormAPIGETRequestCompletionBlock)completionBlock;

/**
 *  Method for requestion montly user usage from JotForm.
 *
 *  @param completionBlock BOOL, ARRAY of IDs, ERROR.
 */
+ (void)GETRequestForMonthlyUserUsageWithCompletionHandler:(MCFormUsageAPIRequestCompletionBlock)completionBlock;

@end
