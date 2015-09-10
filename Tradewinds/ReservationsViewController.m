//
//  ReservationsViewController.m
//  Tradewinds
//
//  Created by Phil Howes on 30/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import "ReservationsViewController.h"
#import "TradeWindsAPI.h"
#import "Availability.h"
#import "UIColor+Tradewinds.h"

@interface ReservationsViewController ()

@property (strong, nonatomic) TradeWindsAPI *tradewinds;
@property (strong, nonatomic) NSArray *boatsAndAvailabilities;
@property (strong, nonatomic) NSDate *selectedDate;

@end

@implementation ReservationsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tradewinds = [TradeWindsAPI new];
  self.selectedDate = [NSDate date];
  [self getAvailabilityFromDate:[NSDate date]];
  
  self.calendar = [JTCalendar new];
  self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
  self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
  self.calendar.calendarAppearance.ratioContentMenu = 2.;
  self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
  self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
    NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    NSInteger currentMonthIndex = comps.month;
    
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
      dateFormatter = [NSDateFormatter new];
      dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
    }
    
    while(currentMonthIndex <= 0){
      currentMonthIndex += 12;
    }
    
    NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
    
    return [NSString stringWithFormat:@"%ld\n%@", comps.year, monthText];
  };
  [self.calendar setMenuMonthsView:self.calendarMenuView];
  [self.calendar setContentView:self.calendarContentView];
  [self.calendar setDataSource:self];
  [self.calendar reloadData];
  
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidLayoutSubviews
{
  [self.calendar repositionViews];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
  if ([date compare:[NSDate date]] == NSOrderedDescending) {
    if ([[self.tradewinds dayOfWeekForDate:date] isEqualToString:@"S"]) {
      NSString *dateString = [self.tradewinds stringFromDate:date];
      NSArray *availabilities = [self.tradewinds getAvailabilitiesForDate:dateString];
      if ([availabilities count] > 0) {
        Availability *boat = [availabilities firstObject];
        if ([boat.updated_at compare:[[NSDate date] dateByAddingTimeInterval:-60*5]] == NSOrderedAscending) { // more than 5 mins old
          [self getAvailabilityFromDate:date];
        }
      } else {
        [self getAvailabilityFromDate:date];
      }
      
    }
    return [self.tradewinds anyAvailabilitiesForDate:date];
  }
  return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
  self.selectedDate = date;
  [self.tableView reloadData];
}

- (void)calendarDidLoadPreviousPage
{
  NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
  NSLog(@"Next page loaded");
}

- (NSDateFormatter *)dateFormatter
{
  static NSDateFormatter *dateFormatter;
  if(!dateFormatter){
    dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
  }
  
  return dateFormatter;
}

#pragma mark - Table view mumbo jumbo

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([self.selectedDate compare:[[NSDate date] dateByAddingTimeInterval:-60*60*24]] == NSOrderedDescending) {
    NSString *dateString = [self.tradewinds stringFromDate:self.selectedDate];
    self.boatsAndAvailabilities = [self.tradewinds getAvailabilitiesForDate:dateString];
    return [self.boatsAndAvailabilities count];
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  Availability *boatAndAvailability = [self.boatsAndAvailabilities objectAtIndex:indexPath.row];
  cell.textLabel.text = boatAndAvailability.boat_name;
  if ([boatAndAvailability.unavailable isEqualToNumber:[NSNumber numberWithBool:YES]]) {
    cell.backgroundColor = [UIColor reservedRed];
  } else {
    cell.backgroundColor = [UIColor availableGreen];
  }
  return cell;
}

#pragma mark - Tradewinds availability

- (void)getAvailabilityFromDate:(NSDate*)date {
  NSString *dateString = [self.tradewinds stringFromDate:date];
  [self.tradewinds getAvailabilityWithStartdate:dateString callback:^(NSDictionary *response) {
    [self.calendarContentView reloadData];
  }];
}

@end
