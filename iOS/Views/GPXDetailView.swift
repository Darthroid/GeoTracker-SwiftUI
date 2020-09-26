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
			VStack {
				TabTopView(menuItems: ["General", "Tracks", "Elevation"])
					.padding(.bottom, 5)
				List {
					Text(viewModel.gpxEntity.name ?? "GPX file")
					Text(viewModel.gpxEntity.name ?? "GPX file")
					Text(viewModel.gpxEntity.name ?? "GPX file")
					Text(viewModel.gpxEntity.name ?? "GPX file")
					Text(viewModel.gpxEntity.name ?? "GPX file")
				}
				.listStyle(InsetListStyle())
			}
			.navigationBarTitle(Text(viewModel.gpxEntity.name ?? "GPX file"))
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
		GPXDetailView(viewModel: GPXViewModel(from: GPXEntity()))
    }
}
