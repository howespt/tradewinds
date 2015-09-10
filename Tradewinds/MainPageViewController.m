//
//  MainPageViewController.m
//  Tradewinds
//
//  Created by Phil Howes on 30/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import "MainPageViewController.h"
#import "OverviewViewController.h"
#import "ReservationsViewController.h"

@interface MainPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) ReservationsViewController *reservationsVC;
@property (strong, nonatomic) UINavigationController *reservationsNav;
@property (strong, nonatomic) OverviewViewController *overviewVC;
@property (strong, nonatomic) UINavigationController *overviewNav;

@end

@implementation MainPageViewController


- (instancetype)init {
  self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.reservationsVC = [ReservationsViewController new];
  self.overviewVC = [OverviewViewController new];
  self.delegate = self;
  self.dataSource = self;
  [self setViewControllers:@[self.overviewVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
  
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  if (viewController == self.reservationsVC) {
    return self.overviewVC;
  }
  
  return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  if (viewController == self.overviewVC) {
    return self.reservationsVC;
  }
  
  return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
  return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
  return 0;
}

@end
