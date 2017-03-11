//
//  SetupViewController.m
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import "SetupViewController.h"

@interface SetupViewController ()

@end

//
//  SetupViewController.m
//  RandomStudent
//
//  Created by Christopher Galasso on 1/20/17.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"
#import "sqlite3.h"

#define KEY_RETURNINGUSER @"KeyReturningUser"
#define KEY_USER @"KeyUser"
#define KEY_FILENAME @"KeyFileName"
#define KEY_PERIOD @"KeyPeriod"

@implementation SetupViewController
@synthesize delegate;
@synthesize fileNameField;
@synthesize userNameField;
@synthesize periodField;
@synthesize scrollView;
@synthesize activeField;

#pragma mark UITextField optional methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}


-(void) textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

// The designated initializer.  Override if you create the controller programmatically
// and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

-(void) registerNotificationEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

-(void) unregisterNotificationEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    
}
-(void) willHide:(NSNotification *)notification
{
    NSLog(@"Will Hide!");
    //Do Something
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}
-(void) didHide:(id) object
{
    //	NSLog(@"Did Hide!");
    
    //  Nothing to do
}

-(void) willShow:(id) object
{
    //Nothing to do
    //	NSLog(@"Will Show!");
}

-(void) didShow:(NSNotification *)notification
{
    NSLog(@"Did Show!");
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height , 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    /* This moves stuff around, but it's not quite right...
     
     CGRect backgroundRect = activeField.superview.frame;
     backgroundRect.size.height += keyboardSize.height;
     [activeField.superview setFrame:backgroundRect];
     [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y - keyboardSize.height) animated:YES];
     */
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= keyboardSize.height;
    //	NSLog(@"Active Field Rectangle == %@", activeField.frame.origin + activeField.frame.size.height);
    
    //	if (!CGRectContainsPoint(aRect, activeField.frame.origin))
    if (!CGRectContainsPoint(aRect, CGPointMake(activeField.frame.origin.x, activeField.frame.origin.y + activeField.frame.size.height)))
    {
        
        [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y - keyboardSize.height) animated:YES];
        //		[self.scrollView scrollRectToVisible:activeField.frame animated:YES];
        
    }
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //	self.databaseRemoved = NO;
    [self registerNotificationEvents];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.periodField.text = [userDefaults objectForKey:KEY_PERIOD];
    
}

-(IBAction) resetDatabase:(id) sender
{
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"Students.db"];
    
    
    sqlite3 * studentDB;
    
    if (sqlite3_open([dbPathString UTF8String] , &studentDB) == SQLITE_OK)
    {
        NSString *deleteStmt = [NSString stringWithFormat:@"DELETE FROM STUDENTS WHERE 1"];
        const char *delete_stmt = [deleteStmt UTF8String];
        NSLog(@"Deleting all entries");
        char *error = nil;
        if (sqlite3_exec(studentDB, delete_stmt, NULL, NULL, &error) == SQLITE_OK)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Database Message" message:@"All entries deleted!" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            
            [alert addAction:defaultAction];
            [rootViewController presentViewController:alert animated:YES completion:nil];
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Message" message:@"All Entries Deleted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Database Message" message:@"Error resetting database - See log for details" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            
            [alert addAction:defaultAction];
            [rootViewController presentViewController:alert animated:YES completion:nil];
            NSLog(@"Error - Reset Database - %s", sqlite3_errmsg(studentDB));
        }
        
        
    }
    
    // self.databaseRemoved = YES;
    
    sqlite3_close(studentDB);
    
}

// Override to allow orientations other than the default portrait orientation.
/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait) ||
 (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
 (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self unregisterNotificationEvents];
    
}




-(IBAction) saveInfo:(id) sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.userNameField.text forKey:KEY_USER];
    [userDefaults setObject:self.fileNameField.text forKey:KEY_FILENAME];
    NSString *tempPeriod = [NSString stringWithString:self.periodField.text];
    if ([tempPeriod isEqualToString:@""])
    {
        NSLog(@"Nil!");
        [userDefaults setObject:@"" forKey:KEY_PERIOD];
    }
    else
    {
        NSLog(@"Not Nil! %@HIHIHI", tempPeriod);
        [userDefaults setObject:self.periodField.text forKey:KEY_PERIOD];
    }
    
    [userDefaults setBool:YES forKey:KEY_RETURNINGUSER];
    
    [userDefaults synchronize];
    
    [self.delegate SetupViewControllerDidFinish:self];
    
}

@end

