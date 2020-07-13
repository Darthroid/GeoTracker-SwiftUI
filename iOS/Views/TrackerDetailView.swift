//
//  TrackerDetailView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
import CoreLocation
//import GeoTrackerCore

struct TrackerDetailView: View {
	var viewModel: TrackerViewModel
	
	var shareButton: some View {
		Button(action: {
			
		}) {
			Image(systemName: "square.and.arrow.up")
				.resizable()
		}
	}
	
    var body: some View {
		VStack {
			MapView(coordinate: viewModel.points.first?.toCLLocationCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
			List {
				ForEach(viewModel.points, id: \.self) { point in
					PointRow(viewModel: point)
				}
			}
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
