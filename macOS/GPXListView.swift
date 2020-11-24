//
//  TrackerListView.swift
//  GeoTracker-SwiftUI
//
//  Created by Oleg Komaristy on 04.07.2020.
//

import SwiftUI

struct GPXListView: View {
	enum ActiveSheet {
		case trackerCreator, none
	}
		
	@ObservedObject var viewModel = GPXListViewModel()
	
	@Environment(\.managedObjectContext) var moc
	
	var body: some View {
		List {
			ForEach(viewModel.gpxModels, id: \.self) { gpxModel in
				NavigationLink(
					destination: GPXDetailView(viewModel: gpxModel)
				) {
					GPXRow(viewModel: gpxModel)
				}
			}.onDelete { indexSet in
				delete(at: indexSet)
			}
		}
		.frame(minWidth: 225, maxWidth: 300)
		.onAppear {
			viewModel.fetchEntities(moc)
		}
		.accessibility(identifier: "TrackerList")
	}
	
	func delete(at offset: IndexSet) {
		try? viewModel.delete(moc, atOffset: offset)
	}
	
	func openPanel() {
		let panel = NSOpenPanel()
		panel.allowedFileTypes = DOC_TYPES
		panel.canChooseDirectories = false
		panel.canCreateDirectories = false
		panel.allowsMultipleSelection = true
		let result = panel.runModal()
		if result == .OK {
			panel.urls.forEach {
				do {
					try viewModel.parseGPXFrom($0, context: moc)
				} catch {
					print(error.localizedDescription)
				}
			}
		}
	}
}

struct GPXListView_Previews: PreviewProvider {
	static var previews: some View {
		let moc = CoreDataManager.shared.persistentContainer.viewContext
		GPXListView()
			.environment(\.managedObjectContext, moc)
	}
}
