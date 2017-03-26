//
//  AppDelegate.h
//  RandomStudent
//
//  Created by Christopher Galasso on 3/7/17.
//  Copyright © 2017 Christopher Galasso. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OIDAuthorizationFlowSession;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

@property (strong, nonatomic, nonnull) UIWindow *window;


@end

