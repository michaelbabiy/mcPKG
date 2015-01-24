//
//  MCMacCitiKeyViewController.m
//  mcPKG
//
//  Created by iC on 1/31/14.
//  Copyright (c) 2014 Mac*Citi, LLC. All rights reserved.
//

#import "MCMacCitiKeyViewController.h"
#import "MCRandomPassword.h"
#import "MCParseConstants.h"
#import "MCDeveloper.h"
#import "BZGFormField.h"

#define MC_CYDIA_DEV_ID_REGEX @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

@interface MCMacCitiKeyViewController () <BZGFormFieldDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet BZGFormField *firstNameField;
@property (weak, nonatomic) IBOutlet BZGFormField *lastNameField;
@property (weak, nonatomic) IBOutlet BZGFormField *cydiaDevField;
@property (weak, nonatomic) IBOutlet BZGFormField *cydiaAccountNumberField;
@property (weak, nonatomic) IBOutlet BZGFormField *twitterHandleField;

@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (void)setupBZGFormFields;
- (IBAction)saveButtonSelected:(id)sender;
- (IBAction)emailButtonSelected:(id)sender;

@end

@implementation MCMacCitiKeyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBZGFormFields];
    
    dispatch_queue_t waitQ = dispatch_queue_create("waitQ", NULL);
    dispatch_async(waitQ, ^{
        usleep(200000);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.firstNameField.textField becomeFirstResponder];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.developer) {
        self.firstNameField.textField.text = self.developer.firstName;
        self.lastNameField.textField.text = self.developer.lastName;
        self.cydiaDevField.textField.text = self.developer.developerID;
        self.cydiaAccountNumberField.textField.text = self.developer.accountNumber;
        self.twitterHandleField.textField.text = self.developer.twitterHandle;
        self.keyLabel.text = self.developer.maccitiKey;
        
        // Disabling all editing.
        self.firstNameField.textField.enabled = NO;
        self.lastNameField.textField.enabled = NO;
        self.cydiaDevField.textField.enabled = NO;
        self.cydiaAccountNumberField.textField.enabled = NO;
        self.twitterHandleField.textField.enabled = NO;
        self.messageLabel.hidden = NO;
        
        // If developer is not nil, assuming I was sent here from Developer List VC.
        UIBarButtonItem *emailBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Email"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(emailButtonSelected:)];
        self.navigationItem.rightBarButtonItem = emailBarButton;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupBZGFormFields
{
    self.firstNameField.textField.font = [UIFont systemFontOfSize:14];
    self.firstNameField.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.firstNameField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.firstNameField.textField.placeholder = @"Michael";
    self.firstNameField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.firstNameField.textField.returnKeyType = UIReturnKeyNext;
    self.firstNameField.delegate = self;
    
    self.lastNameField.textField.font = [UIFont systemFontOfSize:14];
    self.lastNameField.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastNameField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.lastNameField.textField.placeholder = @"Babiy";
    self.lastNameField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.lastNameField.textField.returnKeyType = UIReturnKeyNext;
    self.lastNameField.delegate = self;
    
    self.cydiaDevField.textField.font = [UIFont systemFontOfSize:14];
    self.cydiaDevField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.cydiaDevField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cydiaDevField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.cydiaDevField.textField.placeholder = @"ickohen@me.com";
    self.cydiaDevField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.cydiaDevField.textField.returnKeyType = UIReturnKeyNext;
    self.cydiaDevField.delegate = self;
    [self.cydiaDevField setTextValidationBlock:^BOOL(BZGFormField *field, NSString *text) {
        NSPredicate *cydiaDEVIDTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MC_CYDIA_DEV_ID_REGEX];
        if ([cydiaDEVIDTest evaluateWithObject:self.cydiaDevField.textField.text]) {
            return YES;
        } else {
            return NO;
        }
    }];
    
    self.cydiaAccountNumberField.textField.font = [UIFont systemFontOfSize:14];
    self.cydiaAccountNumberField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.cydiaAccountNumberField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cydiaAccountNumberField.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.cydiaAccountNumberField.textField.placeholder = @"05170617";
    self.cydiaAccountNumberField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.cydiaAccountNumberField.textField.returnKeyType = UIReturnKeyNext;
    self.cydiaAccountNumberField.delegate = self;
    
    self.twitterHandleField.textField.font = [UIFont systemFontOfSize:14];
    self.twitterHandleField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.twitterHandleField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.twitterHandleField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.twitterHandleField.textField.placeholder = @"@macciti";
    self.twitterHandleField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.twitterHandleField.textField.returnKeyType = UIReturnKeyGo;
    self.twitterHandleField.delegate = self;
}

