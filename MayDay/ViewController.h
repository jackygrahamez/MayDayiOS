//
//  ViewController.h
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate> {
    IBOutlet UILabel *label;
    IBOutlet UITextView *message;
    IBOutlet UITextField *firstNumber;
    IBOutlet UIPickerView *picker;
    IBOutlet UITextField *contact1;
    IBOutlet UITextField *contact2;
    IBOutlet UITextField *contact3;
    CLLocationManager *locationManager;
}
-(IBAction)saveMessage:(id)sender;
-(IBAction)saveContact:(id)sender;
-(IBAction)controlTextDidChange:(id)sender;
-(IBAction)trigger:(id)sender;

@property (nonatomic, retain) CLLocationManager *locationManager;

@end

