//
//  SetupViewController.m
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import "SetupViewController.h"
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"
#import "GTLRDrive.h"
#import "RS_Database.h"


#import "sqlite3.h"


@interface SetupViewController ()<OIDAuthStateChangeDelegate,
OIDAuthStateErrorDelegate>

@end

//
//  SetupViewController.m
//  RandomStudent
//
//  Created by Christopher Galasso on 1/20/17.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";
//static NSString *const kIssuer = @"https://www.googleapis.com/auth/drive";


/*! @brief The OAuth client ID.
 @discussion For Google, register your client at
 https://console.developers.google.com/apis/credentials?project=_
 The client should be registered with the "iOS" type.
 */
static NSString *const kClientID = @"82296042172-s23hcibpj3mi7bvnhelp1bq0qq80cqb0.apps.googleusercontent.com";

/*! @brief The OAuth redirect URI for the client @c kClientID.
 @discussion With Google, the scheme of the redirect URI is the reverse DNS notation of the
 client ID. This scheme must be registered as a scheme in the project's Info
 property list ("CFBundleURLTypes" plist key). Any path component will work, we use
 'oauthredirect' here to help disambiguate from any other use of this scheme.
 */
static NSString *const kRedirectURI =
@"com.googleusercontent.apps.82296042172-s23hcibpj3mi7bvnhelp1bq0qq80cqb0:/oauthredirect";
/*! @brief @c NSCoding key for the authState property.
 */
static NSString *const kExampleAuthorizerKey = @"authorization";

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

#pragma mark UITextField optional methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"HIHIHIH");
//    [textField becomeFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"MNMNMN");
//    [textField becomeFirstResponder];
}


-(void) textFieldDidEndEditing:(UITextField *)textField
{
    
}

#pragma UIPickerViewDataSource required methods
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayOfFiles.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *tempString =  [self.arrayOfFiles objectAtIndex:row];
    NSRange substringRange = [tempString rangeOfString:@" - ID="];
    NSString *title = [tempString substringToIndex:substringRange.location];
    
    return title;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayOfFiles = [[NSMutableArray alloc] init];
    self.arrayOfStudents = [[NSMutableArray alloc] init];
    
    
#if !defined(NS_BLOCK_ASSERTIONS)
//    NSLog(@"is Equal? %i", [kClientID isEqualToString:@"82296042172-s23hcibpj3mi7bvnhelp1bq0qq80cqb0.apps.googleusercontent.com"]);
    
    BOOL isEqual = [kClientID isEqualToString:@"82296042172-s23hcibpj3mi7bvnhelp1bq0qq80cqb0.apps.googleusercontent.com"];
    
    NSAssert( isEqual == YES,
             @"Update kClientID with your own client ID. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
    
    isEqual = [kRedirectURI isEqualToString:@"com.googleusercontent.apps.82296042172-s23hcibpj3mi7bvnhelp1bq0qq80cqb0:/oauthredirect"];
    NSAssert(isEqual == YES,
             @"Update kRedirectURI with your own redirect URI. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
    
    
    // verifies that the custom URI scheme has been updated in the Info.plist
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    NSAssert(urlTypes.count > 0, @"No custom URI scheme has been configured for the project.");
    NSArray *urlSchemes = ((NSDictionary *)urlTypes.firstObject)[@"CFBundleURLSchemes"];
    NSAssert(urlSchemes.count > 0, @"No custom URI scheme has been configured for the project.");
    NSString *urlScheme = urlSchemes.firstObject;
    
    NSAssert([urlScheme isEqualToString:@"com.googleusercontent.apps.82296042172-s23hcibpj3mi7bvnhelp1bq0qq80cqb0"],
             @"Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) "
             "with the scheme of your redirect URI. Full instructions: "
             "https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
    
#endif // !defined(NS_BLOCK_ASSERTIONS)
    
    self.driveService = [[GTLRDriveService alloc] init];
    self.sheetsService = [[GTLRSheetsService alloc] init];
    
    _logTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    _logTextView.layer.borderWidth = 1.0f;
    _logTextView.alwaysBounceVertical = YES;
    _logTextView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    _logTextView.text = @"";
    
    [self loadState];
    [self updateUI];
    [self.fileWithPeriod reloadAllComponents];
    
    self.googleAuthFrame.layer.borderColor = [UIColor colorWithRed:.8 green:0 blue:0 alpha:1.0].CGColor;
    self.googleAuthFrame.layer.borderWidth = 1.0f;
    
    self.fileInfoFrame.layer.borderColor = [UIColor colorWithRed:.8 green:0 blue:0 alpha:1.0].CGColor;
    self.fileInfoFrame.layer.borderWidth = 1.0f;

    self.errorLogFrame.layer.borderColor = [UIColor colorWithRed:.8 green:0 blue:0 alpha:1.0].CGColor;
    self.errorLogFrame.layer.borderWidth = 1.0f;

    self.resetButton.layer.borderWidth = 2;
    self.saveButton.layer.borderWidth = 2;
    self.userinfoButton.layer.borderWidth = 2;
//    self.googleFrame.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.fileWithPeriod reloadAllComponents];
    
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
            [self showAlert:@"Database Message" message:@"All entries deleted!"];
        }
        else
        {
            [self showAlert:@"Database Message" message:@"Error resetting database - See log for details"];
            [self logMessage:@"Error attempting to reset database - %s", sqlite3_errmsg(studentDB)];
        }
        
        
    }
    
    sqlite3_close(studentDB);
    [self.arrayOfStudents removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@"" forKey:KEY_PERIOD ];
    [userDefaults synchronize];

    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}





