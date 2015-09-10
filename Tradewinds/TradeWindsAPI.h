//
//  TradeWindsAPI.h
//  Tradewinds
//
//  Created by Phil Howes on 10/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TradeWindsAPI : NSObject

- (void)loginWithUsername:(NSString *)username password:(NSString *)password callback:(void (^)(NSDictionary *response))callback;
- (void)refreshLoginWithCallback:(void (^)(NSDictionary *response))callback;

- (void)getReservationsWithCallback:(void (^)())callback;

- (void)getAvailabilityWithStartdate:(NSString *)startdate callback:(void (^)(NSDictionary *response))callback;

- (NSString *)stringFromDate:(NSDate *)date;

- (NSArray *)getAvailabilitiesForDate:(NSString *)dateString;

- (BOOL)anyAvailabilitiesForDate:(NSDate *)date;

- (NSString *)dayOfWeekForDate:(NSDate *)date;

- (NSArray *)getMyReservations;

@end
