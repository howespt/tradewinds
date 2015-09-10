//
//  OverviewViewController.m
//  Tradewinds
//
//  Created by Phil Howes on 10/05/2015.
//  Copyright (c) 2015 Phil Howes. All rights reserved.
//

#import "OverviewViewController.h"
#import "MyReservationCell.h"
#import "BoatAvailabilityCell.h"
#import "MyReservationCell.h"
#import "Reservation.h"
#import "UIColor+Tradewinds.h"
#import "TWReservationCell.h"

@interface OverviewViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) TradeWindsAPI *tradewinds;
@property (strong, nonatomic) NSArray *myReservations;
@property (strong, nonatomic) NSArray *calanderDays;



@end

@implementation OverviewViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.edgesForExtendedLayout = UIRectEdgeNone;
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  UINib *nib = [UINib nibWithNibName:@"TWReservationCell" bundle:nil];
  [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"myReservationCell"];
  
  self.tradewinds = [TradeWindsAPI new];
  self.navigationItem.title = @"Trade Winds";
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17.0f], NSForegroundColorAttributeName: [UIColor whiteColor]}];
  self.myReservations = [self.tradewinds getMyReservations];
  self.navigationController.navigationBar.barTintColor = [UIColor tradewindsGray];
  self.collectionView.backgroundColor = [UIColor tradewindsBackgroundGray];
}

- (void)fetchReservations {
  [self.tradewinds getReservationsWithCallback:^() {
    self.myReservations = [self.tradewinds getMyReservations];
    [self.collectionView reloadData];
  }];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self fetchReservations];
}

#pragma mark - collectionview

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  if (section == 0) {
    if ([self.myReservations isKindOfClass:[NSNull class]]) {
      return 1;
    }
    return MAX(1, [self.myReservations count]);
  } else {
    return [self.calanderDays count];
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  TWReservationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myReservationCell" forIndexPath:indexPath];
  cell.backgroundColor = [UIColor whiteColor];
  cell.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
  cell.layer.shadowOffset = CGSizeMake(-2, 2);
  cell.layer.shadowOpacity = 0.7;
  cell.layer.shadowRadius = 2;
  cell.clipsToBounds = NO;
//  if ([self.myReservations count] == 0) {
//    cell.boatName.text = @"No reservations";
//    return cell;
//  }
//  Reservation *reservation = [self.myReservations objectAtIndex:indexPath.row];
//  cell.boatName.text = reservation.boat_name;
//  cell.reservationStart.text = reservation.start_date_time;
//  cell.reservationEnd.text = reservation.end_date_time;
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(self.view.frame.size.width-32, 127);
}

@end
