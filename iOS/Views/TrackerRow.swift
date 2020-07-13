//
//  TrackerRow.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 23.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
//import GeoTrackerCore
//#if os(iOS)
struct TrackerRow: View {
	@State var isGenerating: Bool = false
	
	#if os(macOS)
	@State var image = NSImage()
	#else
	@State var image = UIImage()
	#endif
	
	var viewModel: TrackerViewModel
	
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
		PreviewGenerator.shared.generate(points: viewModel.points, trackerId: viewModel.id, size: size, completion: { preview in
//			DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
				isGenerating = false

				image = preview
//			})
			
		})
	}
}

struct TrackerRow_Previews: PreviewProvider {
    static var previews: some View {
		TrackerRow(
			viewModel: TrackerViewModel(from: Tracker())
		)
		.previewLayout(.fixed(width: 375, height: 80))
    }
}
//#endif
