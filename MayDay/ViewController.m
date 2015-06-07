//
//  ViewController.m
//  MayDay
//
//  Created by John Shultz on 3/1/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import "ViewController.h"
#import "AudioToolbox/AudioServices.h"
#import <AddressBookUI/AddressBookUI.h>
#import <StoreKit/StoreKit.h>


NSUserDefaults *defaults;
// Your global variable definition.
NSInteger startTimeSeconds = 0,
        triggerCount = 0,
        contactField = 1,
        balanceInt = 10;
NSDate *startDateObj = nil;
ViewController *masterViewController;
NSString *message, *first, *second, *third, *balanceString, *appSandboxString = @"1!Sbx-qe";
NSArray *contacts;
BOOL alerting = false;


@interface ViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
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

/*
 * START IN-APP PURCHASE
 */
#define kRemoveAdsProductIdentifier @"merchant.com.textsosalert.buyfifty"

- (void)tapsBuyFifty{
    NSLog(@"User requests to buy 50 text messages");

    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        NSString *promocodeString = promocode.text;
        if ([appSandboxString isEqualToString:promocodeString]) {
            NSString *purchaseDialogMessage = @"Do you want to buy 50 text messages for $0.99?\n\n[Environment: Sandbox]";
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Confirm Your In-App Purchase"
                                  message:purchaseDialogMessage
                                  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy",nil];
            alert.tag = 100;
            [alert show];
        } else {
            SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:
[NSSet setWithObject:kRemoveAdsProductIdentifier]];
            productsRequest.delegate = self;
            [productsRequest start];
        }

    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (IBAction)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (IBAction) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");

            [self addFiftyMessages];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self addFiftyMessages]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

