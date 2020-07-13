//
//  GeoTracker_SwiftUIApp.swift
//  Shared
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import SwiftUI
@main
struct GeoTracker_SwiftUIApp: App {
//	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onAppear {
					CoreDataManager.shared.initalizeStack {}
				}
		}
	}
}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//		CoreDataManager.shared.initalizeStack {}
//		return true
//	}
//}
