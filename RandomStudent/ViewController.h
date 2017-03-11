//
//  ViewController.h
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
//#import "RS_Database.h"
#import "InfoViewController.h"
#import "SetupViewController.h"


@interface ViewController :
UIViewController <  InfoViewProtocol,
                    SetupViewControllerProtocol,
                    UIPickerViewDelegate,
                    UIPickerViewDataSource
    >


{
}

@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@property (weak, nonatomic) IBOutlet UIButton *userPrefButton;
@property (weak, nonatomic) IBOutlet UIPickerView *studentPicker;

@property NSMutableArray *arrayOfPerson;
- (void)loadValuesIntoArray;


@property (retain, nonatomic) NSTimer *randomTimer;

@property (retain, nonatomic) NSString *period;

@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) IBOutlet UILabel *periodLabel;

- (IBAction)showInfo:(id)sender;
- (void)showSetupScreen;

- (void) logSelf;
- (void) displayAll;


- (IBAction) chooseRandom:(id) sender;
- (IBAction) populate:(id) sender;




@end

