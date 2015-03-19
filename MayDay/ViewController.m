//
//  ViewController.m
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
-(IBAction)saveMessage:(id)sender
{
    NSString *savestring = message.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:savestring forKey:@"messagestring"];
    [defaults synchronize];
}
-(IBAction)saveContact:(id)sender
{
    NSLog(@"saveContact");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *savestring1 = contact1.text;
    [defaults setObject:savestring1 forKey:@"contact1string"];
    NSString *savestring2 = contact2.text;
    [defaults setObject:savestring2 forKey:@"contact2string"];
    NSString *savestring3 = contact3.text;
    [defaults setObject:savestring3 forKey:@"contact3string"];
    NSLog(@"%@,%@,%@",savestring1,savestring2,savestring3);
    
    [defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadstring = [defaults objectForKey:@"messagestring"];
    [message setText:loadstring];
    contact1.keyboardType = UIKeyboardTypeNumberPad;
    contact2.keyboardType = UIKeyboardTypeNumberPad;
    contact3.keyboardType = UIKeyboardTypeNumberPad;
    NSString *first = [defaults objectForKey:@"contact1string"];
    NSString *second = [defaults objectForKey:@"contact2string"];
    NSString *third = [defaults objectForKey:@"contact3string"];
    NSLog(@"%@,%@,%@",first,second,third);
    [message setText:loadstring];
    [contact1 setText:first];
    [contact2 setText:second];
    [contact3 setText:third];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
     //NSArray *_pickerData = @[@"1 min", @"2 min", @"3 min", @"4 min", @"5 min", @"6 min", @"7 min"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Make sure the user has typed a valid number so far.
-(IBAction)controlTextDidChange:(id)sender
{
    /*
    if (obj.object == self->firstNumber)
    {
        NSString *countValue = firstNumber.stringValue;
        
        if ([countValue length] > 0) {
            
            if ([[countValue substringFromIndex:[countValue length]-1] integerValue] > 0 ||
                [[countValue substringFromIndex:[countValue length]-1] isEqualToString:@"0"])
            {
                self.lastNumber = firstNumber.stringValue;
            }
            else
            {
                firstNumber.stringValue = self.lastNumber;
                NSBeep();
            }
        }

    }
    */
}
-(IBAction)trigger:(id)sender
{
    NSString *message = @"Test Message";
    NSString *number = @"2024941707";
    //[[CTMessageCenter sharedMessageCenter]  sendSMSWithText:message serviceCenter:nil toAddress:number];

}

-(void)dismissKeyboard {
    [message resignFirstResponder];
    [contact1 resignFirstResponder];
    [contact2 resignFirstResponder];
    [contact3 resignFirstResponder];
}

@end
