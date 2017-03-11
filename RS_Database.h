//
//  RS_Database.h
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "sqlite3.h"
@protocol RS_Database_Protocol;


@interface RS_Database : NSObject {
    
}
@property (retain, nonatomic) NSString *formatStyle;
@property (retain, nonatomic) id delegate;

+(void)showError:(const char *) errorMessage;
+(NSString* ) getStudentDBFileName;
+ (void)createStudentDBTable;
+ (void)insertTestValuesIntoDB;
+(int) getNumberOfEntriesFromDB;
+ (int) getNumberOfEntriesFromDB:(NSString *) period;


@end
@protocol RS_Database_Protocol

-(void) operationDidFinish:(RS_Database *) db;

@end
