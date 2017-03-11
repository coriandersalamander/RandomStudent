//
//  ViewController.m
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import "ViewController.h"
#import "RS_Database.h"
#import "sqlite3.h"
#define KEY_USER @"KeyUser"
#define KEY_FIRSTNAME @"KeyFirstName"
#define KEY_RETURNINGUSER @"KeyReturningUser"
#define KEY_PERIOD @"KeyPeriod"


@interface ViewController () 

@end

@implementation ViewController
- (IBAction) populate:(id) sender
{
    
    [self showSetupScreen];
    
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return [self.arrayOfPerson objectAtIndex:row];
}

- (void)showSetupScreen
{
    NSLog(@"I'm here!!!");
    SetupViewController *controller = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
    //	controller.period = self.period;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    controller.delegate = self;
    
    //	[self presentModalViewController:controller animated:YES];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void) SetupViewControllerDidFinish:(SetupViewController *) controller
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tempPeriod = [userDefaults objectForKey:KEY_PERIOD];
    if ([tempPeriod isEqualToString:@""])
    {
        self.periodLabel.text = @"Entire Roster - No Period Selected";
    }
    else
    {
        self.periodLabel.text = [NSString stringWithFormat:@"Period %@", tempPeriod];
    }
    
    [RS_Database createStudentDBTable];
    if ([RS_Database getNumberOfEntriesFromDB] == 0)
    {
        [RS_Database insertTestValuesIntoDB];
    }
    [self loadValuesIntoArray];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)displayAll
{
    sqlite3_stmt *statement ;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"Students.db"];
    
    //	self.formatStyle = @"FirstNameFirst";
    //	self.formatStyle = @"LastNameFirst";
    sqlite3 *studentDB;
    
    if (sqlite3_open([dbPathString UTF8String], &studentDB)==SQLITE_OK)
    {
        //        [arrayOfPerson removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM STUDENTS"];
        const char *query_sql = [querySQL UTF8String];
        if (sqlite3_prepare_v2(studentDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                [self.arrayOfPerson addObject:name];
                
            }
        }
    }
    
    //    [[self myTableView]reloadData];
    [self.studentPicker reloadAllComponents];
}

-(void) loadValuesIntoArray
{
    NSLog(@"In loadValuesIntoArray");
    NSString * dbPathString = [RS_Database getStudentDBFileName];
    [self.arrayOfPerson removeAllObjects];
    
    /*	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please enter period", @"new_list_dialog")
     message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
     periodField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
     
     [periodField setBackgroundColor:[UIColor whiteColor]];
     [alert addSubview:periodField];
     [alert show];
     [alert release];
     
     */
    sqlite3 *studentDB;
    
    if (sqlite3_open([dbPathString UTF8String], &studentDB)==SQLITE_OK)
    {
        
        sqlite3_stmt *statement ;
        
        NSString *querySQL = nil;
        
        if ([self.periodLabel.text isEqualToString:@"Entire Roster - No Period Selected"])
        {
            querySQL = [NSString stringWithFormat:@"SELECT * FROM STUDENTS"];
        }
        else
        {
            NSRange substringRange = [self.periodLabel.text rangeOfString:@" "];
            NSString *periodNumber = [self.periodLabel.text substringFromIndex:substringRange.location + 1];
            
            querySQL = [NSString stringWithFormat:@"SELECT * FROM STUDENTS WHERE PERIOD = '%@'", periodNumber];
            
        }
        
        NSLog(@"Query SQL = %@", querySQL);
        const char *query_sql = [querySQL UTF8String];
        if (sqlite3_prepare_v2(studentDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *fullName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)] ;
                //				NSRange substringRange = [fullName rangeOfString:@" "];
                
                //				NSString *firstName = [fullName substringToIndex:substringRange.location];
                //				NSLog(@"First name == %@", firstName);
                [self.arrayOfPerson addObject:fullName];
                //				NSString *lastName = [fullName substringFromIndex:substringRange.location + 1];
                //				NSLog(@"Last name == %@", lastName);
                
                
            }
            if ((sqlite3_finalize(statement)) != SQLITE_OK)
            {
                NSLog(@"SQL finalize not ok == %s", sqlite3_errmsg(studentDB));
            }
        }
        else 
        {
            NSLog(@"Prep didn't work! Error == %s", sqlite3_errmsg(studentDB));
        }
        
    }
    else 
    {
        NSLog(@"Open didn't work! Error == %s", sqlite3_errmsg(studentDB));
        
    }
    sqlite3_close(studentDB);
    
    
}
-(void) infoViewDidFinish:(InfoViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)showInfo:(id)sender {
    
    InfoViewController *controller = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
    
    
}

-(void) logSelf
{
    for (NSString* tempString in self.arrayOfPerson) {
        NSLog(@"%@", tempString);
    }
}	

- (IBAction) chooseRandom:(id) sender
{
    
    if (self.randomTimer)
    {
        [self.randomTimer invalidate];
        self.randomTimer = nil;
        [self.randomButton setTitle:@"Random!" forState:UIControlStateNormal];
    }
    else
    {
        [self.randomButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.randomTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(selectStudent:) userInfo:nil repeats:YES];
    }
    
}
-(void) selectStudent:(id) object
{
    
    int numberOfEntries = (int)self.arrayOfPerson.count;
    
    NSNumber *rand = [[NSNumber alloc] initWithLong:arc4random_uniform(numberOfEntries)] ;
    
    
    [self.studentPicker selectRow:[rand intValue] inComponent:0 animated:YES];
}	


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.randomButton.layer.cornerRadius = 10;//half of the width
    self.userPrefButton.layer.cornerRadius = 10;//half of the width

    self.studentPicker.layer.cornerRadius = 10;//half of the width
    self.studentPicker.layer.borderWidth = 2;
    self.studentPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.arrayOfPerson = [[NSMutableArray alloc] init];
    
    [RS_Database createStudentDBTable];
    if ([RS_Database getNumberOfEntriesFromDB] == 0)
    {
        [RS_Database insertTestValuesIntoDB];
    }
    [self loadValuesIntoArray];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UIPickerViewDataSource required methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayOfPerson.count;
}


@end
