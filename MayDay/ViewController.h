//
//  ViewController.h
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface UINavigationController(indexPoping) {
    
}
@property NSInteger *newVCsIndex;
@end
@interface ViewController : UIViewController<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, ABPeoplePickerNavigationControllerDelegate> {
    IBOutlet UILabel *label;
    IBOutlet UITextView *message;
    IBOutlet UITextField *firstNumber;
    IBOutlet UIPickerView *picker;
    IBOutlet UITextField *contact1;
    IBOutlet UITextField *contact2;
    IBOutlet UITextField *contact3;
    CLLocationManager *locationManager;
    NSTimer *autoTimer;
    NSInteger startTimeSeconds;
    NSDate *startDateObj;
    
    __weak IBOutlet UILabel *status;
    __weak IBOutlet UILabel *homeReadyCopy;
    __weak IBOutlet UIButton *settingsButton;
    __weak IBOutlet UIButton *aboutButton;
    __weak IBOutlet UIView *settingsBorder;
    __weak IBOutlet UIView *aboutBorder;
    __weak IBOutlet UILabel *alertingText;
    __weak IBOutlet UIButton *stopAlertingButton;
}
@property (weak, nonatomic) IBOutlet UIButton *contactPicker1;
@property (weak, nonatomic) IBOutlet UIButton *contactPicker2;
@property (weak, nonatomic) IBOutlet UIButton *contactPicker3;


-(IBAction)saveMessage:(id)sender;
-(IBAction)saveContact:(id)sender;
-(IBAction)saveInterval:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *stopAlerting;

-(IBAction)controlTextDidChange:(id)sender;
-(IBAction)trigger:(id)sender;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIPickerView *messageIntervalPicker;

@property (weak, nonatomic) UINavigationController *navigationBar;

@end

@interface PickerObject : NSObject
{
    
}
//@property (nonatomic, strong) int *minutes;
//@property (nonatomic, strong) NSString *label;

@end