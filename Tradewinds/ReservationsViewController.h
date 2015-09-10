//
//  ReservationsViewController.h
//  Tradewinds
//
//  Created by Phil Howes on 30/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTCalendar/JTCalendar.h>

@interface ReservationsViewController : UIViewController <JTCalendarDataSource, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
