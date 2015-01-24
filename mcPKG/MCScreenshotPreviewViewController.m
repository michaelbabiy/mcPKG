//
//  MCScreenshotPreviewViewController.m
//  mcPKG
//
//  Created by iC on 1/30/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCScreenshotPreviewViewController.h"
#import "MCRawControl.h"
#import "MCWebAPi.h"
#import "MCRawControlValidator.h"
#import "LDProgressView.h"
#import "SSZipArchive.h"

@interface MCScreenshotPreviewViewController () <SSZipArchiveDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) NSInteger imagesCount;

/**
 *  isDirectory and imageDirectory are designed to be used together.
 *  If Screenshots directory contains another directory that in turn
 *  contains images, isDirectory will be YES and imageDirectory will be
 *  set to the new path from which we can extract files.
 */
@property (assign, nonatomic) BOOL isDirectory;
@property (strong, nonatomic) NSString *imageDirectory;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) LDProgressView *progressView;

- (NSString *)screenshotsDirectory;
- (void)deleteButtonSelected:(id)sender;
- (void)tweetSubmissionImage:(UIImage *)image description:(NSString *)description;
- (IBAction)composeEmailButtonSelected:(id)sender;
- (IBAction)nextImageButtonSelected:(UITapGestureRecognizer *)sender;

@end

@implementation MCScreenshotPreviewViewController

- (NSArray *)images
{
    if (!_images) {
        _images = [[NSArray alloc]init];
    }
    return _images;
}

- (LDProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-2, 564, self.view.frame.size.width+4, 6)];
        _progressView.color = [UIColor colorWithRed:0.318 green:0.725 blue:0.859 alpha:1.000];
        _progressView.flat = @YES;
        _progressView.animate = @YES;
        _progressView.showText = @NO;
        _progressView.showStroke = @NO;
        _progressView.progressInset = @1;
        _progressView.showBackground = @NO;
        _progressView.outerStrokeWidth = @0;
        _progressView.type = LDProgressSolid;
    }
    return _progressView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.progressView];
    [[NSFileManager defaultManager]removeItemAtPath:[self screenshotsDirectory]
                                              error:nil];
    
    NSLog(@"%@", self.rawControl.screenshotsDownloadURLString);
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:[self screenshotsDirectory]]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:[self screenshotsDirectory]
                                 withIntermediateDirectories:NO
                                                  attributes:nil
                                                       error:nil];
    }
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MCWebAPi GETREquestForPackageFileWithURL:[NSURL URLWithString:[MCRawControlValidator validateURLString:self.rawControl.screenshotsDownloadURLString]]
                             packageDirectoryPath:[self screenshotsDirectory]
                                         observer:self
                                       completion:^(BOOL success, NSArray *contents, NSError *error) {
                                           if (!error) {
                                               NSArray *contentsOfScreenshotDirectory = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self screenshotsDirectory]
                                                                                                                                           error:nil];
                                               if ([contentsOfScreenshotDirectory count] > 0) {
                                                   NSString *screenshotsZIPPath = contentsOfScreenshotDirectory.firstObject;
                                                   [SSZipArchive unzipFileAtPath:[[self screenshotsDirectory]stringByAppendingPathComponent:screenshotsZIPPath]
                                                                   toDestination:[self screenshotsDirectory]delegate:self];
                                               }
                                           }
                                       }];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSFileManager defaultManager]removeItemAtPath:[self screenshotsDirectory] error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)screenshotsDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories.firstObject;
    NSString *screenshotsDirectory = [documentDirectory stringByAppendingPathComponent:@"Screenshots"];
    return screenshotsDirectory;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.fractionCompleted;
            self.navigationItem.title = [NSString stringWithFormat:@"%.f%%", progress.fractionCompleted * 100];
        });
    }
}

- (void)deleteButtonSelected:(id)sender
{
    NSError *error = nil;
    [[NSFileManager defaultManager]removeItemAtPath:[self screenshotsDirectory] error:&error];
    if (!error) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tweetSubmissionImage:(UIImage *)image description:(NSString *)description
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController addImage:image];
        [self presentViewController:composeViewController animated:YES completion:nil];
        [composeViewController setCompletionHandler: ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultDone) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    } else {
        [[[UIAlertView alloc]initWithTitle:@"Error Composing a Tweet"
                                   message:@"Twitter account is not configured in Settings."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil]show];
    }
}

