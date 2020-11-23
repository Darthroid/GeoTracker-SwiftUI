//
//  ContentView.swift
//  Shared
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import SwiftUI
import Combine

public enum Tab: Int {
	case trackerList, settings

	var text: Text {
		switch self {
		case .trackerList: return Text(Bundle.main.displayName)
		case .settings: return Text("Settings")
		}
	}
	// TODO: macOS
	#if os(macOS)
	var image: Image {
		switch self {
		case .trackerList: return Image("list.bullet")
		case .settings: return Image("gear")
		}
	}
	#else
	var image: Image {
		switch self {
		case .trackerList: return Image(systemName: "list.bullet")
		case .settings: return Image(systemName: "gear")
		}
	}
	#endif
}

struct ContentView: View {
	
	@State private var selectedTab = Tab.trackerList
	@State var showSheetView = false
	
	@Environment(\.managedObjectContext) var moc

	private func tabBarItem(_ tab: Tab) -> some View {
		VStack {
			tab.image
			tab.text
		}
	}

	var body: some View {
		NavigationView {
			GPXListView()
				.environment(\.managedObjectContext, moc)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
