//
//  GeoTracker_SwiftUIApp.swift
//  Shared
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import SwiftUI
#if !os(macOS)
@main
struct GeoTracker_SwiftUIApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onAppear {
					if CommandLine.arguments.contains("--uitesting") {
						// reset state (clear UserDefaults, etc)
//						let defaultsName = Bundle.main.bundleIdentifier!
//						UserDefaults.standard.removePersistentDomain(forName: defaultsName)
					}
				}
		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		CoreDataManager.shared.initalizeStack {}
		return true
	}
}
#else
// A newly-created iOS project using the Swift language may no longer build after enabling Mac Catalyst. (67885114)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var window: NSWindow!


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Create the SwiftUI view that provides the window contents.
		let contentView = ContentView()

		// Create the window and set the content view.
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false)
		window.isReleasedWhenClosed = false
		window.center()
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: contentView)
		window.makeKeyAndOrderFront(nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

#endif
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//		CoreDataManager.shared.initalizeStack {}
//		return true
//	}
//}
