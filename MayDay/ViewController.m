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
    NSString *savestring1 = contact1.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:savestring1 forKey:@"contact1string"];
    [defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadstring = [defaults objectForKey:@"messagestring"];
    [message setText:loadstring];
    NSString *first = [defaults objectForKey:@"contact1string"];
    [message setText:loadstring];
    [contact1 setText:first];
    
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
@end
