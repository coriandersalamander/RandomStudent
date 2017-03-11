//
//  SetupViewController.h
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@protocol SetupViewControllerProtocol;

@interface SetupViewController : UIViewController <UITextFieldDelegate> {
    
}
@property (assign) id delegate;
//@property (assign) BOOL databaseRemoved;
@property (retain, nonatomic) IBOutlet UITextField *userNameField;
@property (retain, nonatomic) IBOutlet UITextField *fileNameField;
@property (retain, nonatomic) IBOutlet UITextField *periodField;
@property (retain, nonatomic) IBOutlet UITextField *activeField;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

-(IBAction) saveInfo:(id) sender;
-(IBAction) resetDatabase:(id) sender;
@end


@protocol SetupViewControllerProtocol
-(void) SetupViewControllerDidFinish:(SetupViewController *) controller;

@end
