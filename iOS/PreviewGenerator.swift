//
//  PreviewGenerator.swift
//  GeoTracker-SwiftUI
//
//  Created by Oleg Komaristy on 01.07.2020.
//

import Foundation
import MapKit
//#if os(iOS)
import UIKit

extension MKMapSnapshotter.Snapshot {

	func drawPolyline(_ polyline: MKPolyline, color: UIColor, lineWidth: CGFloat) -> UIImage {
		UIGraphicsBeginImageContext(self.image.size)
		let rectForImage = CGRect(x: 0, y: 0, width: self.image.size.width, height: self.image.size.height)

		// Draw map
		self.image.draw(in: rectForImage)

		var pointsToDraw = [CGPoint]()

		let points = polyline.points()
		var i = 0
		while i < polyline.pointCount {
			let point = points[i]
			let pointCoord = point.coordinate
			let pointInSnapshot = self.point(for: pointCoord)
			pointsToDraw.append(pointInSnapshot)
			i += 1
		}

		let context = UIGraphicsGetCurrentContext()
		context!.setLineWidth(lineWidth)

		for point in pointsToDraw {
			if point == pointsToDraw.first {
				context!.move(to: point)
			} else {
				context!.addLine(to: point)
			}
		}

		context?.setStrokeColor(color.cgColor)
		context?.strokePath()

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image!
	}
}

final class PreviewGenerator {
	public static let shared = PreviewGenerator()
	private let imageCache = NSCache<NSString, UIImage>()
	
	func generate(coordinates: [CLLocationCoordinate2D], id: String, size: CGSize, completion: @escaping ((UIImage) -> Void)) {
		if let cachedImage = self.imageCache.object(forKey: id as NSString) {
			completion(cachedImage)
		} else {
			self.generateSnapShot(coordinates: coordinates, id: id, size: size, completion: completion)
		}
	}
	
	private func generateSnapShot(coordinates: [CLLocationCoordinate2D], id: String, size: CGSize, completion: @escaping ((UIImage) -> Void)) {
		guard !coordinates.isEmpty else {
			completion(UIImage())
			return
		}
		
		let mapSnapshotOptions = MKMapSnapshotter.Options()

		let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
		let region = MKCoordinateRegion(polyLine.boundingMapRect)

		mapSnapshotOptions.region = region

		// Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
		mapSnapshotOptions.scale = UIScreen.main.scale

		// Set the size of the image output.
		mapSnapshotOptions.size = size

		mapSnapshotOptions.showsBuildings = false

		let snapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
		
		snapshotter.start(with: .global(qos: .userInteractive)) { [weak self] snapshot, _ in
			guard let snapshot = snapshot else {
				return
			}

			let finalImage = snapshot.drawPolyline(polyLine, color: UIColor.systemBlue, lineWidth: 3)
			self?.imageCache.setObject(finalImage, forKey: id as NSString)
			DispatchQueue.main.async {
				completion(finalImage)
			}
		}
	}
}
//#endif