-(void)addFiftyMessages
{
    balanceInt = balanceInt + 50;
    balanceInt--;
    NSString *balanceUpdate = [@(balanceInt) stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:balanceUpdate forKey:@"balance"];
    [defaults synchronize];
    UINavigationController *navigationController = self.navigationController;
    [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
}

/*
 * END IN-APP PURCHASE
 */


- (IBAction)buyFiftyMessages:(id)sender {

    NSString *promocodeString = promocode.text;
    NSString *purchaseDialogMessage = @"Do you want to buy 50 text messages for $0.99?";
    if ([appSandboxString isEqualToString:promocodeString]) {
        purchaseDialogMessage = @"Do you want to buy 50 text messages for $0.99?\n\n[Environment: Sandbox]";
    }

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Confirm Your In-App Purchase"
                          message:purchaseDialogMessage
                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy",nil];
    alert.tag = 100;
    [alert show];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{


    // Is this my Alert View?
    if (alertView.tag == 100) {
        //Yes


        // You need to compare 'buttonIndex' & 0 to other value(1,2,3) if u have more buttons.
        // Then u can check which button was pressed.
        if (buttonIndex == 0) {// 1st Other Button

            NSLog(@"buttonIndex 0");

        }
        else if (buttonIndex == 1) {// 2nd Other Button

            NSLog(@"buttonIndex 1");
            balanceInt = balanceInt + 50;
            balanceInt--;
            NSString *balanceUpdate = [@(balanceInt) stringValue];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:balanceUpdate forKey:@"balance"];
            [defaults synchronize];
            UINavigationController *navigationController = self.navigationController;
            [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
        }

    }
    else {
        //No
        // Other Alert View

    }

}

- (IBAction)contact1SetupField:(id)sender {

    if (contact1SetupField.text.length > 3) {
        NSLog(@"length > 3");
        masterViewController.saveContactsNext.alpha = 1.0;
        masterViewController.saveContactsNext.enabled = YES;
        masterViewController.saveContactsNext.userInteractionEnabled = YES;
    }
}

-(IBAction)saveMessage:(id)sender
{
    NSString *savestring = message.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:savestring forKey:@"messagestring"];
    [defaults synchronize];
    //[masterViewController.navigationController popViewControllerAnimated:YES];
    UINavigationController *navigationController = self.navigationController;
    [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
}
- (IBAction)saveMessageNext:(id)sender {
    NSString *savestring = message.text;
    NSString *setupCompleted = @"true";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:savestring forKey:@"messagestring"];
    [defaults setObject:setupCompleted forKey:@"setupcompleted"];
    [defaults synchronize];
    [masterViewController setupLocalNotifications];
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
    //[masterViewController.navigationController popViewControllerAnimated:YES];
    UINavigationController *navigationController = self.navigationController;
    [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
}
- (IBAction)saveContactsNext:(id)sender {
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
    int row = [masterViewController.messageIntervalPicker selectedRowInComponent:0];
    NSLog(@"value at index %i %@", row, [_pickerData objectAtIndex:row]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* interval = [NSString stringWithFormat:@"%i", row];
    [defaults setObject:interval forKey:@"interval"];
    //[masterViewController.navigationController popViewControllerAnimated:YES];
    UINavigationController *navigationController = self.navigationController;
    [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
}
- (IBAction)stopAlerting:(id)sender {
    NSLog(@"Stop Alerting");
    [autoTimer invalidate];
    autoTimer = nil;
    alerting = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"alerting"];
    [defaults synchronize];
    //[masterViewController hideAlerting];
    self.view.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
    //self.window.rootViewController =
    //(UIViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"homeView"];

}

- (IBAction)contactPicker1:(id)sender {
    NSLog(@"contactPicker1");
    contactField = 1;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = masterViewController;
    [masterViewController presentModalViewController:picker animated:YES];
}
- (IBAction)contactPicker2:(id)sender {
    NSLog(@"contactPicker2");
    contactField = 2;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = masterViewController;
    [masterViewController presentModalViewController:picker animated:YES];
}
- (IBAction)contactPicker3:(id)sender {
    NSLog(@"contactPicker3");
    contactField = 3;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = masterViewController;
    [masterViewController presentModalViewController:picker animated:YES];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [masterViewController dismissModalViewControllerAnimated:YES];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    NSLog(@"Went here 1 ...");

    [masterViewController peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    [masterViewController displayPerson:person];
    [masterViewController dismissModalViewControllerAnimated:YES];

    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    NSLog(@"displayPerson");
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    //masterViewController.firstName.text = name;
    //contact1.text = name;

    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        masterViewController.saveContactsNext.alpha = 1.0;
        masterViewController.saveContactsNext.enabled = YES;
        masterViewController.saveContactsNext.userInteractionEnabled = YES;
    } else {
        phone = @"[None]";
    }
    //masterViewController.phoneNumber.text = phone;
    NSLog(@"phone %@",phone);
    if (contactField == 1) {
        contact1.text = phone;
    }
    if (contactField == 2) {
        contact2.text = phone;
    }
    if (contactField == 3) {
        contact3.text = phone;
    }


    CFRelease(phoneNumbers);
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
}

-(void)swipeInit
{
    swipeLeftToRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipedScreenRight:)];
    [swipeLeftToRightGesture setNumberOfTouchesRequired: 1];
    [swipeLeftToRightGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    [[masterViewController view] addGestureRecognizer: swipeLeftToRightGesture];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [masterViewController.view addGestureRecognizer:tap];
}

-(void)intervalPickerInit
{
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
    masterViewController.messageIntervalPicker.dataSource = self;
    masterViewController.messageIntervalPicker.delegate = self;
}

- (void)initLocationManager
{


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

    //[masterViewController.locationManager requestWhenInUseAuthorization];
    [masterViewController.locationManager requestAlwaysAuthorization];
    [masterViewController.locationManager startUpdatingLocation];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.iokit.hid.displayStatus"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}


- (void)viewDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"view applicationDidBecomeActive");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    masterViewController = self;
    [masterViewController swipeInit];
    [masterViewController intervalPickerInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchTrigger:) name:@"watchTrigger" object:nil];

    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadstring = [defaults objectForKey:@"messagestring"];
    balanceString = [defaults objectForKey:@"balance"];

    if (balanceString) {
        NSLog(@"balanceString %@", balanceString);
        balanceInt = [balanceString intValue];
        balanceString = [NSString stringWithFormat: @"Balance: %@", balanceString];
        [balance setText:balanceString];
    }

    [message setText:loadstring];

    masterViewController.saveContactsNext.alpha = 0.50;
    masterViewController.saveContactsNext.enabled = NO;
    masterViewController.saveContactsNext.userInteractionEnabled = NO;

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
    if (contact1.text.length > 0 ||
        contact2.text.length > 0 |
        contact3.text.length > 0) {
        masterViewController.saveContactsNext.alpha = 1.0;
        masterViewController.saveContactsNext.enabled = YES;
        masterViewController.saveContactsNext.userInteractionEnabled = YES;
    }

    [masterViewController initLocationManager];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    NSString *restorationId = self.restorationIdentifier;
    if ([restorationId  isEqual: @"homeView"]) {
        NSLog(@"homeView");
    }

    [masterViewController animate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    /*
    [message resignFirstResponder];
    [contact1 resignFirstResponder];
    [contact2 resignFirstResponder];
    [contact3 resignFirstResponder];
     */
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
    [masterViewController.messageIntervalPicker selectRow:row inComponent:0 animated:YES];
}

- (void)setupLocalNotifications {

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // current time plus 10 secs
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:5];
    
    NSLog(@"Text SOS Installed: %@", now);
    
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = @"Text SOS Installed";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1; // increment
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)sendLocalNotifications {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // current time plus 10 secs
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:5];
    
    NSLog(@"Alerting your emergency contacts: %@", now);
    
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = @"Alerting your emergency contacts";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1; // increment
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (void)swipedScreenRight:(UISwipeGestureRecognizer*)swipeGesture
{
    NSString *restorationId = self.restorationIdentifier;

    NSLog(@"swipedScreenRight %@", restorationId);
    if ([restorationId  isEqual: @"messageSettings"]) {
        UINavigationController *navigationController = self.navigationController;
        [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    } else if ([restorationId  isEqual: @"contactSettings"]) {
        UINavigationController *navigationController = self.navigationController;
        [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    } else if ([restorationId  isEqual: @"alertSettings"]) {
        UINavigationController *navigationController = self.navigationController;
        [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeView"]] animated:NO];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        NSLog(@"%@",self.navigationController.viewControllers);
        [masterViewController.navigationController popViewControllerAnimated:YES];
    }


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


    [masterViewController initData];

    //Validation INFO
    //May need to implement JSON Token Authentication
    //EXAMPLE #1 http://www.sitepoint.com/using-json-web-tokens-node-js/
    //EXAMPLE #2 https://github.com/auth0/node-jsonwebtoken
    NSString *password = @"123456";
    //NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *adId = @"PLACEHOLDER";
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *debug = @"false";

    //Need to get a CA Certificate for the server
    NSURL *someURLSetBefore = [NSURL URLWithString:@"https://textsosalert.com/messaging"];
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
                     [masterViewController vibrate];
                     [masterViewController sendLocalNotifications];
                     balanceInt--;
                     NSString *balanceUpdate = [@(balanceInt) stringValue];
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setObject:balanceUpdate forKey:@"balance"];
                     [defaults synchronize];

                     //[masterViewController showAlerting];
                     self.view.window.rootViewController = [self.storyboard
                                                            instantiateViewControllerWithIdentifier:@"homeAlertingView"];
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

- (void) initData
{
    //Grab Saved Data
    defaults = [NSUserDefaults standardUserDefaults];
    message = [defaults objectForKey:@"messagestring"];
    first = [defaults objectForKey:@"contact1string"];
    first = [[first componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];

    second = [defaults objectForKey:@"contact2string"];
    second = [[second componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];

    third = [defaults objectForKey:@"contact3string"];
    third = [[third componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];

    contacts = [NSArray arrayWithObjects:first,second,third,nil];
}

- (void) startTimer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *interval = [defaults objectForKey:@"interval"];
    NSString *alerting = @"true";
    [defaults setObject:alerting forKey:@"alerting"];
    [defaults synchronize];
    double i = ([interval doubleValue] + 1) * 60;
    NSLog(@"interval %f",i);
    autoTimer = [NSTimer scheduledTimerWithTimeInterval:i
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];

}


- (void) tick:(NSTimer *) timer {
    //do something here..
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *alerting = [defaults objectForKey:@"alerting"];
    if (alerting) {
    NSLog(@"sendMessage");
    [masterViewController sendMessage];
    }
}

static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

    NSLog(@"event received!");

    [masterViewController powerButtonTrigger];

    // you might try inspecting the `userInfo` dictionary, to see
    //  if it contains any useful info
    if (userInfo != nil) {
        CFShow(userInfo);
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlerting"])
    {
        NSLog(@"Logging showAlerting");
    }
}

- (void) showAlerting
{
    status.text = @"Alerting!";

    status.textColor = [UIColor colorWithRed:0.988 green:0.176 blue:0.176 alpha:1];
    homeReadyCopy.hidden=true;
    settingsButton.hidden=true;
    aboutButton.hidden=true;
    settingsButton.hidden=true;
    settingsBorder.hidden=true;
    aboutButton.hidden=true;
    aboutBorder.hidden=true;

    alertingText.hidden=false;
    stopAlertingButton.hidden=false;
}

- (void) hideAlerting
{
    status.text = @"Ready!";
    status.textColor = [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
    homeReadyCopy.hidden=false;
    settingsButton.hidden=false;
    aboutButton.hidden=false;
    settingsButton.hidden=false;
    settingsBorder.hidden=false;
    aboutButton.hidden=false;
    aboutBorder.hidden=false;

    alertingText.hidden=true;
    stopAlertingButton.hidden=true;
}

- (void) powerButtonTrigger
{
    NSLog (@"powerButtonTrigger");
    if (alerting == false) {
        NSDate *currentDateObj = [NSDate date];

        if (startDateObj != nil) {
            NSTimeInterval interval = [currentDateObj timeIntervalSinceDate:startDateObj];
            if (interval<10) {
                if (interval > 2) {
                    triggerCount++;
                    NSLog (@"press number %i first press was %.0f seconds ago", triggerCount, interval);
                    if (triggerCount >= 5 ) {
                        NSLog(@"triggering MayDay Alert");
                        [masterViewController sendMessage];
                        [masterViewController startTimer];
                        startDateObj = nil;
                        triggerCount = 0;
                        alerting = true;
                        //[masterViewController showAlerting];
                        self.view.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeAlertingView"];
                    }
                }
            } else {
                NSLog(@"reset trigger");
                startDateObj = nil;
                triggerCount = 0;
            }
        } else {
            NSLog (@"first button press");
            startDateObj = [NSDate date];
            triggerCount = 0;
        }
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
            [masterViewController keepAlive];
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

-(void)vibrate
{
    NSLog(@"I'm vibrating");
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //AudioServicesPlaySystemSound(1103);
}

-(void) animate
{
    NSLog(@"Animate");
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        /* what to do next */
        [pickerCircle setHidden:YES];

    }];
    /* your animation code */
    CGPoint startPoint = [pickerCircle center];
    CGPoint endPoint = [pickerButton1 center];

    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathMoveToPoint(thePath, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(thePath, NULL, endPoint.x, endPoint.y);

    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"position"];
    animation.duration = 2.f;
    animation.path = thePath;
    animation.repeatCount = 2;
    animation.removedOnCompletion = YES;


    [pickerCircle.layer addAnimation:animation forKey:@"position"];
    pickerCircle.layer.position = endPoint;
    [CATransaction commit];

}

- (void)watchTrigger:(NSNotification *)notification
{
    NSLog(@"refreshView");
    //[masterViewController powerButtonTrigger];
}

- (IBAction)triggerButton:(id)sender {
    [masterViewController powerButtonTrigger];
}

@end
