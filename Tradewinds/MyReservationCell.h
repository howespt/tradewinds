//
//  MyReservationCell.h
//  Tradewinds
//
//  Created by Phil Howes on 10/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyReservationCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *boatName;
@property (strong, nonatomic) IBOutlet UILabel *reservationStart;
@property (strong, nonatomic) IBOutlet UILabel *reservationEnd;

@end
