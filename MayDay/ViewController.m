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
    //Grab Saved Data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *message = [defaults objectForKey:@"messagestring"];
    NSString *first = [defaults objectForKey:@"contact1string"];
    NSString *second = [defaults objectForKey:@"contact2string"];
    NSString *third = [defaults objectForKey:@"contact3string"];
    
    //Validation INFO
    //May need to implement JSON Token Authentication
    //EXAMPLE #1 http://www.sitepoint.com/using-json-web-tokens-node-js/
    //EXAMPLE #2 https://github.com/auth0/node-jsonwebtoken
    NSString *password = @"123456";
    //NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *adId = @"PLACEHOLDER";
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSURL *someURLSetBefore = [NSURL URLWithString:@"http://localhost:3000/messaging"];
    NSLog(@"someURLSetBefore %@",someURLSetBefore);
    NSLog(@"message %@", message);
    
    
    //[[CTMessageCenter sharedMessageCenter]  sendSMSWithText:message serviceCenter:nil toAddress:number];
    //build an info object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:password, @"password", adId, @"adId", idfv, @"idfv", nil];
    
    //convert object to data
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:someURLSetBefore];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[connection start];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         NSLog(@"error: %@", error);
         NSLog(@"data: %@", data);
         NSLog(@"response: %@", response);

         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         if ([data length] >0 && error == nil && [httpResponse statusCode] == 200)
         {
         NSLog(@"dataAsString %@", [NSString stringWithUTF8String:[data bytes]]);
             // DO YOUR WORK HERE
             NSError *error1;
             NSMutableDictionary * innerJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error1];
             NSLog(@"error1 %@", error1);
             NSLog(@"allKeys");
             for( NSString *aKey in [innerJson allKeys] )
             {
                 // do something like a log:
                 NSLog(@"aKey %@",aKey);
             }
             if ([innerJson objectForKey:@"sent"]) {
                 // contains key
                 NSLog(@"Result for sent is %@", [innerJson objectForKey:@"sent"]);
                 if ([innerJson objectForKey:@"sent"]) {
                     NSLog(@"message sent");
                 } else {
                     NSLog(@"message not sent");
                 }
                 
             } else {
                 NSLog(@"Server unavailable");
             }
         }
         
     }];


}

-(void)dismissKeyboard {
    [message resignFirstResponder];
    [contact1 resignFirstResponder];
    [contact2 resignFirstResponder];
    [contact3 resignFirstResponder];
}

@end
