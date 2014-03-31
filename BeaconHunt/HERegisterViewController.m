//
//  HERegisterViewController.m
//  BeaconHunt
//
//  Created by Roberto Silva on 26/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "HERegisterViewController.h"
#import "HEActivityIndicatorButton.h"
#import "NSString+Helper.h"
#import <FXKeychain.h>
#import <Parse/Parse.h>

@interface HERegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextField;
@property (weak, nonatomic) IBOutlet HEActivityIndicatorButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heLogoBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventLogoBottomSpaceConstraint;

@end

@implementation HERegisterViewController {
    float _noKeyBoardBottomSpace;
}

#pragma mark DYNAMIC INTERFACE LAYOUT

- (void)setupInterface
{
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (screenHeight > 480) {
        self.bottomSpaceConstraint.constant += 44;
        self.heLogoBottomSpaceConstraint.constant += 44;
        self.eventLogoBottomSpaceConstraint.constant += 44;
    }
    
    _noKeyBoardBottomSpace = self.bottomSpaceConstraint.constant;
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    self.bottomSpaceConstraint.constant = height + 4;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.bottomSpaceConstraint.constant = _noKeyBoardBottomSpace;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)dismissKeyboard
{
    [self.userNameTextField resignFirstResponder];
    [self.userEmailTextField resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark LIFE CYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.sendButton.enabled = NO;
    [self setupInterface];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self observeKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
}

#pragma mark STORYBOARD ACTIONS

- (IBAction)editingChanged:(id)sender {
    if ([self.userNameTextField.text length] > 0 && [self.userEmailTextField.text isValidEmail]) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
}

- (IBAction)registerUser:(id)sender {
    [self registerUserOnParse];
    
    //[[FXKeychain defaultKeychain] setObject:self.userEmailTextField.text  forKey:BHUserEmailKey];
    //[[FXKeychain defaultKeychain] setObject:self.userNameTextField.text  forKey:BHUserNameKey];
    
    //[self.delegate userRegistered];
}

#define PARSE_USER_TABLE @"User"
#define PARSE_USER_NAME_COL @"name"
#define PARSE_USER_EMAIL_COL @"email"
- (void)registerUserOnParse {
    NSString *name = self.userNameTextField.text;
    NSString *email = self.userEmailTextField.text;
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_USER_TABLE];
    [query whereKey:PARSE_USER_EMAIL_COL equalTo:email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) { // Insert
                NSLog(@"Create User");
                PFObject *newUser = [PFObject objectWithClassName:PARSE_USER_TABLE];
                newUser[PARSE_USER_NAME_COL] = name;
                newUser[PARSE_USER_EMAIL_COL] = email;
                
                [newUser saveInBackground];
                
            } else { // Update
                NSLog(@"Update User");
                PFObject *myUser = [objects firstObject];
                myUser[PARSE_USER_NAME_COL] = name;
                myUser[PARSE_USER_EMAIL_COL] = email;
                
                [myUser saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Register User in Parse Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextField) {
        [self.userEmailTextField becomeFirstResponder];
    } else if (textField == self.userEmailTextField) {
        if (self.sendButton.enabled) {
            [self dismissKeyboard];
            //[self performSegueWithIdentifier:kValidateUserSegueID sender:textField];
        }
    }
    
    return YES;
}

#pragma mark OTHERS


@end
