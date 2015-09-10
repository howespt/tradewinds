//
//  Availability.h
//  Tradewinds
//
//  Created by Phil Howes on 30/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Availability : NSManagedObject

@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * unavailable;
@property (nonatomic, retain) NSString * boat_name;
@property (nonatomic, retain) NSString * availability_date;

@end
