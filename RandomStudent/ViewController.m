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
#define KEY_PERIOD @"KeyPeriod"
#define KEY_PERIOD_ARRAY @"Key_Period_Array"



@interface ViewController () 

@end

@implementation ViewController
- (IBAction) populate:(id) sender
{
    
    [self showSetupScreen];
    
}

#pragma UIPickerViewDataSource required methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.studentPicker])
    {
        return self.arrayOfPerson.count;
    }
    else
    {
        return self.arrayOfPeriods.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.studentPicker])
    {
        return [self.arrayOfPerson objectAtIndex:row];
    }
    else
    {
        return [self.arrayOfPeriods objectAtIndex:row];
        
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view __TVOS_PROHIBITED
{
 
    UILabel *pickerRowLabel = (UILabel *)view;
    if (pickerRowLabel == nil)
    {
        // Rule 1: width and height match what the picker view expects.
        //         Change as needed.
//        NSLog(@"Bounds == %f", pickerView.bounds.size.height);
//        CGRect frame = CGRectMake(0.0, 0.0, 320, 44); Again... Hardcoding is bad.
        CGRect frame = CGRectMake(0.0, 0.0, pickerView.frame.size.width, pickerView.frame.size.height * .15);
//        CGRect frame = CGRectMake(0.0, 0.0, pickerView.frame.size. );
        pickerRowLabel = [[UILabel alloc] initWithFrame:frame];
//        pickerRowLabel.layer.cornerRadius = pickerRowLabel.bounds.size.width / 2;
        // Rule 2: background color is clear. The view is positioned over
        //         the UIPickerView chrome.
            pickerRowLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:31.0/255.0 blue:91.0/255.0 alpha:1.0];
            pickerRowLabel.textColor = [UIColor colorWithRed:242.0/255.0 green:169.0/255.0 blue:0.0/255.0 alpha:1.0];
        // Rule 3: view must capture all touches otherwise the cell will highlight,
        //         because the picker view uses a UITableView in its implementation.
        pickerRowLabel.userInteractionEnabled = YES;
        pickerRowLabel.font = [UIFont fontWithName:@"Futura-Bold" size:17.0];
        pickerRowLabel.textAlignment = NSTextAlignmentCenter;
    }
    if ([pickerView isEqual:self.studentPicker])
    {
        pickerRowLabel.text = [self.arrayOfPerson objectAtIndex:row];

    }
    else
    {
        pickerRowLabel.text = [self.arrayOfPeriods objectAtIndex:row];
        
    }
    return pickerRowLabel;
 
}


// User presses User Preferences
- (void)showSetupScreen
{
    SetupViewController *controller = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    controller.delegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)choosePeriod:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"\n\n\n\n\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    //Make a frame for the picker & then create the picker
    CGRect pickerFrame = CGRectMake(25, 10, 200, 160);
    self.periodsPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    
    self.periodsPicker.backgroundColor = [UIColor lightGrayColor];
//    self.periodsPicker.layer.borderColor = [UIColor redColor].CGColor;
//    self.periodsPicker.layer.borderWidth = 1;
    //There will be 3 pickers on this view so I am going to use the tag as a way
    //to identify them in the delegate and datasource
    self.periodsPicker.tag = 1;
    
    //set the pickers datasource and delegate
    self.periodsPicker.dataSource = self;
    self.periodsPicker.delegate = self;
    
    //set the pickers selection indicator to true so that the user will now which one that they are chosing
    [self.periodsPicker setShowsSelectionIndicator:YES];
    
    //Add the picker to the alert controller
    [alert.view addSubview:self.periodsPicker];
    
    //make the toolbar view
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(25, 160, 200.0f, 40.f)];
    toolView.backgroundColor = [UIColor blackColor]; //set it's background
    
    //add buttons to the view
    CGRect buttonFrame = CGRectMake(0, 5, 100, 30); //size & position of the button as placed on the toolView
    //make the cancel button & set the title
    UIButton *button = [[UIButton alloc] initWithFrame: buttonFrame];
    [button setTitle: @"Ok" forState: UIControlStateNormal];
    
    [button setTitleColor: [UIColor blueColor] forState: UIControlStateNormal]; //make the color blue to keep the same look as prev version

    [button addTarget: self
               action: @selector(savePeriod:)
     forControlEvents: UIControlEventTouchDown];
    
    [toolView addSubview:button]; //add to the subview
    [alert.view addSubview:toolView];

    [self presentViewController:alert animated:NO completion:nil];
    
}

