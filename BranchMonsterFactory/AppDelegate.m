    //
//  AppDelegate.m
//  BranchMonsterFactory
//
//  Created by Alex Austin on 9/6/14.
//  Copyright (c) 2014 Branch, Inc All rights reserved.
//

#import "AppDelegate.h"
#import "Helpers/MonsterPreferences.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Branch/Branch.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // if you are using the TEST key
    [Branch setUseTestBranchKey:YES];
    // listener for Branch Deep Link data
    [[Branch getInstance: @"668519394388759337"] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nonnull params, NSError * _Nullable error) {
        // do stuff with deep link data (nav to page, display content, etc)
        if (!error && params){
            NSLog(@">> Params: %@", params);
            
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController *nextVC;
            
            // If the key 'monster' is present in the deep link dictionary
            // then load the monster viewer with the appropriate monster parameters
            if ([params objectForKey:@"monster"]) {
                NSLog(@"____ param: %@", [params valueForKeyPath:@"monster.monster_name"]);
                [MonsterPreferences setMonsterName:[params valueForKeyPath:@"monster.monster_name"]];
                [MonsterPreferences setFaceIndex:[[params valueForKeyPath:@"monster.face_index"] intValue]];
                [MonsterPreferences setBodyIndex:[[params valueForKeyPath:@"monster.body_index"] intValue]];
                [MonsterPreferences setColorIndex:[[params valueForKeyPath:@"monster.color_index"] intValue]];
                
                // Choose the monster viewer as the next view controller
                nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MonsterViewerViewController"];
                
                
                // Else, the app is being opened up from the home screen or from the app store
                // Load the next logical view controller
            } else {
                
                // If a name has been saved in preferences, then this user has already created a monster
                // Load the viewer
                if (![MonsterPreferences getMonsterName]) {
                    [MonsterPreferences setMonsterName:@""];
                    
                    // Choose the monster viewer as the next view controller
                    nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MonsterCreatorViewController"];
                    
                    // If no name has been saved, this user is new, so load the monster maker screen
                } else {
                    nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MonsterViewerViewController"];
                    
                }
                [navController setViewControllers:@[nextVC] animated:YES];
            }
            // launch the next view controller
            [navController setViewControllers:@[nextVC] animated:YES];
        }
    }];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![[Branch getInstance] handleDeepLink:url]) {
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[Branch getInstance] application:app openURL:url options:options];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    // handler for Universal Links
    [[Branch getInstance] continueUserActivity:userActivity];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // handler for Push Notifications
    [[Branch getInstance] handlePushNotification:userInfo];
}

@end
