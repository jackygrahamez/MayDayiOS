//
//  DetailViewController.h
//  MayDay
//
//  Created by John Shultz on 3/22/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;


@end