-(IBAction) saveInfo:(id) sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (self.arrayOfFiles.count == 0 && (![[userDefaults objectForKey:KEY_PERIOD] isEqualToString:@""]))
    {
        // Do nothing. All the user did was to click the User Preferences button.
        
    }
    else if (self.arrayOfFiles.count == 0)
    {
        NSLog(@"Nil!");
        [userDefaults setObject:@"" forKey:KEY_PERIOD];
    }
    else
    {
        [userDefaults setObject:self.userNameField.text forKey:KEY_USER];
        [userDefaults setObject:self.fileNameField.text forKey:KEY_FILENAME];
        //    NSString *tempPeriod = [NSString stringWithString:self.periodField.text];
        NSInteger selectedRow = [self.fileWithPeriod selectedRowInComponent:0];
        
        NSString *tempString = [self.arrayOfFiles objectAtIndex:selectedRow ];
        NSRange substringRange = [tempString rangeOfString:@" - "];
        NSString *periodNumber = [tempString substringToIndex:substringRange.location];
        
        [userDefaults setObject:periodNumber forKey:KEY_PERIOD];
        NSString *restOfString = [tempString substringFromIndex:substringRange.location + 1];
        substringRange = [restOfString rangeOfString:@" - ID="];
        NSString *spreadsheetID = [restOfString substringFromIndex:substringRange.location + 6];
        
        NSString *range = [NSString stringWithFormat:@"%@!A2:B", periodNumber];
        GTLRSheetsService *sheetsService = self.sheetsService;
        GTLRSheetsQuery_SpreadsheetsValuesGet *query =
            [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:spreadsheetID range:range];

        [sheetsService executeQuery:query
                 completionHandler:^(GTLRServiceTicket *callbackTicket,
                                     GTLRSheets_ValueRange *result,
                                     NSError *error)
        {
            if (error == nil)
            {
                NSArray *rows = result.values;
                if (rows.count > 0) {
                    for (NSArray *row in rows) {
                        // Print columns A and B, which correspond to indices 0 and 4.
//                        [self.arrayOfStudents addObject:[NSString stringWithFormat:@"%@ %@", row[0], row[1]]];
                        [self.arrayOfStudents addObject:row[0]];
                        [self.arrayOfStudents addObject:row[1]];
    //                        [self.arrayOfStudents addObject:[NSString stringWithFormat:@"%@ %@", row[0], row[1]]];
                    }
                } else {
                    NSLog(@"No data found.");
                }
            } else {
                NSMutableString *message = [[NSMutableString alloc] init];
                [message appendFormat:@"Error getting sheet data: %@\n", error.localizedDescription];
                NSLog(@"Error getting sheet data %@", error.localizedDescription);
            }
        
         [RS_Database insertRealValuesIntoDB:periodNumber withArray:self.arrayOfStudents];
        }];
         
    }

    [userDefaults setBool:YES forKey:KEY_RETURNINGUSER];
    [userDefaults synchronize];
    
    [self.delegate SetupViewControllerDidFinish:self];

}


