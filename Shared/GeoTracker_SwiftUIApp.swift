//
//  GeoTracker_SwiftUIApp.swift
//  Shared
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import SwiftUI
@main
struct GeoTracker_SwiftUIApp: App {
	#if os(macOS)
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	#else
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	#endif
	@Environment(\.scenePhase) private var scenePhase
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
				.onChange(of: scenePhase) { phase in
					switch phase {
					case .active:
						print("SncenePhase -> active")
					case .inactive:
						print("SncenePhase -> inactive")
					case .background:
						print("SncenePhase -> background")
						CoreDataManager.shared.saveContext()
					@unknown default:
						print("SncenePhase -> unknown")
					}
				}
				.onAppear {
					if CommandLine.arguments.contains("--uitesting") {
						// reset state (clear UserDefaults, etc)
//						let defaultsName = Bundle.main.bundleIdentifier!
//						UserDefaults.standard.removePersistentDomain(forName: defaultsName)
					}
				}
		}.commands {
			SidebarCommands()
			CommandGroup(replacing: .newItem) {
//			CommandMenu("Utilities") {
				Button(action: {}) {
					Text("New")
				}.keyboardShortcut("n", modifiers: .command)
				
				Button(action: openDocument) {
					Text("Open")
				}.keyboardShortcut("o", modifiers: .command)
			}
		}
	}
	
	func openDocument() {
		#if os(macOS)
		let panel = NSOpenPanel()
		panel.allowedFileTypes = DOC_TYPES
		panel.canChooseDirectories = false
		panel.canCreateDirectories = false
		panel.allowsMultipleSelection = true
		let result = panel.runModal()
		let context = CoreDataManager.shared.persistentContainer.viewContext
		if result == .OK {
			panel.urls.forEach {
				do {
					let entity = try GPXParseManager()
						.parseGPX(
							fromUrl: $0,
							context: context
						)
					try CoreDataManager.shared.insertGpxEntity(context, entity)
				} catch {
					print(error.localizedDescription)
				}
			}
		}
		#endif
	}
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		
	}
}
#else
class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}
}
#endif
