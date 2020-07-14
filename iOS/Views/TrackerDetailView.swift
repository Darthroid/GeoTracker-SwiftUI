//
//  TrackerDetailView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
import CoreLocation

struct TrackerDetailView: View {
	@State private var showShareSheet = false
	
	var viewModel: TrackerViewModel
	
	var shareButton: some View {
		Button(action: {
			viewModel.exportAsGPX() {
				showShareSheet.toggle()
			}
		}) {
			Image(systemName: "square.and.arrow.up")
				.resizable()
		}.sheet(isPresented: $showShareSheet) {
			ShareSheet(activityItems: [viewModel.fileUrl ?? viewModel.gpxString])
		}
	}
	
    var body: some View {
		VStack {
			MapView(coordinates: viewModel.points.map { $0.toCLLocationCoordinate }, mode: .viewing)
				.accessibility(identifier: "MapView")
			List {
				ForEach(viewModel.points, id: \.self) { point in
					PointRow(viewModel: point)
				}
			}
			.accessibility(identifier: "PointList")
		}
		.navigationBarTitle(Text("\(viewModel.name)"), displayMode: .inline)
		.navigationBarItems(trailing: shareButton)
	}
}

struct TrackerDetailView_Previews: PreviewProvider {
    static var previews: some View {
		TrackerDetailView(viewModel: TrackerViewModel(from: Tracker()))
    }
}
