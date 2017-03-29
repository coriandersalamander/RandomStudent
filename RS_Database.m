//
//  RS_Database.m
//  RandomStudent
//
//  Created by Christopher Galasso on 2/11/17.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "RS_Database.h"


@implementation RS_Database
@synthesize formatStyle;
@synthesize delegate;

+(NSString* ) getStudentDBFileName
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"Students.db"];
    return dbPathString;
    
}

+(void)createStudentDBTable
{
    //	[timeZoneNames count];
    // https://sheets.googleapis.com/v4/spreadsheets/spreadsheetId?&fields=sheets.properties
    
///    NSLog(@"Start - createStudentDBTable!");
    char *error;
    
    NSString *dbPathString = [RS_Database getStudentDBFileName];
    
    //	self.formatStyle = @"FirstNameFirst";
    //	self.formatStyle = @"LastNameFirst";
    
    //	NSURL *url = [NSURL URLWithString:dbPathString];
    //	NSLog(@"File size == %@", [url  )
    
    sqlite3 *studentDB;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString] )
    {
        NSLog(@"Db does not exist... Creating it");
        int retVal = sqlite3_open([dbPathString UTF8String], &studentDB);
        if (retVal == SQLITE_OK)
        {
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS STUDENTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, PERIOD TEXT)";
            retVal = sqlite3_exec(studentDB, sql_stmt, NULL, NULL, &error);
            if (retVal != SQLITE_OK)
                //execute the sql statement
            {
//                [self showError:sqlite3_errmsg(studentDB)];
                NSLog(@"Exec error = %s", sqlite3_errmsg(studentDB));
            }
            
        }
        else
        {
//            [self showError:sqlite3_errmsg(studentDB)];
            NSLog(@"Open error = %s", sqlite3_errmsg(studentDB));
            
        }
        sqlite3_close(studentDB);
    }
    else
    {
        //		NSLog(@"File size == ", [fileManager )
        // Nothing to do... Database already exists.
        // In the unlikely case that there exists a
        // students.db file, we'll probably need to log an error
        // and create a file using an index (in other words,
        // students1.db, students2.db, students3.db, etc.
        //
        // That's on the to-do list.
    }
    
}
+(int) getNumberOfEntriesFromDB
{
    return [self getNumberOfEntriesFromDB:@"ALL"];
}
+(int) getNumberOfEntriesFromDB:(NSString *) period
{
//    NSLog(@"insertReal - Period == %@ ", period);

    NSString * dbPathString = [RS_Database getStudentDBFileName];
    sqlite3_stmt *statement ;
    sqlite3 *studentDB;
    int numberOfEntries = 0;
    if (sqlite3_open([dbPathString UTF8String], &studentDB)==SQLITE_OK)
    {
        NSString *querySQL = nil;
        if ([period isEqualToString:@"ALL"])
        {
            querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM STUDENTS"];
        }
        else
        {
            querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM STUDENTS WHERE PERIOD = '%@'", period];
//            querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM STUDENTS WHERE PERIOD = 11"];
        }
        
        //		NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM STUDENTS WHERE PERIOD = 11"];
        //		NSLog(@"QuerySQL == %@", querySQL);
        //		NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type='table'"];
        const char *query_sql = [querySQL UTF8String];
        if (sqlite3_prepare_v2(studentDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            int retVal = sqlite3_step(statement);
            if (retVal == SQLITE_ROW)
            {
                numberOfEntries = sqlite3_column_int(statement, 0);
            }
            else
            {
                NSLog(@"Step ret val == %i", retVal);
            }
            if ((sqlite3_finalize(statement)) != SQLITE_OK)
            {
                NSLog(@"SQL finalize error == %s", sqlite3_errmsg(studentDB));
            }
        }
        else
        {
            NSLog(@"Prep didn't work! Error == %s", sqlite3_errmsg(studentDB));
        }
        sqlite3_close(studentDB);
    }
    else
    {
        NSLog(@"getNumberOfEntriesFromDB - Database Didnt Open! Error == %s", sqlite3_errmsg(studentDB));
    }
    return numberOfEntries;
}

+(void) insertTestValuesIntoDB
{
    
    NSMutableArray *myArr =
    [NSMutableArray arrayWithObjects:
     @"Mickey", @"Mouse",
     @"Donald", @"Duck",
     @"Goofy", @"",
     @"Pluto", @"",
     @"Huey", @"",
     @"Dewey", @"",
     @"Louie", @"",
     @"Nigel", @"Tufnel",
     @"David", @"St. Hubbins",
     @"Derek", @"Smalls",
/*     @"A", @"B",
     @"C", @"D",
     @"E", @"F",
     @"G", @"H",
     @"I", @"J",
     @"L", @"K",
     @"M", @"N",
     @"O", @"P",
     @"Q", @"R",
     @"S", @"T",
     @"U", @"V",
     @"W", @"X",
     @"Y", @"Z",
*/     nil];
    
    sqlite3 *studentDB;
    
    
    int numberOfEntries = [RS_Database getNumberOfEntriesFromDB];
    
    /*
     NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM STUDENTS WHERE PERIOD = %@", self.period];
     //		NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type='table'"];
     const char *query_sql = [querySQL UTF8String];
     if (sqlite3_prepare_v2(studentDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
     {
     int retVal = sqlite3_step(statement);
     if (retVal == SQLITE_ROW)
     {
     numberOfEntries = sqlite3_column_int(statement, 0);
     }
     else
     {
     NSLog(@"Step ret val == %i", retVal);
     }
     if ((sqlite3_finalize(statement)) != SQLITE_OK)
     {
     NSLog(@"SQL finalize error == %s", sqlite3_errmsg(studentDB));
     }
     
     }
     else
     {
     NSLog(@"Prep didn't work! Error == %s", sqlite3_errmsg(studentDB));
     }
     */
    //	self.formatStyle = @"FirstNameFirst";
    //	self.formatStyle = @"LastNameFirst";
    if (numberOfEntries == 0)
    {
        NSString * dbPathString = [RS_Database getStudentDBFileName];
        if (sqlite3_open([dbPathString UTF8String], &studentDB)==SQLITE_OK)
        {
            NSUInteger i, count = [myArr count];
            for (i = 0; i < count; i+=2)
            {
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", [myArr objectAtIndex:i], [myArr objectAtIndex:i+1]];
                NSString *insertStmt =
                [NSString stringWithFormat:@"INSERT INTO STUDENTS (NAME,PERIOD) VALUES ('%s','%s')",
                 [fullName UTF8String], "100"] ;
                const char *insert_stmt = [insertStmt UTF8String];
                //				NSLog(@"Attempting to add Person %@ and Period %@ to DB", fullName, @"11");
                char *error = nil;
                if (sqlite3_exec(studentDB, insert_stmt, NULL, NULL, &error) != SQLITE_OK)
                {
                    NSLog(@"Error - InsertTestValues - %s", sqlite3_errmsg(studentDB));
                }
                
            }
            sqlite3_close(studentDB);
        }
        else
        {
            NSLog(@"Database Didnt Open! Error == %s", sqlite3_errmsg(studentDB));
        }
        
    }
    else 
    {
        NSLog(@"Number of entries == %i", numberOfEntries);
    }
    
}
+(void) insertRealValuesIntoDB:(NSString *)period withArray:(NSMutableArray *)arr
{
    
    NSMutableArray *myArr =
        [NSMutableArray arrayWithArray:arr];
    
    sqlite3 *studentDB;
    
    int numberOfEntries = [RS_Database getNumberOfEntriesFromDB:period ];
    
    if (numberOfEntries == 0)
    {
        NSString * dbPathString = [RS_Database getStudentDBFileName];
        if (sqlite3_open([dbPathString UTF8String], &studentDB)==SQLITE_OK)
        {
            NSUInteger i, count = [myArr count];
            for (i = 0; i < count; i+=2)
            {
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", [myArr objectAtIndex:i], [myArr objectAtIndex:i+1]];
                NSString *insertStmt =
                [NSString stringWithFormat:@"INSERT INTO STUDENTS (NAME,PERIOD) VALUES ('%s','%@')",
                 [fullName UTF8String], period] ;
                const char *insert_stmt = [insertStmt UTF8String];
                NSLog(@"Attempting to add Person %@ and Period %@ to DB", fullName, period);
                char *error = nil;
                if (sqlite3_exec(studentDB, insert_stmt, NULL, NULL, &error) != SQLITE_OK)
                {
                    NSLog(@"Error - InsertTestValues - %s", sqlite3_errmsg(studentDB));
                }
                
            }
            sqlite3_close(studentDB);
        }
        else
        {
            NSLog(@"Database Didnt Open! Error == %s", sqlite3_errmsg(studentDB));
        }
        
    }
    
}

+(void)showError:(const char *) errorMessage
{

    NSLog(@"Error == %s", errorMessage);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DatabaseError" message:[NSString stringWithFormat:@"%s", errorMessage] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
    {         [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;

    [alert addAction:defaultAction];
    [rootViewController presentViewController:alert animated:YES completion:nil];
    
    

    /*	UIAlertView *alert =
     [[UIAlertView alloc] 
     initWithTitle:@"Database Error" 
     message:[NSString stringWithFormat:@"%s", errorMessage]
     delegate:self 
     cancelButtonTitle:@"Close" 
     otherButtonTitles:nil];
     [alert show];
     */	
}

@end