/*! @brief Saves the @c GTMAppAuthFetcherAuthorization to @c NSUSerDefaults.
 */
- (void)saveState {
    if (_authorization.canAuthorize) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:kExampleAuthorizerKey];
    } else {
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kExampleAuthorizerKey];
    }
}

/*! @brief Loads the @c GTMAppAuthFetcherAuthorization from @c NSUSerDefaults.
 */
- (void)loadState {
    GTMAppAuthFetcherAuthorization* authorization =
    [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kExampleAuthorizerKey];
    [self setGtmAuthorization:authorization];
}

- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
//    NSLog(@"Authorization == %@", authorization);
    if ([_authorization isEqual:authorization]) {
        return;
    }
    _authorization = authorization;
    self.driveService.authorizer = authorization;
    self.sheetsService.authorizer = authorization;
    [self stateChanged];
}

/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI {
//    _userinfoButton.opaque = !_authorization.canAuthorize;
//    _clearAuthStateButton.opaque = !_authorization.canAuthorize;
    
    _userinfoButton.enabled = _authorization.canAuthorize;
    _clearAuthStateButton.enabled = _authorization.canAuthorize;
    // dynamically changes authorize button text depending on authorized state
    if (!_authorization.canAuthorize) {
        [_authAutoButton setTitle:@"Authorize" forState:UIControlStateNormal];
        [_authAutoButton setTitle:@"Authorize" forState:UIControlStateHighlighted];
        self.userinfoButton.alpha = .25;
        self.clearAuthStateButton.alpha = .25;
    } else {
        [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateNormal];
        [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateHighlighted];
        self.userinfoButton.alpha = 1.0;
        self.clearAuthStateButton.alpha = 1.0;
    }
}

- (void)stateChanged {
    [self saveState];
    [self updateUI];
}

