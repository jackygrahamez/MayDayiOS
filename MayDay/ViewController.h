//
//  ViewController.h
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    IBOutlet UILabel *label;
    IBOutlet UITextView *message;
    IBOutlet UITextField *firstNumber;
    IBOutlet UIPickerView *picker;
    IBOutlet UITextField *contact1;
    IBOutlet UITextField *contact2;
    IBOutlet UITextField *contact3;
}
-(IBAction)saveMessage:(id)sender;
-(IBAction)saveContact:(id)sender;
-(IBAction)controlTextDidChange:(id)sender;

@end