-(void) savePeriod:(id) object
{
    
    if ([self.periodsPicker numberOfRowsInComponent:0] > 0)
    {
        [self.arrayOfPerson removeAllObjects];
        
        NSInteger selectedRow = [self.periodsPicker selectedRowInComponent:0];
        self.period = [self.arrayOfPeriods objectAtIndex:selectedRow];
    
        [self loadValuesIntoArray];
        [self.studentPicker reloadAllComponents];
        self.periodLabel.text = [NSString stringWithFormat:@"Period - %@", self.period];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.period forKey:KEY_PERIOD];
        [userDefaults synchronize];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(void) SetupViewControllerDidFinish:(SetupViewController *) controller withPeriods:(NSMutableArray *)periods;

{
/*    [RS_Database createStudentDBTable];

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
    
    if ([RS_Database getNumberOfEntriesFromDB] == 0)
    {
        [RS_Database insertTestValuesIntoDB];
    }
    [self loadValuesIntoArray];
    [self.studentPicker reloadAllComponents];
    
*/

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.view.backgroundColor = [UIColor colorWithRed:0.08 green:0.69 blue:0.94 alpha:1.0]; //Petty Blue
//    self.view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:71.0/255.0 blue:187.0/255.0 alpha:1.0]; //Adelphi Blue
    self.view.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:120.0/255.0 blue:250.0/255.0 alpha:1.0]; //Winner! Don't change this! 
    
    
    self.randomButton.layer.cornerRadius = self.randomButton.bounds.size.width / 2;
//    self.randomButton.layer.borderColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.50 alpha:1.0].CGColor;
//    self.randomButton.layer.borderWidth = 2;
    self.userPrefButton.layer.cornerRadius = 10;
    self.userPrefButton.layer.borderColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.50 alpha:1.0].CGColor;
    self.userPrefButton.layer.borderWidth = 2;

    self.choosePeriodButton.layer.cornerRadius = 10;
    self.choosePeriodButton.layer.borderColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.50 alpha:1.0].CGColor;
    self.choosePeriodButton.layer.borderWidth = 2;
    
    /* Note to self... Hardcoding is bad. Use the width of the Picker to determine cornerRadius.
    self.studentPicker.layer.cornerRadius = 135; // This is good for iPhone 5, but hard-coding is bad.
    self.studentPicker.layer.cornerRadius = self.studentPicker.layer.bounds.size.width / 2; // This is far more flexible.
     */
    
//    self.studentPicker.layer.frame.size.height = 162.0;
    
/*
 NSLog(@"frame.size.width == %f", self.studentPicker.layer.frame.size.width);
    NSLog(@"frame.size.height == %f", self.studentPicker.layer.frame.size.height);
    NSLog(@"bounds.size.width == %f", self.studentPicker.layer.bounds.size.width);
    NSLog(@"bounds.size.height == %f", self.studentPicker.layer.bounds.size.height);
 */
    
//    self.studentPicker.layer.cornerRadius = 15;
    self.studentPicker.layer.masksToBounds = YES; // This value fixes a problem when running iOS 8.3 where the edges of the picker wheel's labels were peeking out into view, when they should have been hidden behind the picker itself.
//    self.studentPicker.layer.cornerRadius = 40;
    CGRect frame = self.studentPicker.frame;
    frame.size.width = MIN(self.studentPicker.bounds.size.width, self.studentPicker.bounds.size.height);
    frame.origin.x = frame.origin.x + (fabs(self.studentPicker.bounds.size.width - self.studentPicker.bounds.size.height)/2);
//    frame.origin.y = self.view.center.y;
    
//    [self.studentPicker setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [self.studentPicker setFrame:frame];

//    [self.studentPicker.center
    self.studentPicker.layer.cornerRadius = self.studentPicker.layer.bounds.size.width / 2;
//    self.studentPicker.set
    
    self.studentPicker.layer.needsDisplayOnBoundsChange = YES;
    
