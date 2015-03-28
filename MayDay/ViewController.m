//
//  ViewController.m
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import "ViewController.h"

// Your global variable definition.
NSInteger startTimeSeconds = 0;
NSInteger triggerCount = 0;
NSDate *startDateObj = nil;
ViewController *masterViewController;


@interface ViewController ()
{
    NSArray *_pickerData;
    UISwipeGestureRecognizer *swipeLeftToRightGesture;
}
@end

@interface UINavigationController(indexPoping)
- (void)popToViewControllerAtIndex:(NSInteger)newVCsIndex animated:(BOOL)animated;
@end

@implementation UINavigationController(indexPoping)
- (void)popToViewControllerAtIndex:(NSInteger)newVCsIndex animated:(BOOL)useAnimation
{
    if (newVCsIndex < [self.viewControllers count]) {
        [self popToViewController:[self.viewControllers objectAtIndex:newVCsIndex] animated:useAnimation];
    }
    
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
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
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveInterval:(id)sender {
    int row = [self.messageIntervalPicker selectedRowInComponent:0];
    NSLog(@"value at index %i %@", row, [_pickerData objectAtIndex:row]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* interval = [NSString stringWithFormat:@"%i", row];
    [defaults setObject:interval forKey:@"interval"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    masterViewController = self;
    //[self keepAlive];
    
    swipeLeftToRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipedScreenRight:)];
    [swipeLeftToRightGesture setNumberOfTouchesRequired: 1];
    [swipeLeftToRightGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer: swipeLeftToRightGesture];
    
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
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.iokit.hid.displayStatus"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)trigger:(id)sender
{
    [self sendMessage];
    [self startTimer];
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
    NSInteger row = 4;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *interval = [defaults objectForKey:@"interval"];
    if(interval != nil){
        row = [interval integerValue];
    }
    //This is how you manually SET(!!) a selection!
    [self.messageIntervalPicker selectRow:row inComponent:0 animated:YES];
}

- (void)swipedScreenRight:(UISwipeGestureRecognizer*)swipeGesture
{
    NSLog(@"swipedScreenRight");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) sendMessage
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
    
    //Need to get a CA Certificate for the server
    NSURL *someURLSetBefore = [NSURL URLWithString:@"http://maydaysos.net/messaging"];
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

- (void) startTimer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *interval = [defaults objectForKey:@"interval"];
    NSString *alerting = @"true";
    [defaults setObject:alerting forKey:@"alerting"];
    double i = ([interval doubleValue] + 1) * 60;
    NSLog(@"interval %f",i);
    autoTimer = [NSTimer scheduledTimerWithTimeInterval:i
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
    
}
- (IBAction)stopAlerting:(id)sender {
    [autoTimer invalidate];
    autoTimer = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"alerting"];
}

- (void) tick:(NSTimer *) timer {
    //do something here..
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *alerting = [defaults objectForKey:@"alerting"];
    if (alerting) {
    NSLog(@"sendMessage");
    [self sendMessage];
    }
}

static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    NSLog(@"event received!");
    NSDate *currentDateObj = [NSDate date];

    if (startDateObj != nil) {
        NSTimeInterval interval = [currentDateObj timeIntervalSinceDate:startDateObj];
        if (interval<10) {
            triggerCount++;
            NSLog (@"press number %i first press was %.0f seconds ago", triggerCount, interval);
            if (triggerCount >= 5) {
                NSLog(@"triggering MayDay Alert");
                [masterViewController sendMessage];
                [masterViewController startTimer];
                startDateObj = nil;
                triggerCount = 0;
            }
            
        } else {
            NSLog(@"reset trigger");
            startDateObj = nil;
            triggerCount = 0;
        }
    } else {
         NSLog (@"first button press");
        startDateObj = [NSDate date];
    }
    

    // you might try inspecting the `userInfo` dictionary, to see
    //  if it contains any useful info
    if (userInfo != nil) {
        CFShow(userInfo);
    }
    
}

- (void) keepAlive {
    
    UIApplication * application = [UIApplication sharedApplication];
    
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        NSLog(@"Multitasking Supported");
        
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            NSLog(@"Ending timer");
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
            [self keepAlive];
        }];
        
        //To make the code block asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //### background task starts
            NSLog(@"Running in the background\n");
            while(TRUE)
            {
                NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
                [NSThread sleepForTimeInterval:1]; //wait for 1 sec
            }
            //#### background task ends
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        });
    }
    else
    {
        NSLog(@"Multitasking Not Supported");
    }
}

@end
