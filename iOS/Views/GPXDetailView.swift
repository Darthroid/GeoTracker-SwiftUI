//
//  TrackerDetailView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
import CoreLocation

struct GPXDetailView: View {
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
//				.accessibility(identifier: "ShareSheet")
		}
	}
	
    var body: some View {
		VStack {
			MapView(waypoints: viewModel.waypoints, trackPoints: viewModel.allTrackPoints, mode: .viewing)
				.edgesIgnoringSafeArea(.bottom)
		}
		.navigationBarTitle(Text("\(viewModel.name)"), displayMode: .inline)
		.navigationBarItems(trailing: shareButton)
	}
}

struct TrackerDetailView_Previews: PreviewProvider {
    static var previews: some View {
		GPXDetailView(viewModel: GPXViewModel(from: GPXEntity()))
    }
}
