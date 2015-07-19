//
//  InterfaceController.m
//  MayDay WatchKit Extension
//
//  Created by John Shultz on 3/7/15.
//  Copyright (c) 2015 John Shultz. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *label;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *btn;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSLog(@"awakeWithContext!");
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSLog(@"willActivate!");
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    NSLog(@"didDeactivate!");
}

- (IBAction)alarmPressed:(id)sender
{
    NSLog(@"alarmPressed!");
    NSDictionary *requst = @{@"request":@"Hello"};
    
    [InterfaceController openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            [self.label setText:[replyInfo objectForKey:@"response"]];
        }
        
    }];
}

@end



