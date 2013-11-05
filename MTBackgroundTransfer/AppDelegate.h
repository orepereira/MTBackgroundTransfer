//
//  AppDelegate.h
//  MTBackgroundTransfer
//
//  Created by Jorge Costa on 10/16/13.
//  Copyright (c) 2013 MobileTuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundSessionCompletionHandler)();

@end
