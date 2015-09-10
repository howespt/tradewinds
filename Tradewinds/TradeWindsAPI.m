//
//  TradeWindsAPI.m
//  Tradewinds
//
//  Created by Phil Howes on 10/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import "TradeWindsAPI.h"
#import "AppDelegate.h"
#import "Reservation.h"

@interface TradeWindsAPI ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *networkManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation TradeWindsAPI

- (id)init {
  self = [super init];
  
  self.networkManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).sharedRequestOperationManager;
  self.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
  
  return self;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password callback:(void (^)(NSDictionary *response))callback {
  NSDictionary *params = @{@"userid": username, @"pwd": password};
  [self.networkManager GET:@"/Kiran/wsdl/Logon-action_Mob.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    callback(jsonObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
  }];
}

- (void)refreshLoginWithCallback:(void (^)(NSDictionary *))callback {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [self loginWithUsername:[userDefaults objectForKey:@"username"] password:[userDefaults objectForKey:@"password"] callback:^(NSDictionary *response) {
    callback(response);
  }];
}


- (void)getReservationsWithCallback:(void (^)())callback {
  [self.networkManager GET:@"/Kiran/wsdl/Reservations_Mob.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    
    if ([[jsonObject objectForKey:@"ErrorCode"] isEqual:[NSNumber numberWithLong:(long)0]]) {
      NSArray *reservations = [jsonObject objectForKey:@"Answerkey"];
      [self updateReservations:reservations];
      callback();
    } else {
      [self refreshLoginWithCallback:^(NSDictionary *response) {
        [self getReservationsWithCallback:^{
          callback();
        }];
      }];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
  }];
}

- (void)getAvailabilityWithStartdate:(NSString *)startdate callback:(void (^)(NSDictionary *response))callback {
//  [self getWeekenders];
  
  NSDictionary *params = @{@"StartDate": startdate, @"fleet": @"Silver"};
  
  [self.networkManager GET:@"/Kiran/wsdl/Availability_Mob.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(startdate);
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    NSLog(jsonObject.description);
    if ([[jsonObject objectForKey:@"ErrorCode"] isEqual:[NSNumber numberWithLong:(long)0]]) {
      NSArray *boatsAndAvailabilities = [jsonObject objectForKey:@"Answerkey"];
      for (NSDictionary *boatAndAvailability in boatsAndAvailabilities) {
        NSString *boatName = [boatAndAvailability objectForKey:@"boat_name"];
        [self upsertBoatAvailability:boatName andDictionaryOfValues:boatAndAvailability];
      }
    }
    
    callback(jsonObject);
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
  }];
}

- (void)getWeekenders {
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"MM/dd/YYYY"];
  NSString *nowDate = [dateFormat stringFromDate:now];
  
  NSDate *aWeek = [now dateByAddingTimeInterval:60*60*24*7];
  NSString *soon = [dateFormat stringFromDate:aWeek];
  
  NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
  NSArray *daysOfWeek = @[@"",@"Su",@"M",@"T",@"W",@"Th",@"F",@"S"];
  [nowDateFormatter setDateFormat:@"e"];
  NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:aWeek] integerValue];
  NSLog(@"Day of Week: %@",[daysOfWeek objectAtIndex:weekdayNumber]);
  
}

- (NSString *)stringFromDate:(NSDate *)date {
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"MM/dd/YYYY"];
  NSString *nowDate = [dateFormat stringFromDate:date];
  return nowDate;
}

- (NSString *)dayOfWeekForDate:(NSDate *)date {
  NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
  NSArray *daysOfWeek = @[@"",@"Su",@"M",@"T",@"W",@"Th",@"F",@"S"];
  [nowDateFormatter setDateFormat:@"e"];
  NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:date] integerValue];
  return [daysOfWeek objectAtIndex:weekdayNumber];
}

#pragma mark - Core data

- (void)upsertBoatAvailability:(NSString *)boatName andDictionaryOfValues:(NSDictionary *)objectValues {
  
  NSArray *availabilityData = [objectValues objectForKey:@"data"];
  for (NSDictionary *dateData in availabilityData) {
    NSString *dateString = [dateData objectForKey:@"date"];
    NSString *availabilityStatus = [[dateData objectForKey:@"boat_status"] objectForKey:@"first"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Availability"];
    NSPredicate *boatAndDataPredicate = [NSPredicate predicateWithFormat:@"(boat_name == %@) AND (availability_date == %@)", boatName, dateString];
    [request setPredicate:boatAndDataPredicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSManagedObject *object;
    if (results.count > 0) {
      object = [results objectAtIndex:0];
    } else {
      object = [NSEntityDescription insertNewObjectForEntityForName:@"Availability"
                                             inManagedObjectContext:self.managedObjectContext];
    }
    
    [object setValue:availabilityStatus forKey:@"unavailable"];
    [object setValue:boatName forKey:@"boat_name"];
    [object setValue:dateString forKey:@"availability_date"];
    [object setValue:[NSDate date] forKey:@"updated_at"];
    
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
      NSLog(@"Unresolved error %@, %@", saveError, [saveError userInfo]);
      //    abort();
    }
  }
}

- (void)updateReservations:(NSArray *)reservations {
  NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Reservation"];
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
  [results setValue:@YES forKey:@"cancelled"];
  for (NSDictionary *reservation in reservations) {
    Reservation *res = [NSEntityDescription insertNewObjectForEntityForName:@"Reservation"
                                           inManagedObjectContext:self.managedObjectContext];
    res.slip = [reservation objectForKey:@"slip"];
    res.boat_name = [reservation objectForKey:@"boat_name"];
    res.start_date_time = [reservation objectForKey:@"start_date_time"];
    res.end_date_time = [reservation objectForKey:@"end_date_time"];
    res.cancelled = @NO;
  }
  NSError *saveError = nil;
  if (![self.managedObjectContext save:&saveError]) {
    NSLog(@"Unresolved error %@, %@", saveError, [saveError userInfo]);
    //    abort();
  }
}


- (NSArray *)getAvailabilitiesForDate:(NSString *)dateString {
  NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Availability"];
  NSPredicate *boatAndDatePredicate = [NSPredicate predicateWithFormat:@"availability_date == %@", dateString];
  [request setPredicate:boatAndDatePredicate];
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
  return results;
}

- (BOOL)anyAvailabilitiesForDate:(NSDate *)date {
  NSString *dateString = [self stringFromDate:date];
  NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Availability"];
  NSPredicate *boatAndDatePredicate = [NSPredicate predicateWithFormat:@"(availability_date == %@) AND (unavailable == 0)", dateString];
  [request setPredicate:boatAndDatePredicate];
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
  if ([results count] > 0) {
    return YES;
  } else {
    return NO;
  }
}

- (NSArray *)getMyReservations {
  NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Reservation"];
  NSPredicate *notCancelled = [NSPredicate predicateWithFormat:@"cancelled == 0"];
  [request setPredicate:notCancelled];
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
  return results;
}

@end
