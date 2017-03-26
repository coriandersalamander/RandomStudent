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

@interface SetupViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
}
@property (nullable, assign) id delegate;
//@property (assign) BOOL databaseRemoved;
@property (weak, nonatomic, nullable) IBOutlet UIPickerView *fileWithPeriod;
@property (retain, nonatomic, nullable) IBOutlet UITextField *userNameField;
@property (retain, nonatomic, nullable) IBOutlet UITextField *fileNameField;
@property (retain, nonatomic, nullable) IBOutlet UITextField *periodField;
@property (retain, nonatomic, nonnull) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic, nonnull) IBOutlet UIView *googleAuthFrame;
@property (retain, nonatomic, nonnull) IBOutlet UIView *errorLogFrame;
@property (retain, nonatomic, nonnull) IBOutlet UIView *fileInfoFrame;

@property(nullable) IBOutlet UIButton *authAutoButton;
@property(nullable) IBOutlet UIButton *userinfoButton;
@property(nullable) IBOutlet UIButton *clearAuthStateButton;
@property(nullable) IBOutlet UITextView *logTextView;
@property(nullable) IBOutlet UIButton *resetButton;
@property(nullable) IBOutlet UIButton *saveButton;

@property (nullable) NSMutableArray *arrayOfFiles;
@property (nullable) NSMutableArray *arrayOfStudents;

@property (nonnull) NSString *spreadsheetID;

@property (nonnull, nonatomic, strong) GTLRDriveService *driveService;
@property (nonnull, nonatomic, strong) GTLRSheetsService *sheetsService;

NS_ASSUME_NONNULL_BEGIN

/*! @brief The example application's view controller.
 */

/*! @brief The authorization state.
 */
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

/*! @brief Authorization code flow using @c OIDAuthState automatic code exchanges.
 @param sender IBAction sender.
 */
- (IBAction)authWithAutoCodeExchange:(nullable id)sender;

/*! @brief Performs a Userinfo API call using @c GTMAppAuthFetcherAuthorization.
 @param sender IBAction sender.
 */
- (IBAction)userinfo:(nullable id)sender;

/*! @brief Nils the @c OIDAuthState object.
 @param sender IBAction sender.
 */
- (IBAction)clearAuthState:(nullable id)sender;

/*! @brief Clears the UI log.
 @param sender IBAction sender.
 */
- (IBAction)clearLog:(nullable id)sender;

- (void)showAlert:(NSString *)title message:(NSString *)message;

- (GTLRDriveService *)driveService;

-(IBAction) saveInfo:(id) sender;
-(IBAction) resetDatabase:(id) sender;
@end


@protocol SetupViewControllerProtocol
-(void) SetupViewControllerDidFinish:(SetupViewController *) controller;

@end
NS_ASSUME_NONNULL_END
