//
//  MapView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 24.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView {
	enum MapMode {
		case viewing, recording
	}
	
	@State var polyline: MKPolyline?
	
	@State var coordinates: [CLLocationCoordinate2D] = []
	
	var mode: MapMode

	func makeMapView() -> MKMapView {
		MKMapView(frame: .zero)
	}
	
	func updateMapView(_ view: MKMapView, context: Context) {
//		let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
//		let region = MKCoordinateRegion(center: coordinate, span: span)
//		view.setRegion(region, animated: false)
	}
}

#if os(macOS)

extension MapView: NSViewRepresentable {
	func makeNSView(context: Context) -> MKMapView {
		makeMapView()
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		updateMapView(nsView, context: context)
	}
}

#else

extension MapView: UIViewRepresentable {
	func makeUIView(context: Context) -> MKMapView {
		makeMapView()
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		updateMapView(uiView, context: context)
	}
}

#endif

struct MapView_Previews: PreviewProvider {
	static var previews: some View {
		MapView(mode: .viewing)
	}
}

