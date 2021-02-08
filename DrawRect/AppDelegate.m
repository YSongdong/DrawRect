//
//  AppDelegate.m
//  DrawRect
//
//  Created by tiao on 2021/2/4.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    ViewController *view = [[ViewController alloc]init];
    
    self.window.rootViewController = view;
    //现实Window
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
