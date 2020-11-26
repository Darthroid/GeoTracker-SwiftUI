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
			}.onDrop(
				of: DOC_TYPES,
				isTargeted: nil,
				perform: { (items) -> Bool in
					return processDrop(items: items)
				}
			)
		}
		.onAppear {
			viewModel.fetchEntities(moc)
		}
		.listStyle(SidebarListStyle())
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
	
	func processDrop(items: [NSItemProvider]) -> Bool {
		guard !items.isEmpty else { return false }
		items.forEach { item in
			guard let identifier = item.registeredTypeIdentifiers.first,
				  DOC_TYPES.contains(identifier)
			else { return }
			
			item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
				DispatchQueue.main.async {
					if let urlData = urlData as? Data {
						let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
						try? viewModel.parseGPXFrom(url, context: moc)
					}
				}
			}
			
		}
		
		return true
	}
}

struct GPXListView_Previews: PreviewProvider {
	static var previews: some View {
		let moc = CoreDataManager.shared.persistentContainer.viewContext
		GPXListView()
			.environment(\.managedObjectContext, moc)
	}
}