- (IBAction)composeEmailButtonSelected:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose email content."
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Package Rejected", @"Request PSD Files", @"Tweet This Image", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)nextImageButtonSelected:(UITapGestureRecognizer *)sender
{
    self.imagesCount--;
    if (self.imagesCount == -1) {
        self.imagesCount = [self.images count] - 1;
    }
    
    NSString *imagePath = [self.images objectAtIndex:self.imagesCount];
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (_isDirectory) {
            if (self.imagesCount >= 0) {
                self.imageView.image = [UIImage imageWithContentsOfFile:[self.imageDirectory stringByAppendingPathComponent:imagePath]];
            }
        } else {
            if (self.imagesCount >= 0) {
                self.imageView.image = [UIImage imageWithContentsOfFile:[[self screenshotsDirectory] stringByAppendingPathComponent:imagePath]];
            }
        }
    }
}

#pragma mark - SSZipArchive

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    // Remove archive and other bad files. Dont need it anymore.
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    
    /**
     *  If images zipped on the Mac, sometimes the folder containing images will
     *  include the __MACOSX folder. There is no certain way of knowing the index of that folder
     *  so I'll have to "wing it", or execute "remove" command just in case.
     */
    [[NSFileManager defaultManager]removeItemAtPath:[unzippedPath stringByAppendingPathComponent:@"__MACOSX"] error:nil];
    
    // Add all images to the images array.
    NSArray *contents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:unzippedPath
                                                                           error:nil];
    
    /**
     *  Sometimes users place their screenshots in a directory and then zip
     *  that directory instead of zipping "selected" images. If thats the case,
     *  we need to make sure we navigate to that directory in Screenshots folder
     *  and then create an array of images. Oterwise, just create an array of images.
     */
    if ([[NSFileManager defaultManager]fileExistsAtPath:[unzippedPath stringByAppendingPathComponent:[contents firstObject]] isDirectory:&_isDirectory]) {
        if (_isDirectory) {
            
            // NSLog(@"isDirectory");
            
//            /**
//             *  If images zipped on the Mac, sometimes the folder containing images will
//             *  include the __MACOSX folder. There is no certain way of knowing the index of that folder
//             *  so I'll have to "wing it", or execute "remove" command just in case.
//             */
//            
//            [[NSFileManager defaultManager]removeItemAtPath:[unzippedPath stringByAppendingPathComponent:@"__MACOSX"]
//                                                      error:nil];
            
//            // Need to update the contents of the Folder in case __MACOSX was removed.
//            contents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:unzippedPath
//                                                                          error:nil];
            
            // Assuming first object is in fact the path to another direcotry.
            self.imageDirectory = [unzippedPath stringByAppendingPathComponent:[contents firstObject]];
            
            // If __MACOSX folder existed, chances are .DS_Store is inside of the imageDirectory. Removing it.
            [[NSFileManager defaultManager]removeItemAtPath:[self.imageDirectory stringByAppendingPathComponent:@".DS_Store"]
                                                      error:nil];
            
            // Images array filled with images from the proper folder.
            self.images = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:self.imageDirectory
                                                                             error:nil];
            
            // Setting up the count that will be used to shuffle through the images in the array.
            self.imagesCount = [self.images count];
            
            if (self.imagesCount > 0) {
                self.imageView.image = [UIImage imageWithContentsOfFile:[self.imageDirectory stringByAppendingPathComponent:[self.images firstObject]]];
            }
        } else {
            
            // NSLog(@"!isDirectory");
            
            self.images = contents;
            self.imagesCount = [self.images count];
            if (self.imagesCount > 0) {
                self.imageView.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:[self.images firstObject]]];
            }
        }
    }
}

#pragma mark - Mail View Controller Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:[NSString stringWithFormat:@"Submission: %@", self.rawControl.packageName]];
        [mailComposeViewController setToRecipients:@[self.rawControl.authorEmail]];
        
        if (buttonIndex == 0) {
            [mailComposeViewController setMessageBody:@"Hi there!\n\nThank you so much for your submission.\n\nI am sure you've put a lot of time into this theme. Unfortunately I cannot accept it to the Cydia store due to the quality of it.\n\nIf you are willing to improve on the UI / icons in general, I would be more than happy to reconsider my decision.\n\nThank you and have a great day!\n\n- Michael" isHTML:NO];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        } else if (buttonIndex == 1) {
            [mailComposeViewController setMessageBody:@"Hi there!\n\nThank you for your submission.\n\nCan you please email me PSD files for verification (preferably icons)?\n\nThank you!\n\n-Michael" isHTML:NO];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        } else if (buttonIndex == 2) {
            [self tweetSubmissionImage:self.imageView.image description:nil];
        }
    }
}

@end
