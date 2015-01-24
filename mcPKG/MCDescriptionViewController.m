//
//  MCDescriptionViewController.m
//  mcPKG
//
//  Created by iC on 1/28/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCDescriptionViewController.h"
#import "MCScreenshotPreviewViewController.h"
#import "MCDependencyViewController.h"
#import "APAutocompleteTextField.h"
#import "MCRawControlValidator.h"
#import "MCRawControl.h"

@interface MCDescriptionViewController () <APAutocompleteTextFieldDelegate>

@property (strong, nonatomic) APAutocompleteTextField *autoCompleteTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *charactersCountLabel;

- (void)checkForValidPackageDescription;
- (IBAction)nextButtonSelected:(id)sender;

@end

@implementation MCDescriptionViewController

#pragma mark - Instantiation

- (APAutocompleteTextField *)autoCompleteTextField
{
    if (!_autoCompleteTextField) {
        _autoCompleteTextField = [[APAutocompleteTextField alloc] initWithFrame:CGRectMake(5.0f, 312.0f, 240.0f, 40.0f)];
        _autoCompleteTextField.font = [UIFont systemFontOfSize:14];
        _autoCompleteTextField.textColor = [UIColor colorWithRed:134.0 / 255.0 green:134.0 / 255.0 blue:134.0 / 255.0 alpha:1.0];
        _autoCompleteTextField.placeholder = @"Section";
        _autoCompleteTextField.delegate = self;
        _autoCompleteTextField.borderStyle = UITextBorderStyleNone;
    }
    return _autoCompleteTextField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.autoCompleteTextField];
    
    dispatch_queue_t waitQ = dispatch_queue_create("waitQ", NULL);
    dispatch_async(waitQ, ^{
        usleep(500000);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.descriptionTextView becomeFirstResponder];
        });
    });
    
    self.descriptionTextView.text = self.rawControl.packageDescription;
    self.charactersCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.descriptionTextView.text length]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)checkForValidPackageDescription
{
    if ([MCRawControlValidator isValidDescription:self.descriptionTextView.text]) {
        
        // In case change was made to the description, record the change.
        // Also, record package section.
        self.rawControl.packageDescription = self.descriptionTextView.text;
        self.rawControl.packageSection = self.autoCompleteTextField.text;
        
        if ([self.rawControl.packageSection length] > 0) {
            [self performSegueWithIdentifier:@"MCDependencyViewController" sender:self];
        } else {
            [[[UIAlertView alloc]initWithTitle:@"Warning!"
                                       message:@"Section field cannot be empty."
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil, nil]show];
        }
    } else {
        [[[UIAlertView alloc]initWithTitle:@"Warning!"
                                   message:@"Package description is invalid!"
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil]show];
    }
}

- (IBAction)nextButtonSelected:(id)sender
{
    [self checkForValidPackageDescription];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MCDependencyViewController"]) {
        MCDependencyViewController *dependencyViewController = (MCDependencyViewController *)segue.destinationViewController;
        dependencyViewController.rawControl = self.rawControl;
    } else if ([segue.identifier isEqualToString:@"MCScreenshotPreviewViewController"]) {
        MCScreenshotPreviewViewController *screenshotPreviewViewController = (MCScreenshotPreviewViewController *)segue.destinationViewController;
        screenshotPreviewViewController.rawControl = self.rawControl;
    }
}

#pragma mark - TextView Delegate

/**
 *  We need this to make sure count is up-to-date
 *  if the user decides to change text in a text view.
 */
- (void)textViewDidChange:(UITextView *)textView
{
    self.charactersCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[textView.text length]];
}

#pragma mark - Autocomplete Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (NSString *)autocompleteTextField:(APAutocompleteTextField *)textField complitedStringForOriginString:(NSString *)originString
{
    NSString *section = nil;
    if ([textField.text isEqualToString:@"The"]) {
        section = @"Themes (";
    } else if ([textField.text isEqualToString:@"Themes (Ad"]) {
        section = @"Themes (Addons)";
    } else if ([textField.text isEqualToString:@"Themes (Ap"]) {
        section = @"Themes (Apps)";
    } else if ([textField.text isEqualToString:@"Themes (Co"]) {
        section = @"Themes (Complete)";
    } else if ([textField.text isEqualToString:@"Themes (Dr"]) {
        section = @"Themes (DreamBoard)";
    } else if ([textField.text isEqualToString:@"Themes (Ke"]) {
        section = @"Themes (Keyboard)";
    } else if ([textField.text isEqualToString:@"Themes (Lo"]) {
        section = @"Themes (LockScreen)";
    } else if ([textField.text isEqualToString:@"Themes (Sb"]) {
        section = @"Themes (SBSettings)";
    } else if ([textField.text isEqualToString:@"Themes (Sp"]) {
        section = @"Themes (SpringBoard)";
    } else if ([textField.text isEqualToString:@"Themes (Sy"]) {
        section = @"Themes (System)";
    }
    
    if ([textField.text isEqualToString:@"Add"]) {
        section = @"Addons (";
    } else if ([textField.text isEqualToString:@"Addons (Zep"]) {
        section = @"Addons (Zeppelin)";
    } else if ([textField.text isEqualToString:@"Addons (Loc"]) {
        section = @"Addons (LockBuilder)";
    }
    
    if ([textField.text isEqualToString:@"Wid"]) {
        section = @"Widgets";
    }
    
    if ([textField.text isEqualToString:@"Fon"]) {
        section = @"Fonts (BytaFont 2)";
    }
    
    if ([textField.text isEqualToString:@"Sit"]) {
        section = @"Site-Specific Apps";
    }
    
    if ([textField.text isEqualToString:@"Twe"]) {
        section = @"Tweaks";
    }
    
    if ([textField.text isEqualToString:@"Wal"]) {
        section = @"Wallpaper";
    }
    
    NSRange originStringRange = [section rangeOfString:originString];
    if (originStringRange.location != 0) {
        section = nil;
    }
    
    return section;
}

@end
