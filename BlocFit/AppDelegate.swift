//
//  AppDelegate.swift
//  BlocFit
//
//  Created by Colin Conduff on 9/30/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData
import Keys
import GoogleMaps
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /**
     Provide GMSServices with the Google Maps API Key held by cocoapods-keys.
     
     The API Key can be set in a .env file or in the command-line.  
     See the README.md file and cocoapods-keys documentation for more info.
     */
    func setupGoogleMapsAPI() {
        let gmsKey = BlocfitKeys().googleMapsAPIKey()!
        GMSServices.provideAPIKey(gmsKey)
    }
    
    /**
     Initialize the user's data when the app is first installed.
     
     Create a new owner and set when the app is first installed.
     Set initial privacy settings and store them in user defaults.
     */
    func setupUserData() {
        do {
            if try !Owner.wasCreated(context: persistentContainer.viewContext) {
                let _ = try Owner.create(context: persistentContainer.viewContext)
                BFUserDefaults.set(friendsWillDefaultToTrusted: true)
                BFUserDefaults.set(willShareFirstNameWithTrustedFriends: false)
            }
        } catch let error {
            print(error)
        }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupGoogleMapsAPI()
        setupUserData()
        
        FBSDKApplicationDelegate.sharedInstance()
            .application(
                application,
                didFinishLaunchingWithOptions: launchOptions)
            
        return true
    }
    
    // Required for FBSDK
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance()
            .application(
                app,
                open: url,
                options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can 
        // occur for certain types of temporary interruptions (such as an incoming phone call or 
        // SMS message) or when the user quits the application and it begins the transition to 
        // the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics 
        // rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user 
        // data, invalidate timers, and store enough application state information to restore 
        // your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of 
        // applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you 
        // can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was 
        // inactive. If the application was previously in the background, optionally refresh the 
        // user interface.
        
        // Facebook related
//        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. 
        // Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application 
        // terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BlocFit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to 
                // generate a crash log and terminate. You should not use this function in a 
                // shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection 
                 *   when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
