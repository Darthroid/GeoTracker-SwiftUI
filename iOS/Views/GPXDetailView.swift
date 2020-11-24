//
//  TrackerDetailView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
import CoreLocation

struct GPXInfoView: View {
	@State private var showShareSheet = false
	
	@Environment(\.managedObjectContext) var moc
	
	var viewModel: GPXViewModel
	
	var shareButton: some View {
		Button(action: {
			viewModel.exportAsGPX() {
				showShareSheet.toggle()
			}
		}) {
			Image(systemName: "square.and.arrow.up")
				.resizable()
		}
		.accessibility(identifier: "ShareButton")
		.sheet(isPresented: $showShareSheet) {
			ShareSheet(activityItems: [viewModel.fileUrl ?? viewModel.gpxString])
		}
	}
	
	var body: some View {
		NavigationView {
			List {
				Text("Created: \(viewModel.gpxEntity.time)")	// TODO: int64 to readable date
				Text("Author: " + (viewModel.gpxEntity.author ?? "Unknown"))
				Text("URL: " + (viewModel.gpxEntity.url ?? "Empty"))
				Text("Email: " + (viewModel.gpxEntity.url ?? "Empty"))
				VStack(alignment: .leading) {
					Text("Tracks")
						.font(.headline)
						.padding(.bottom)
					Text("\(viewModel.tracks.count) tracks")
				}
				VStack(alignment: .leading) {
					Text("Waypoints")
						.font(.headline)
						.padding(.bottom)
					Text("\(viewModel.waypoints.count) waypoints")
				}
				VStack(alignment: .leading) {
					Text("Description")
						.font(.headline)
						.padding(.bottom)
					Text(viewModel.gpxEntity.desc ?? "Empty")
				}
			}
			.listStyle(InsetListStyle())
			.navigationBarTitle(Text(viewModel.gpxEntity.name ?? "GPX file"), displayMode: .inline)
			.navigationBarItems(trailing: shareButton)
		}
	}
}

struct GPXInfoView_Previews: PreviewProvider {
	static var previews: some View {
		GPXInfoView(viewModel: GPXViewModel(from: GPXEntity()))
	}
}

struct GPXDetailView: View {
	@State private var showInfoSheet = false
	
	@Environment(\.managedObjectContext) var moc
	
	var viewModel: GPXViewModel
	
	var infoButton: some View {
		Button(action: {
			showInfoSheet.toggle()
		}) {
			Image(systemName: "info.circle")
				.resizable()
				.frame(width: 25, height: 25)
		}
		.accessibility(identifier: "InfoButton")
		.sheet(isPresented: $showInfoSheet) {
//			ShareSheet(activityItems: [viewModel.fileUrl ?? viewModel.gpxString])
			GPXInfoView(viewModel: viewModel)
				.environment(\.managedObjectContext, moc)
		}
	}
	
    var body: some View {
		VStack {
			MapView(waypoints: viewModel.waypoints, trackPoints: viewModel.allTrackPoints, mode: .viewing)
				.edgesIgnoringSafeArea(.bottom)
		}
		.navigationBarTitle(Text("\(viewModel.name)"), displayMode: .inline)
		.navigationBarItems(trailing: infoButton)
	}
}

struct GPXDetailView_Previews: PreviewProvider {
    static var previews: some View {
		let moc = CoreDataManager.shared.persistentContainer.viewContext
		GPXDetailView(viewModel: GPXViewModel(from: GPXEntity(context: moc)))
			.environment(\.managedObjectContext, moc)
    }
}
