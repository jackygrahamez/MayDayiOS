//
//  ViewController.m
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSArray *_pickerData;
}
@end

@implementation ViewController

#pragma mark - Properties

@synthesize locationManager;

#pragma mark - Methods

#pragma mark - View lifecycle

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

- (IBAction)saveInterval:(id)sender {
    int row = [self.messageIntervalPicker selectedRowInComponent:0];
    NSLog(@"value at index %i %@", row, [_pickerData objectAtIndex:row]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* interval = [NSString stringWithFormat:@"%i", row];
    [defaults setObject:interval forKey:@"interval"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    int total = 121;
    
    NSMutableArray *minutes = [[NSMutableArray alloc] init];
    NSMutableArray *label = [[NSMutableArray alloc] init];
    for(int x = 1; x < total; x++)
    {
        NSString* min = [NSString stringWithFormat:@"%i minutes", x];
        //[_pickerData addObject:[NSNumber numberWithInt:x]];
        [minutes addObject:[NSNumber numberWithInt:x]];
        [label addObject:[NSString stringWithString:min]];
    }
    _pickerData = label;
    
    // Connect data
    self.messageIntervalPicker.dataSource = self;
    self.messageIntervalPicker.delegate = self;
    
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
    
    //Location Manager
    
    locationManager = [[CLLocationManager alloc] init];
    
    [locationManager startUpdatingLocation];
    NSLog(@" lat: %f",locationManager.location.coordinate.latitude);
    NSLog(@" lon: %f",locationManager.location.coordinate.longitude);
    
    [locationManager stopUpdatingLocation];
    
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy =
        kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
    }
    
    //[self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
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
    //Get GPS Location
    // 1. Get the current location
    
    CLLocation *curPos = locationManager.location;
    
    NSString *latitude = [[NSNumber numberWithDouble:curPos.coordinate.latitude] stringValue];
    
    NSString *longitude = [[NSNumber numberWithDouble:curPos.coordinate.longitude] stringValue];
    
    NSLog(@"Lat: %@", latitude);
    NSLog(@"Long: %@", longitude);
    
    
    //Grab Saved Data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *message = [defaults objectForKey:@"messagestring"];
    NSString *first = [defaults objectForKey:@"contact1string"];
    NSString *second = [defaults objectForKey:@"contact2string"];
    NSString *third = [defaults objectForKey:@"contact3string"];
    //NSArray *contacts = @[first, second, third];
    NSArray *contacts = [NSArray arrayWithObjects:first,second,third,nil];

    
    //Validation INFO
    //May need to implement JSON Token Authentication
    //EXAMPLE #1 http://www.sitepoint.com/using-json-web-tokens-node-js/
    //EXAMPLE #2 https://github.com/auth0/node-jsonwebtoken
    NSString *password = @"123456";
    //NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *adId = @"PLACEHOLDER";
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSURL *someURLSetBefore = [NSURL URLWithString:@"http://localhost:3000/messaging"];
    //NSLog(@"someURLSetBefore %@",someURLSetBefore);
    //NSString *messageWithGPS = @"%@ test", *message;

    NSString *messageWithGPS = @"";
    NSString *messageWithoutGPS = @"";
    
    //Check if GPS is working
    if (latitude != 0 && longitude != 0) {
        messageWithGPS = [NSString stringWithFormat:@"%@ I'm here https://maps.google.com/maps?1=%@,%@ via gps", message, latitude, longitude];
        message = messageWithGPS;
    } else {
        messageWithoutGPS = [NSString stringWithFormat:@"%@", message];
        message = messageWithoutGPS;
    }
    
    NSLog(@"messageWithGPS %@", messageWithGPS);

    NSArray *loc = @[longitude, latitude];
    
    //[[CTMessageCenter sharedMessageCenter]  sendSMSWithText:message serviceCenter:nil toAddress:number];
    //build an info object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    contacts, @"contacts",
                                    message, @"message",
                                    loc, @"loc",
                                    password, @"password",
                                    adId, @"adId",
                                    idfv, @"idfv", nil];
    
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
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
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
                 NSString* sent = (NSString*)[innerJson objectForKey:@"sent"];
                 NSLog(@"Result for sent is %@", sent);
                 if ([sent isEqualToString:@"true"]) {
                     NSLog(@"message sent");
                 } else {
                     NSLog(@"message not sent");
                     UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"Too Many Messages"
                                           message:@"MayDay is meant for emergencies only. If you wish to continue using, uninstall and reinstall"
                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
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


// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *interval = [defaults objectForKey:@"interval"];
    NSInteger row = [interval integerValue];
    
    //This is how you manually SET(!!) a selection!
    [self.messageIntervalPicker selectRow:row inComponent:0 animated:YES];
}


@end
