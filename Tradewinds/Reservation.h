//
//  Reservation.h
//  Tradewinds
//
//  Created by Phil Howes on 30/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reservation : NSManagedObject

@property (nonatomic, retain) NSString * start_date_time;
@property (nonatomic, retain) NSString * boat_name;
@property (nonatomic, retain) NSNumber * cancelled;
@property (nonatomic, retain) NSString * end_date_time;
@property (nonatomic, retain) NSString * slip;

@end
