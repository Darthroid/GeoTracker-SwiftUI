//
//  TrackerListView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI

struct GPXListView: View {
	enum ActiveSheet {
		case documentPicker, trackerCreator, none
	}
	
	@State var showingActionSheet = false
	@State var showingSheet = false
	@State var activeSheet: ActiveSheet = .none
	
	@ObservedObject var viewModel = GPXListViewModel()
	
	var addButton: some View {
		Button(action: {
			self.showingActionSheet.toggle()
		}) {
			Image(systemName: "plus.circle.fill")
				.resizable()
		}
		.frame(width: 25, height: 25)
		.actionSheet(isPresented: $showingActionSheet) {
			ActionSheet(
				title: Text(""),
				buttons: [
					.default(Text("New tracker")) {
						activeSheet = .trackerCreator
						showingSheet.toggle()
					},
					.default(Text("Import")) {
						activeSheet = .documentPicker
						showingSheet.toggle()
					},
					.cancel(Text("Cancel"))
				]
			)
		}
		.accessibility(identifier: "AddButton")
	}
	
	var picker: some View {
		DocumentPickerView(
			documentTypes: DOC_TYPES,
			pickerMode: .import,
			onDocumentPick: { urls in
				urls.forEach {
					do {
						try viewModel.parseGPXFrom($0)
					} catch {
						print(error.localizedDescription)
					}
				}
			}
		)
	}
	
    var body: some View {
		List {
			ForEach(viewModel.gpxModels, id: \.self) { gpxModel in
				NavigationLink(
					destination: GPXDetailView(viewModel: gpxModel)
				) {
					GPXRow(viewModel: gpxModel)
//					Text(tracker.description)
				}
			}.onDelete { indexSet in
				delete(at: indexSet)
			}
		}
//		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle(Tab.trackerList.text)
		.navigationBarItems(trailing: addButton)
		.sheet(isPresented: $showingSheet) {
			switch self.activeSheet {
			case .documentPicker:
				picker
			case .trackerCreator:
				CreateTrackerView()
			default:
				fatalError("Incorrect active sheet")
			}
		}
		.accessibility(identifier: "TrackerList")
    }
	
	func delete(at offset: IndexSet) {
		try? viewModel.delete(atOffset: offset)
	}
}

struct GPXListView_Previews: PreviewProvider {
    static var previews: some View {
        GPXListView()
    }
}
