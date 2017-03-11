//
//  InfoViewController.h
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewProtocol; 
@interface InfoViewController : UIViewController
@property id delegate;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

-(IBAction) backButtonPressed:(id) sender;


@end
@protocol InfoViewProtocol

-(void) infoViewDidFinish:(InfoViewController *) controller;
@end
