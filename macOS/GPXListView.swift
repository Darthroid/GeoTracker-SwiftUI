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
	
	@State var showingActionSheet = false
	@State var showingSheet = false
	@State var activeSheet: ActiveSheet = .trackerCreator
	
	@ObservedObject var viewModel = GPXListViewModel()
	
	@Environment(\.managedObjectContext) var moc
	
	var menu: some View {
		Menu(content: {
			Button(action: {
				activeSheet = .trackerCreator
				showingSheet.toggle()
			}) {
				Label("Create track", systemImage: "location.north.line")
			}
			Button(action: {
				
			}) {
				Label("Import GPX file", systemImage: "folder.badge.plus")
			}
		}, label: {
			Image(systemName: "plus.circle.fill")
				.resizable()
				.frame(width: 25, height: 25)
		})
		.accessibility(identifier: "AddButton")
	}
	
	var body: some View {
		List {
			ForEach(viewModel.gpxModels, id: \.self) { gpxModel in
//				NavigationLink(
//					destination: GPXDetailView(viewModel: gpxModel)
//				) {
//					GPXRow(viewModel: gpxModel)
					Text(gpxModel.description)
//				}
			}.onDelete { indexSet in
				delete(at: indexSet)
			}
		}
		.navigationTitle(Tab.trackerList.text)
//		.navigationBarTitle(Tab.trackerList.text)
//		.navigationBarItems(trailing: menu)
		.onAppear {
			viewModel.fetchEntities(moc)
		}
		.sheet(isPresented: $showingSheet) {
			switch self.activeSheet {
//			case .trackerCreator:
//				CreateTrackerView()
			default:
				fatalError("Incorrect active sheet")
			}
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
		GPXListView()
	}
}
