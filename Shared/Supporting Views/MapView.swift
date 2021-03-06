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
	
	@State var waypoints: [Waypoint] = []
	@State var trackPoints: [TrackPoint] = []
	
	var mode: MapMode

	func makeMapView() -> MKMapView {
		let map = MKMapView(frame: .zero)
		#if os(macOS)
		map.setAccessibilityIdentifier("MapView")
		#else
		map.accessibilityIdentifier = "MapView"
		#endif
		return map
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func updateMapView(_ view: MKMapView, context: Context) {
		#if os(iOS)
		view.showsScale = true
		#endif
		self.drawPolyline(view, with: self.trackPoints.map({ $0.coordinate }))
		switch self.mode {
		case .viewing:
			waypoints.forEach {
				self.addAnnotation(
					view,
					coordinate: $0.coordinate,
					title: $0.name,
					subtitle: $0.desc
				)
			}
		case .recording:
			break
		}
	}
	
	/// Draws polyline on map from coordiantes.
	/// - Parameters:
	///   - coordinates: Coordinates array for drwaing polyline.
	///   - center: Boolean value indicating whether map needs to be centered on polyline.
	///   - animated: Boolean value indicating whether centering on polyline should be animated.
	func drawPolyline(_ view: MKMapView, with coordinates: [CLLocationCoordinate2D], center: Bool = true, animated: Bool = false) {
		view.removeOverlays(view.overlays)
		let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)

		view.addOverlay(polyLine)

		guard center else { return }

		let centerBlock = {
			let overlays = view.overlays
			if let topOverlay = overlays.first(where: { $0 is MKPolyline }) {
				let rect = overlays.reduce(topOverlay.boundingMapRect, { $0.union($1.boundingMapRect) })
				#if os(macOS)
				let edgePadding = NSEdgeInsets(
					top: 50.0,
					left: 50.0,
					bottom: 50.0,
					right: 50.0
				)
				#else
				let edgePadding = UIEdgeInsets(
					top: 50.0,
					left: 50.0,
					bottom: 50.0,
					right: 50.0
				)
				#endif
				
				view.setVisibleMapRect(
					rect,
					edgePadding: edgePadding,
					animated: animated
				)
			}
		}

		if animated {
			#if os(macOS)
			centerBlock()
			#else
			UIView.animate(withDuration: 1.5, animations: {
				centerBlock()
			})
			#endif
		} else {
			centerBlock()
		}
	}
	
	func addAnnotation(_ view: MKMapView, coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
		let annoatation = MKPointAnnotation()
		annoatation.coordinate = coordinate
		annoatation.title = title
		annoatation.subtitle = subtitle

		view.addAnnotation(annoatation)
	}
	
	func clearMap(_ view: MKMapView) {
		let overlays = view.overlays
		let allAnnotations = view.annotations
		view.removeAnnotations(allAnnotations)
		view.removeOverlays(overlays)
	}
}

#if os(macOS)

extension MapView: NSViewRepresentable {
	func makeNSView(context: Context) -> MKMapView {
		let map = makeMapView()
		map.delegate = context.coordinator
		return map
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		updateMapView(nsView, context: context)
	}
}

#else

extension MapView: UIViewRepresentable {
	func makeUIView(context: Context) -> MKMapView {
		let map = makeMapView()
		map.delegate = context.coordinator
		return map
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

// MARK: - Coordinator

final class Coordinator: NSObject {
	var control: MapView

	init(_ control: MapView) {
		self.control = control
	}
}

extension Coordinator: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MKPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = .systemBlue
		renderer.lineWidth = 4
		return renderer
	}
}
