//
//  ViewController.m
//  Tradewinds
//
//  Created by Phil Howes on 10/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import "ViewController.h"
#import "OverviewViewController.h"
#import "TradeWindsAPI.h"
#import "MainPageViewController.h"

@interface ViewController ()

@property (strong, nonatomic) TradeWindsAPI *tradewinds;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tradewinds = [TradeWindsAPI new];
  [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  if ([userDefaults objectForKey:@"logged_in"]) {
    [self handleLogin];
  }
  [self handleLogin];
}

- (void)login {
  [self handleLogin];
  [self.tradewinds loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text callback:^(NSDictionary *response) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@YES forKey:@"logged_in"];
    [userDefaults setObject:self.passwordTextField.text forKey:@"password"];
    [userDefaults setObject:self.usernameTextField.text forKey:@"username"];
    
    [self handleLogin];
  }];
}

- (void)handleLogin {
  MainPageViewController *mainPageVC = [MainPageViewController new];
  UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:mainPageVC];
  [self presentViewController:navControl animated:YES completion:nil];
}

@end
