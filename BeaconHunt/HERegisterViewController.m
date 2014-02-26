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

@interface HERegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextField;
@property (weak, nonatomic) IBOutlet HEActivityIndicatorButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;

@end

@implementation HERegisterViewController

#define BOTTOM_SPACE 100
#pragma mark KEYBOARD CTRL

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
    
    self.bottomSpaceConstraint.constant = height + 16;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.bottomSpaceConstraint.constant = BOTTOM_SPACE;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self observeKeyboard];
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
    
    [[FXKeychain defaultKeychain] setObject:self.userEmailTextField.text  forKey:BHUserEmailKey];
    [[FXKeychain defaultKeychain] setObject:self.userNameTextField.text  forKey:BHUserNameKey];
    
    [self.delegate userRegistered];
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
