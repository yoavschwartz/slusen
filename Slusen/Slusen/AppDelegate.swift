//
//  AppDelegate.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    fileprivate var mobilePayJob: PublishSubject<MobilePaySuccessfulPayment>?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()

        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary != nil {
            if let controller = self.window?.rootViewController as? SideMenuBaseViewController {
                controller.showViewController(index: 1, animated: false)
            }
        }


        // Override point for customization after application launch.

        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })

            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self

        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        MobilePayManager.sharedInstance().setup(withMerchantId: "APPDK0000000000", merchantUrlScheme: "slusen", country: MobilePayCountry.denmark)



        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        handleMobilePayment(url: url)
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if ( application.applicationState == .inactive || application.applicationState == .background  )
        {
            if let controller = self.window?.rootViewController as? SideMenuBaseViewController {
                controller.showViewController(index: 1, animated: false)
            }
        }
    }
}

extension Notification.Name {
    static let orderStatusChange = Notification.Name("OrderStatusChange")
}

//TODO: Talk to dima about content-available: true


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")

        // Print full message.
        print("%@", userInfo)

        NotificationCenter.default.post(name: .orderStatusChange, object: nil)
    }

}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}

extension AppDelegate: PaymentHandler {
    func makePayment(orderID: String, productPrice: Float) -> Observable<MobilePaySuccessfulPayment> {
        let pubSubject = PublishSubject<MobilePaySuccessfulPayment>()
        self.mobilePayJob = pubSubject
        let payment = MobilePayPayment(orderId: orderID, productPrice: productPrice)!
        MobilePayManager.sharedInstance().beginMobilePayment(with: payment) { [weak self] error in
            guard self?.mobilePayJob?.isDisposed != true else { return }
            self?.mobilePayJob?.onError(PaymentError.error(error))
        }
        return pubSubject.asObservable()
    }

    func handleMobilePayment(url: URL) {
        MobilePayManager.sharedInstance().handleMobilePayPayment(with: url, success: { [weak self] (success) in
            guard self?.mobilePayJob?.isDisposed != true else { return }
            guard let success = success else { preconditionFailure("Should never be nil if success") }
            self?.mobilePayJob?.onNext(success)
            self?.mobilePayJob?.onCompleted()
            print(success)
            }, error: { [weak self] (error: Error) in
                guard self?.mobilePayJob?.isDisposed != true else { return }
                self?.mobilePayJob?.onError(PaymentError.error(error))
            }, cancel: { [weak self] (cancelled: MobilePayCancelledPayment?) in
                guard self?.mobilePayJob?.isDisposed != true else { return }
                guard let cancelled = cancelled else { preconditionFailure("Should never be nil if success") }
                self?.mobilePayJob?.onError(PaymentError.cancelled(orderID: cancelled.orderId))
            }
        )
    }
}

