//
//  AppDelegate.m
//  textsosalert
//
//  Created by John Shultz on 7/19/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    #if DEBUG
        [ZeroPush engageWithAPIKey:@"iosdev_apptoken" delegate:self];
    #else
        [ZeroPush engageWithAPIKey:@"iosprod_apptoken" delegate:self];
    #endif
    //Ask users to recieve push notifications.
    //You can place this in another part of your app.
    [[ZeroPush shared] registerForRemoteNotifications];
    // Override point for customization after application launch.
    
    // Override point for customization after application launch.
    if (![CLLocationManager locationServicesEnabled]) {
        // location services is disabled, alert user
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    [Fabric with:@[CrashlyticsKit]];
    BOOL setupCompletedBool = false,
    SettingsShowTutorialOnLaunchBool = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *setupCompleted = [defaults objectForKey:@"setupcompleted"],
    *SettingsShowTutorialOnLaunch = [defaults objectForKey:@"SettingsShowTutorialOnLaunch"];
    
    NSLog(@"SettingsShowTutorialOnLaunch %@", SettingsShowTutorialOnLaunch);
    
    setupCompletedBool = [setupCompleted boolValue];
    if(!setupCompletedBool || [[NSUserDefaults standardUserDefaults] boolForKey:@"SettingsShowTutorialOnLaunch"]) {
        //self.window.rootViewController = (UIViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"setupNavigation"];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenData
{
    [[ZeroPush shared] registerDeviceToken:tokenData];
    
    //This would be a good time to save the token and associate it with a user that you want to notify later.
    NSString *tokenString = [ZeroPush deviceTokenFromData:tokenData];
    NSLog(@"%@", tokenString);
    
    // For instance you can associate it with a user's email address
    // [[ZeroPush shared] subscribeToChannel:@"user@example.com"];
    // You can then use the /broadcast endpoint to notify all devices subscribed to that email address. No need to save tokens!
    // Don't forget to unsubscribe from the channel when the user logs out of your app!
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", [error description]);
    //Common reason for errors:
    //  1.) Simulator does not support receiving push notifications
    //  2.) User rejected push alert
    //  3.) "no valid 'aps-environment' entitlement string found for application"
    //      This means your provisioning profile does not have Push Notifications configured. https://zeropush.com/documentation/generating_certificates
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"App delegate applicationDidBecomeActive");
    
    BOOL alertingBool = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *alerting = [defaults objectForKey:@"altering"];
    alertingBool = [alerting boolValue];
    if (alertingBool) {
        NSLog(@"alertingBool true");
        self.window.rootViewController =
        (UIViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"homeAlertingView"];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mayday.md.MayDay" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MayDay" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MayDay.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply{
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"Hello"]) {
        
        NSLog(@"containing app received message from watch");
        NSLog(@"applicationDidBecomeActive");
        BOOL alertingBool = false;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *alerting = [defaults objectForKey:@"altering"];
        alertingBool = [alerting boolValue];
        if (alertingBool) {
            NSLog(@"alertingBool true");
            self.window.rootViewController =
            (UIViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"homeAlertingView"];
        } else {
            NSLog(@"alertingBool false");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"watchTrigger" object:nil];
        }
        
        
        NSDictionary *response = @{@"response" : @"Watchkit"};
        reply(response);
    }
    
}

@end
