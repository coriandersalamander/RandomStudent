//
//  SetupViewController.h
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "GTLRDrive.h"
#import "GTLRSheets.h"


@protocol SetupViewControllerProtocol;

@class OIDAuthState;
@class GTMAppAuthFetcherAuthorization;
@class OIDServiceConfiguration;

@interface SetupViewController : UIViewController <UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
}
@property (nullable, assign) id delegate;

@property (retain, nonatomic, nonnull) IBOutlet UIView *googleAuthFrame;
@property(nullable) IBOutlet UIButton *loginButton;
@property(nullable) IBOutlet UIButton *logoutButton;


@property (retain, nonatomic, nonnull) IBOutlet UIView *fileInfoFrame;
@property(nullable) IBOutlet UIButton *viewFilesButton;
@property (retain, nonatomic, nullable) IBOutlet UITextView *fileNameField;
@property (weak, nonatomic, nullable) IBOutlet UIPickerView *filenamePicker;
@property(nullable) IBOutlet UIButton *saveButton;
@property(nullable) IBOutlet UIButton *resetButton;

@property (retain, nonatomic, nonnull) IBOutlet UIView *errorLogFrame;
@property(nullable) IBOutlet UITextView *logTextView;

@property (nullable) NSMutableArray *arrayOfStudents;





/*
 @property (retain, nonatomic, nullable) IBOutlet UITextField *userNameField;
@property (retain, nonatomic, nullable) IBOutlet UITextField *periodField;
@property (retain, nonatomic, nonnull) IBOutlet UIScrollView *scrollView;
*/


@property (retain, nonnull) NSMutableArray *arrayOfFiles;
@property (retain, nullable) NSMutableArray *arrayOfPeriods;

@property (nonnull) NSString *spreadsheetID;

@property (nonnull, nonatomic, strong) GTLRDriveService *driveService;
@property (nonnull, nonatomic, strong) GTLRSheetsService *sheetsService;

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

- (GTLRDriveService *)driveService;
- (IBAction)authenticate:(nullable id)sender;
- (IBAction)viewFiles:(nullable id)sender;
- (IBAction)logout:(nullable id)sender;

- (void)showAlert:(NSString *)title message:(NSString *)message;

-(IBAction) saveInfo:(id) sender;
-(IBAction) resetDatabase:(id) sender;
-(void) removeTestEntries;

-(void) loadPeriodsArrayFromPicker;
-(void) loadStudentsArray;
-(void) addStudentsToDB;
@end


@protocol SetupViewControllerProtocol
-(void) SetupViewControllerDidFinish:(SetupViewController *) controller withPeriods:(NSMutableArray *)periods;

@end
NS_ASSUME_NONNULL_END