- (IBAction)generateMacCitiKeyButtonSelected:(id)sender
{
    if ([self.firstNameField.textField.text length] == 0 ||
        [self.lastNameField.textField.text length] == 0 ||
        [self.cydiaDevField.textField.text length] == 0 ||
        [self.cydiaAccountNumberField.textField.text length] == 0) {
        [[[UIAlertView alloc]initWithTitle:@"Error"
                                   message:@"Please make sure to enter all required information."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil]show];
        return;
    } else {
        NSString *maccitiKey = [MCRandomPassword generateKeyFromString:[NSString stringWithFormat:@"%@%@%@%@",
                                                                        self.cydiaDevField.textField.text,
                                                                        self.cydiaAccountNumberField.textField.text,
                                                                        self.firstNameField.textField.text,
                                                                        self.lastNameField.textField.text]];
        self.keyLabel.text = maccitiKey;
    }
}

- (IBAction)saveButtonSelected:(id)sender
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.hidesWhenStopped = YES;
    [activityIndicatorView startAnimating];
    UIBarButtonItem *activityBarButton = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = activityBarButton;
    
    PFObject *developer = [PFObject objectWithClassName:kDeveloperClass];
    [developer setObject:self.firstNameField.textField.text forKey:kDeveloperFirstNameKey];
    [developer setObject:self.lastNameField.textField.text forKey:kDeveloperLastNameKey];
    [developer setObject:self.cydiaDevField.textField.text forKey:kDeveloperIDKey];
    [developer setObject:self.cydiaAccountNumberField.textField.text forKey:kDeveloperAccountNumberKey];
    [developer setObject:self.keyLabel.text forKey:kDeveloperMacCitiKey];
    [developer setObject:self.twitterHandleField.textField.text forKey:kDeveloperTwitterHandle];
    [developer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)emailButtonSelected:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
        [mailComposeViewController setSubject:@"MacCiti Key"];
        [mailComposeViewController setToRecipients:@[self.developer.developerID]];
        [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"Hey %@,\n\nYour key is: %@\n\nThanks!",
                                                   self.developer.firstName,
                                                   self.developer.maccitiKey] isHTML:NO];
        [mailComposeViewController setMailComposeDelegate:self];
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.firstNameField.textField isFirstResponder]) {
        [self.lastNameField.textField becomeFirstResponder];
    } else if ([self.lastNameField.textField isFirstResponder]) {
        [self.cydiaDevField.textField becomeFirstResponder];
    } else if ([self.cydiaDevField.textField isFirstResponder]) {
        [self.cydiaAccountNumberField.textField becomeFirstResponder];
    } else if ([self.cydiaAccountNumberField.textField isFirstResponder]) {
        [self.twitterHandleField.textField becomeFirstResponder];
    } else if ([self.twitterHandleField.textField isFirstResponder]) {
        [self generateMacCitiKeyButtonSelected:nil];
    } else {
        [self generateMacCitiKeyButtonSelected:nil];
    }
    return YES;
}

#pragma mark - Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSaved:
            [self dismissViewControllerAnimated:YES completion:^{
                [[[UIAlertView alloc]initWithTitle:@"Email Saved"
                                           message:@"Email was not sent. Saved in drafts."
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil, nil]show];
            }];
            break;
        case MFMailComposeResultSent:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultFailed:
            [self dismissViewControllerAnimated:YES completion:^{
                [[[UIAlertView alloc]initWithTitle:@"Error Sending Email"
                                           message:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil, nil]show];
            }];
            break;
    }
}

@end