/*
 NSLog(@"frame.size.width == %f", self.studentPicker.layer.frame.size.width);
    NSLog(@"frame.size.height == %f", self.studentPicker.layer.frame.size.height);
    NSLog(@"bounds.size.width == %f", self.studentPicker.layer.bounds.size.width);
    NSLog(@"bounds.size.height == %f", self.studentPicker.layer.bounds.size.height);
*/
    
    self.studentPicker.layer.borderWidth = 2;
    self.studentPicker.layer.borderColor = [UIColor colorWithRed:0/255 green:31.0/255.0 blue:91.0/255.0 alpha:1.0].CGColor;
    
    self.studentPicker.layer.backgroundColor = [UIColor colorWithRed:158.0/255.0 green:86.0/255.0 blue:235.0/255.0 alpha:0.7].CGColor; // this is really close Called "Light Cyan Blue"
    
    


    //    self.studentPicker.layer.backgroundColor = [UIColor colorWithRed:131.0/255.0 green:120.0/255.0 blue:111.0/255.0 alpha:1.0].CGColor; // this is really close
    
//    self.studentPicker.layer.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:145.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    /* Experimenting here */
    
    /* End of experiments */
     
    
    self.arrayOfPerson = [[NSMutableArray alloc] init];
    self.arrayOfPeriods = [[NSMutableArray alloc] init];

    self.infoButton.layer.cornerRadius = 10;
    self.infoButton.layer.borderColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.50 alpha:1.0].CGColor;
    self.infoButton.layer.borderWidth = 2;
    [RS_Database createStudentDBTable];
    if ([RS_Database getNumberOfEntriesFromDB] == 0)
    {
        [RS_Database insertTestValuesIntoDB];
    }
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tempPeriod = [userDefaults objectForKey:KEY_PERIOD];
    if ([tempPeriod isEqualToString:@""] || tempPeriod == nil)
    {
        self.periodLabel.text = @"ALL Periods";
        self.period = @"";
    }
    else
    {
        self.periodLabel.text = [NSString stringWithFormat:@"Period - %@", tempPeriod];
        self.period = tempPeriod;
    }

    NSMutableArray *savedPeriodArray = [userDefaults objectForKey:KEY_PERIOD_ARRAY];
    if (savedPeriodArray != nil)
    {
        self.arrayOfPeriods = savedPeriodArray;
    }
    
    [self loadValuesIntoArray];
    [self.studentPicker reloadAllComponents];

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
                NSString *period = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                
                NSLog(@"Entry == %@ - Period == %@", name, period);
//                [self.arrayOfPerson addObject:name];
                
            }
        }
    }
    
}

-(void) loadValuesIntoArray
{
//    NSLog(@"In loadValuesIntoArray");
    NSString * dbPathString = [RS_Database getStudentDBFileName];
    [self.arrayOfPerson removeAllObjects];

    sqlite3 *studentDB;
//    NSLog(@"Number of students == %d", [RS_Database getNumberOfEntriesFromDB:self.period]);
    
    if (sqlite3_open([dbPathString UTF8String], &studentDB)==SQLITE_OK)
    {
        
        sqlite3_stmt *statement ;
        
        NSString *querySQL = nil;
        
        if ([self.period isEqualToString:@"" ] || self.period == nil)
        {
            querySQL = [NSString stringWithFormat:@"SELECT * FROM STUDENTS"];
        }
        else
        {
            querySQL = [NSString stringWithFormat:@"SELECT * FROM STUDENTS WHERE PERIOD = '%@'", self.period];
            
        }
        
//        NSLog(@"Query SQL Before = %@", querySQL);
        const char *query_sql = [querySQL UTF8String];
//        NSLog(@"Query SQL After = %s", query_sql);
        if (sqlite3_prepare_v2(studentDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *fullName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)] ;
                [self.arrayOfPerson addObject:fullName];
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
        [self.randomButton setImage:[UIImage imageNamed:@"goicon.png" ] forState:UIControlStateNormal];
    }
    else
    {
        [self.randomButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.randomButton setImage:[UIImage imageNamed:@"stopicon.png" ] forState:UIControlStateNormal];
        self.randomTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(selectStudent:) userInfo:nil repeats:YES];
    }
    
}
-(void) selectStudent:(id) object
{
    
    int numberOfEntries = (int)self.arrayOfPerson.count;
    NSNumber *rand = [[NSNumber alloc] initWithLong:arc4random_uniform(numberOfEntries)] ;
    [self.studentPicker selectRow:[rand intValue] inComponent:0 animated:YES];
}	

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
