//
//  AppDelegate.m
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 12/27/21.
//

#import "AppDelegate.h"
@import GoogleMaps;
//@import GooglePlaces;
@interface AppDelegate ()

@end

@implementation AppDelegate
//implement core location service here?

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:@"AIzaSyD2kiSBXUlM0v-ByN9Aeaf0zIjv3CW7Fsg"];
//    [GMSPlacesClient provideAPIKey:@"AIzaSyD2kiSBXUlM0v-ByN9Aeaf0zIjv3CW7Fsg"];
    //self.window.rootViewController <- pass location manager
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