- (void)didChangeState:(OIDAuthState *)state {
    [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(NSError *)error {
    [self logMessage:@"Received authorization error: %@", error];
}

- (IBAction)authWithAutoCodeExchange:(nullable id)sender {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
//    [self logMessage:@"Fetching configuration for issuer: %@", issuer];
   
    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
            if (!configuration)
            {
                [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
                [self setGtmAuthorization:nil];
                return;
            }
                                                            
//            [self logMessage:@"Got configuration: %@", configuration];
            // builds authentication request
            OIDAuthorizationRequest *request =
                [[OIDAuthorizationRequest alloc]
                 initWithConfiguration:configuration
                 clientId:kClientID
                 scopes:@[OIDScopeOpenID, OIDScopeProfile, kGTLRAuthScopeDrive, kGTLRAuthScopeSheetsDrive, kGTLRAuthScopeSheetsSpreadsheets]
                 redirectURL:redirectURI
                 responseType:OIDResponseTypeCode
                 additionalParameters:nil];
            // performs authentication request
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [self logMessage:@"Initiating authorization request with scope: %@", request.scope];
                                                            
            appDelegate.currentAuthorizationFlow =
                [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                presentingViewController:self
                                callback:^(OIDAuthState *_Nullable authState,
                                            NSError *_Nullable error) {
                                            if (authState)
                                            {
                                                GTMAppAuthFetcherAuthorization *authorization =
                                                    [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                                                                                   
                                                [self setGtmAuthorization:authorization];
                                                //self.service.authorizer = authorization;
//                                                [self logMessage:@"Got authorization tokens. Access token: %@",
//                                                    authState.lastTokenResponse.accessToken];
                                            }
                                            else
                                            {
                                                [self setGtmAuthorization:nil];
                                                [self logMessage:@"Authorization error: %@", [error localizedDescription]];
                                            }
                                        }];
                                    }];
    
}

- (IBAction)clearAuthState:(nullable id)sender {
    [self setGtmAuthorization:nil];
}

- (IBAction)clearLog:(nullable id)sender {
    _logTextView.text = @"";
}

- (IBAction)userinfo:(nullable id)sender {
    
    [self.arrayOfFiles removeAllObjects];

    GTLRDriveService *driveService = self.driveService;
    GTLRSheetsService *sheetsService = self.sheetsService;
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
        
//        query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed)";
    query.fields = @"kind,nextPageToken,files(id,name,kind)";
    if ([self.fileNameField.text isEqualToString:@""] || [self.fileNameField.text isEqualToString:@"Filter by Filename"] )
    {
        query.q = @"mimeType = 'application/vnd.google-apps.spreadsheet'";
    }
    else
    {
        query.q = [NSString stringWithFormat:@"name contains '%@' AND mimeType = 'application/vnd.google-apps.spreadsheet'", self.fileNameField.text];
    }
//    query.q = @"name = 'Rosters.xlsx' AND mimeType = 'application/vnd.google-apps.spreadsheet'";
//    query.q = @"mimeType = 'application/vnd.google-apps.spreadsheet'";
    [driveService executeQuery:query
        completionHandler:^(GTLRServiceTicket *callbackTicket,
                            GTLRDrive_FileList *fileList,
                            NSError *error) {
            if (error)
            {
                [self logMessage:@"Error: %@", error];
            }
            else
            {
                for (GTLRDrive_File *item in fileList)
                {
 //                   [self logMessage:@"Item: %@ (%@) . MIME Type == %@", item.name, item.kind, item.identifier];
                    NSString *spreadsheetId = item.identifier;
                    GTLRSheetsQuery_SpreadsheetsGet *sheetsQuery = [GTLRSheetsQuery_SpreadsheetsGet queryWithSpreadsheetId:spreadsheetId];
                    sheetsQuery.includeGridData = NO;
                        
                    [sheetsService executeQuery:sheetsQuery
                                        delegate:self
                                didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
  
                    }
                }
            }];
}

// Process the response and display output
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRSheets_Spreadsheet *)result
                          error:(NSError *)error
{
    if (error == nil)
    {
        NSArray *sheets = result.sheets;
        for (GTLRSheets_Sheet *row in sheets)
        {
            [self.arrayOfFiles addObject:[NSString stringWithFormat:@"%@ - %@ - ID=%@", row.properties.title, result.properties.title, result.spreadsheetId]];
        }
    [self.fileWithPeriod reloadAllComponents];

    }
    else
    {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting sheet data: %@\n", error.localizedDescription];
    }
}

- (GTLRDriveService *)driveService {
    static GTLRDriveService *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLRDriveService alloc] init];
        
        // Turn on the library's shouldFetchNextPages feature to ensure that all items
        // are fetched.  This applies to queries which return an object derived from
        // GTLRCollectionObject.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
    });
    return service;
}
- (GTLRSheetsService *)sheetsService {
    static GTLRSheetsService *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLRSheetsService alloc] init];
        
        // Turn on the library's shouldFetchNextPages feature to ensure that all items
        // are fetched.  This applies to queries which return an object derived from
        // GTLRCollectionObject.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
    });
    return service;
}

