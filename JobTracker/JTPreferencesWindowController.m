//
//  JTPreferencesWindowController.m
//  JobTracker
//
//  Created by Brad Greenlee on 11/11/12.
//  Copyright (c) 2012 Hack Arts. All rights reserved.
//

#import "JTPreferencesWindowController.h"
#import "LaunchAtLoginController.h"

@interface JTPreferencesWindowController ()

@end

@implementation JTPreferencesWindowController

@synthesize jobTrackerURLCell, usernamesCell, refreshIntervalCell, startingJobNotificationPreference,
    completedJobNotificationPreference, failedJobNotificationPreference, launchAtLoginPreference,
    okayButton, cancelButton, delegate;

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self loadCurrentSettings];
    [[self window] center];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)loadCurrentSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *usernames = [defaults stringForKey:@"usernames"];
    if (usernames != nil) {
        [self.usernamesCell setStringValue:usernames];
    }

    NSInteger refreshInterval = [defaults integerForKey:@"refreshInterval"];
    if (refreshInterval == 0) {
        refreshInterval = DEFAULT_REFRESH_INTERVAL;
    }
    [self.refreshIntervalCell setIntegerValue:refreshInterval];
    
    // this replace just fixes the url generated by an earlier version and can eventually be removed
    NSString *jobTrackerURL = [[defaults stringForKey:@"jobTrackerURL"] stringByReplacingOccurrencesOfString:@"/jobtracker.jsp" withString:@""];
    if (jobTrackerURL != nil) {
        [self.jobTrackerURLCell setStringValue:jobTrackerURL];
    }
    
    [self.startingJobNotificationPreference setState:[defaults boolForKey:@"startingJobNotificationsEnabled"] ? NSOnState : NSOffState];
    [self.completedJobNotificationPreference setState:[defaults boolForKey:@"completedJobNotificationsEnabled"] ? NSOnState : NSOffState];
    [self.failedJobNotificationPreference setState:[defaults boolForKey:@"failedJobNotificationsEnabled"] ? NSOnState : NSOffState];

    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launchAtLoginEnabled = [launchController launchAtLogin];
    
    if (launchAtLoginEnabled) {
        [self.launchAtLoginPreference setState:NSOnState];
    } else {
        [self.launchAtLoginPreference setState:NSOffState];
    }    
}

- (IBAction)okayPressed:(id)sender {
    NSString *jobTrackerURL = [[self.jobTrackerURLCell stringValue] stringByReplacingOccurrencesOfString:@"/jobtracker.jsp" withString:@""];
    NSString *usernames = [[self.usernamesCell stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSInteger refreshInterval = [self.refreshIntervalCell integerValue];
    if (refreshInterval < 1) {
        refreshInterval = 1;
    }
    BOOL startingJobNotificationsEnabled = [self.startingJobNotificationPreference state] == NSOnState;
    BOOL completedJobNotificationsEnabled = [self.completedJobNotificationPreference state] == NSOnState;
    BOOL failedJobNotificationsEnabled = [self.failedJobNotificationPreference state] == NSOnState;
    BOOL launchOnLoginEnabled = [self.launchAtLoginPreference state] == NSOnState;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Save the Launch-on-Login preference.
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	[launchController setLaunchAtLogin:launchOnLoginEnabled];
    
    [defaults setObject:jobTrackerURL forKey:@"jobTrackerURL"];
    [defaults setObject:usernames forKey:@"usernames"];
    [defaults setInteger:refreshInterval forKey:@"refreshInterval"];
    [defaults setBool:startingJobNotificationsEnabled forKey:@"startingJobNotificationsEnabled"];
    [defaults setBool:completedJobNotificationsEnabled forKey:@"completedJobNotificationsEnabled"];
    [defaults setBool:failedJobNotificationsEnabled forKey:@"failedJobNotificationsEnabled"];
    
    [[self window] close];
    [self.delegate preferencesUpdated];    
}


- (IBAction)cancelPressed:(id)sender {
    [[self window] close];
}


@end
