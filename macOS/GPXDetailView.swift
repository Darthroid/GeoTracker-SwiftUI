//
//  TrackerDetailView.swift
//  macOS
//
//  Created by Oleg Komaristy on 11.07.2020.
//

import SwiftUI

struct GPXDetailView: View {
	var viewModel: GPXViewModel
	
	var body: some View {
		VStack {
			MapView(waypoints: viewModel.waypoints, trackPoints: viewModel.allTrackPoints, mode: .viewing)
		}
	}
}

struct TrackerDetailView_Previews: PreviewProvider {
	static var previews: some View {
		let moc = CoreDataManager.shared.persistentContainer.viewContext
		GPXDetailView(viewModel: GPXViewModel(from: GPXEntity(context: moc)))
			.environment(\.managedObjectContext, moc)
	}
}
