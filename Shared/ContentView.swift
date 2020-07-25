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
		case .trackerList: return Text("Trackers")
		case .settings: return Text("Settings")
		}
	}

	var image: Image {
		switch self {
		case .trackerList: return Image(systemName: "list.bullet")
		case .settings: return Image(systemName: "gear")
		}
	}
}

struct ContentView: View {
	
	@State private var selectedTab = Tab.trackerList
	@State var showSheetView = false

	private func tabBarItem(_ tab: Tab) -> some View {
		VStack {
			tab.image
			tab.text
		}
	}

	var body: some View {
		NavigationView {
			GPXListView()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