/*! @brief Logs a message to stdout and the textfield.
 @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    // gets message as string
    va_list argp;
    va_start(argp, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
    va_end(argp);
    
    // outputs to stdout
    NSLog(@"%@", log);
    
    // appends to output log
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    _logTextView.text = [NSString stringWithFormat:@"%@%@%@: %@",
                         _logTextView.text,
                         ([_logTextView.text length] > 0) ? @"\n" : @"",
                         dateString,
                         log];
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end

/*
 
 This is where I'm saving stuff...
 
 #import "GTMAppAuthExampleViewController.h"
 
 @interface GTMAppAuthExampleViewController ()
 
 @end
 
 @implementation GTMAppAuthExampleViewController
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 // Do any additional setup after loading the view from its nib.
 }
 
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }
 
 
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 
 @end
 
 NSURL *userinfoEndpoint =
 self.authorization.authState.lastAuthorizationResponse.request.configuration.discoveryDocument.userinfoEndpoint;
 if (!userinfoEndpoint) {
 [self logMessage:@"Userinfo endpoint not declared in discovery document"];
 return;
 }
 NSString *currentAccessToken = self.authorization.authState.lastTokenResponse.accessToken;
 
 [self logMessage:@"Performing Authorization request"];
 
 [self.authorization.authState performActionWithFreshTokens:^(NSString *_Nonnull accessToken,
 NSString *_Nonnull idToken,
 NSError *_Nullable error) {
 if (error) {
 [self logMessage:@"Error fetching fresh tokens: %@", [error localizedDescription]];
 return;
 }
 
 // log whether a token refresh occurred
 if (![currentAccessToken isEqual:accessToken]) {
 [self logMessage:@"Access token was refreshed automatically (%@ to %@)",
 currentAccessToken,
 accessToken];
 } else {
 [self logMessage:@"Access token was fresh and not updated [%@]", accessToken];
 }
 
 // creates request to the userinfo endpoint, with access token in the Authorization header
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
 NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
 [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
 
 NSURLSessionConfiguration *configuration =
 [NSURLSessionConfiguration defaultSessionConfiguration];
 NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
 delegate:nil
 delegateQueue:nil];
 
 // performs HTTP request
 NSURLSessionDataTask *postDataTask =
 [session dataTaskWithRequest:request
 completionHandler:^(NSData *_Nullable data,
 NSURLResponse *_Nullable response,
 NSError *_Nullable error) {
 dispatch_async(dispatch_get_main_queue(), ^() {
 if (error) {
 [self logMessage:@"HTTP request failed %@", error];
 return;
 }
 if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
 [self logMessage:@"Non-HTTP response"];
 return;
 }
 
 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
 id jsonDictionaryOrArray =
 [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
 
 if (httpResponse.statusCode != 200) {
 // server replied with an error
 NSString *responseText = [[NSString alloc] initWithData:data
 encoding:NSUTF8StringEncoding];
 if (httpResponse.statusCode == 401) {
 // "401 Unauthorized" generally indicates there is an issue with the authorization
 // grant. Puts OIDAuthState into an error state.
 NSError *oauthError =
 [OIDErrorUtilities resourceServerAuthorizationErrorWithCode:0
 errorResponse:jsonDictionaryOrArray
 underlyingError:error];
 [self.authorization.authState updateWithAuthorizationError:oauthError];
 // log error
 [self logMessage:@"Authorization Error (%@). Response: %@", oauthError, responseText];
 } else {
 [self logMessage:@"HTTP: %d. Response: %@",
 (int)httpResponse.statusCode,
 responseText];
 }
 return;
 }
 
 // success response
 [self logMessage:@"Success: %@", jsonDictionaryOrArray];
 });
 }];
 
 [postDataTask resume];
 }];
 
 
 
 // The designated initializer.  Override if you create the controller programmatically
 // and want to perform customization that is not appropriate for viewDidLoad.
 */
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 
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
    
    This moves stuff around, but it's not quite right...
     
     CGRect backgroundRect = activeField.superview.frame;
     backgroundRect.size.height += keyboardSize.height;
     [activeField.superview setFrame:backgroundRect];
     [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y - keyboardSize.height) animated:YES];
 
    
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
 - (void)viewDidUnload {
 [super viewDidUnload];
 // Release any retained subviews of the main view.
 // e.g. self.myOutlet = nil;
 [self unregisterNotificationEvents];
 
 }

 */
// Override to allow orientations other than the default portrait orientation.
/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait) ||
 (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
 (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
 }
 */


