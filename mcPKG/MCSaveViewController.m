//
//  MCSaveViewController.m
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCSaveViewController.h"
#import "MCRawControl.h"
#import "MCRawControlValidator.h"
#import "MCControlFileGenerator.h"
#import "MCWebAPi.h"
#import "LDProgressView.h"
#import "MCSubmission.h"
#import "MCSubmissionAction.h"
#import "CTCheckbox.h"

static NSString * const kMacCitiPackagePrefix = @"macciti_cydiastore_com.macciti.%@_v1.0.0";

@interface MCSaveViewController () <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) LDProgressView *progressView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UITextView *controlTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak , nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet CTCheckbox *checkBox;

- (NSString *)packageDirectory;
- (IBAction)backgroundSelected:(id)sender;
- (IBAction)saveButtonSelected:(id)sender;
- (void)presentMessageViewControllerWithSubmission:(MCSubmission *)submission;

@end

@implementation MCSaveViewController

#pragma mark - Instantiation

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}

- (LDProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(20, 544, self.view.frame.size.width-40, 5)];
        _progressView.color = [UIColor colorWithRed:0.318 green:0.725 blue:0.859 alpha:1.000];
        _progressView.flat = @YES;
        _progressView.animate = @YES;
        _progressView.showText = @NO;
        _progressView.showStroke = @NO;
        _progressView.progressInset = @1;
        _progressView.showBackground = @NO;
        _progressView.outerStrokeWidth = @1;
        _progressView.type = LDProgressSolid;
    }
    return _progressView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.controlTextView setText:[MCControlFileGenerator generateControlFileFromMCRawContro:self.rawControl]];
    [self.view addSubview:self.progressView];
    
    // Setting up properties of the checkBox.
    if (self.rawControl.packageIsPaid) {
        [self.checkBox setColor:[UIColor colorWithRed:54.0 / 255.0 green:57.0 / 255.0 blue:58.0 / 255.0 alpha:1.0]
                forControlState:UIControlStateNormal];
        [self.checkBox setColor:[UIColor colorWithRed:134.0 / 255.0 green:134.0 / 255.0 blue:134.0 / 255.0 alpha:1.0]
                forControlState:UIControlStateDisabled];
        self.checkBox.hidden = NO;
        self.checkBox.textLabel.font = [UIFont systemFontOfSize:14];
        self.checkBox.textLabel.textColor = [UIColor lightGrayColor];
        self.checkBox.textLabel.text = @"Submit for approval?";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.fractionCompleted;
            self.progressLabel.text = [NSString stringWithFormat:@"%.f%%", progress.fractionCompleted * 100];
        });
    }
}

- (NSString *)packageDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories.firstObject;
    if (!self.rawControl.packageIsPaid) {
        return [documentDirectory stringByAppendingPathComponent:self.rawControl.packageID];
    } else {
        return [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:kMacCitiPackagePrefix, self.rawControl.packageID]];
    }
}

- (IBAction)backgroundSelected:(id)sender
{
    [self.controlTextView resignFirstResponder];
}

- (IBAction)saveButtonSelected:(id)sender
{
    // Adding the activit indicator view.
    UIBarButtonItem *activityBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.indicatorView];
    self.navigationItem.rightBarButtonItem = activityBarButton;
    
    // Resign keyboard.
    [self.controlTextView resignFirstResponder];
    
    NSString *packageDirectory = [self packageDirectory];
    NSString *debianDirectory = [packageDirectory stringByAppendingPathComponent:@"DEBIAN"];
    NSString *controlFilePath = [debianDirectory stringByAppendingPathComponent:@"control"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:packageDirectory]) {
        [fileManager removeItemAtPath:packageDirectory error:nil];
    }
    
    // Creating package directory.
    NSError *packageDirectoryCreationError = nil;
    [fileManager createDirectoryAtPath:packageDirectory withIntermediateDirectories:NO attributes:Nil error:&packageDirectoryCreationError];
    if (!packageDirectoryCreationError) {
        NSError *debianDirectoryCreationError = nil;
        [fileManager createDirectoryAtPath:debianDirectory withIntermediateDirectories:NO attributes:nil error:&debianDirectoryCreationError];
        if (!debianDirectoryCreationError) {
            NSError *controlFileCreationError = nil;
            [self.controlTextView.text writeToFile:controlFilePath atomically:YES encoding:NSUTF8StringEncoding error:&controlFileCreationError];
            if (!controlFileCreationError) {
                [MCWebAPi GETREquestForPackageFileWithURL:[NSURL URLWithString:[MCRawControlValidator validateURLString:self.rawControl.packageDownloadURLString]]
                                     packageDirectoryPath:packageDirectory
                                                 observer:self
                                               completion:^(BOOL success, NSArray *contents, NSError *error) {
                                                   if (!error) {
                                                       [self.indicatorView stopAnimating];
                                                       [self.navigationItem setRightBarButtonItem:self.saveButton];
                                                       
                                                       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"submissionID == %@", self.rawControl.submissionID];
                                                       NSArray *results = [MCSubmission findAllWithPredicate:predicate];
                                                       MCSubmission *submission = [results firstObject];
                                                       [MCSubmissionAction markSubmissionCompleted:submission completion:^(BOOL success, NSError *error) {
                                                           if (!error && self.checkBox.checked) {
                                                               [self presentMessageViewControllerWithSubmission:submission];
                                                           } else if (!error) {
                                                               [self.navigationController popToRootViewControllerAnimated:YES];
                                                           }
                                                       }];
                                                   }
                                               }];
            }
        }
    }
}

- (void)presentMessageViewControllerWithSubmission:(MCSubmission *)submission
{
    MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc]init];
    messageComposeViewController.messageComposeDelegate = self;
    messageComposeViewController.recipients = @[@"253-508-8887"];
    
    if ([MFMessageComposeViewController canSendText]) {
        if ([submission.isNewDeveloper boolValue]) {
            messageComposeViewController.body = [NSString stringWithFormat:@"-----\nFull Name: %@\nCountry of Living: %@\nPayPal: %@\nEmail: %@\nCydia Account #: %@\nPackage: com.macciti.%@\nPrice: $%@",
                                                 self.rawControl.authorName,
                                                 submission.authorCountry,
                                                 submission.authorPayPal,
                                                 submission.authorEmail,
                                                 submission.cydiaAccountNumber,
                                                 self.rawControl.packageID,
                                                 submission.packagePrice];
        } else {
            messageComposeViewController.body = [NSString stringWithFormat:@"-----\nDeveloper: %@\nPackage: com.macciti.%@\nPrice: %@",
                                                 submission.cydiaDevID,
                                                 self.rawControl.packageID,
                                                 submission.packagePrice];
        }
        
        [self presentViewController:messageComposeViewController animated:YES completion:nil];
        
    } else {
        [[[UIAlertView alloc]initWithTitle:@"Message Error"
                                   message:@"This device is not configured to send text messages."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil]show];
    }
}

#pragma mark - Message View Controller Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

@end
