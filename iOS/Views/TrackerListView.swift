//
//  TrackerListView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI

struct TrackerListView: View {
	@State var showingActionSheet = false
	@State var showingSheet = false
	
	@ObservedObject var viewModel = TrackerListViewModel()
	
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
						
					},
					.default(Text("Import")) {
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
						try viewModel.parseGpxFrom($0)
					} catch {
						print(error.localizedDescription)
					}
				}
			}
		)
	}
	
    var body: some View {
		List {
			ForEach(viewModel.trackers, id: \.self) { tracker in
				NavigationLink(
					destination: TrackerDetailView(viewModel: tracker)
				) {
					TrackerRow(viewModel: tracker)
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
			picker
		}
		.accessibility(identifier: "TrackerList")
    }
	
	func delete(at offset: IndexSet) {
		try? viewModel.delete(at: offset)
	}
}

struct TrackerListView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerListView()
    }
}
