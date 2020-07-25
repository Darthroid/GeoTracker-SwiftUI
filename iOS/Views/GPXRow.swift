//
//  TrackerRow.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 23.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
import CoreLocation
//#if os(iOS)
struct GPXRow: View {
	@State var isGenerating: Bool = false
	
	#if os(macOS)
	@State var image = NSImage()
	#else
	@State var image = UIImage()
	#endif
	
	var viewModel: GPXViewModel
	
	#if os(macOS)
	var imageView: some View {
		Image(nsImage: image)
			.cornerRadius(10)
			.frame(width: 50, height: 50)
	}
	#else
	var imageView: some View {
		Image(uiImage: image)
			.cornerRadius(10)
			.frame(width: 50, height: 50)
	}
	#endif
	
    var body: some View {
		HStack {
			if isGenerating {
				ZStack {
					// set placeholder ?
					imageView
					ProgressView()
						.frame(width: 50, height: 50)
				}.padding(.trailing, 5)
				
			} else {
				imageView
					.padding(.trailing, 5)
			}
			
			VStack(alignment: .leading) {
				Text(viewModel.name)
					.font(.headline)
				Spacer()
				Text(viewModel.description)
					.font(.subheadline)
			}
			Spacer()
		}
//		.padding()
		.onAppear(perform: generatePreview)
    }
	
	func generatePreview() {
		let size = CGSize(width: 50, height: 50)
		isGenerating = true
		var coordinates = [CLLocationCoordinate2D]()
		
		if !viewModel.allTrackPoints.isEmpty {
			coordinates = viewModel.allTrackPoints.map({ $0.coordinate })
		} else if !viewModel.waypoints.isEmpty {
			coordinates = viewModel.waypoints.map({ $0.coordinate })
		}

		PreviewGenerator.shared.generate(coordinates: coordinates, id: viewModel.id, size: size, completion: { preview in
			isGenerating = false
			
			image = preview
		})
	}
}

struct GPXRow_Previews: PreviewProvider {
    static var previews: some View {
		GPXRow(
			viewModel: GPXViewModel(from: GPXEntity())
		)
		.previewLayout(.fixed(width: 375, height: 80))
    }
}
//#endif
