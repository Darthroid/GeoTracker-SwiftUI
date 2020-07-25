//
//  TrackerRecorderViewModel.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

class TrackerRecorderViewModel: ObservableObject {
	enum TrackerRecordEvent {
		case timerUpdate
		case locationUpdate
	}

	public let updateFrequencyOptions: [Int] = [
		5,			// 5 seconds
		10,			// 10 seconds
		30,			// 30 seconds
		60//,			// 1 minute
//		60 * 5,		// 5 minutes
//		60 * 10,	// 10 minutes
//		60 * 30,	// 30 minute
//		60 * 60		// 1 hour
	]
	
//	private var points = [TrackerPoint]()
	private var trackerManager: TrackerRecordManager?

	//  Coordinates used by StartTrackingViewController to draw polyLine
	public var storedCoordinates: [CLLocationCoordinate2D] {
//		let coordinates = points.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
//		return coordinates
		return []
	}

	@Published public var trackerName: String = ""
	@Published public var selectedFrequencyIndex: Int = 0

	public var isValidTrackerInfo: Bool {
		switch LocationManager.authorizationStatus() {
		case .notDetermined, .restricted, .denied:
			return false
		case .authorizedAlways, .authorizedWhenInUse:
			return !self.trackerName.isEmpty
				&& self.updateFrequencyOptions[selectedFrequencyIndex] > 0
		@unknown default:
			return false
		}
	}

	public var locationInfoString: String {
		guard let location = LocationManager.shared.location else { return "" }
		return 	"Latitude: \(location.coordinate.latitude)" + "\n" +
				"Longitude: \(location.coordinate.longitude)" + "\n" +
				"Speed: \((location.speed * 3.6).rounded(.up)) km/h" + "\n" +
				"Alt: \(location.altitude) m"
	}

	public var locationUpdateHandler: (TrackerRecordEvent) -> Void = { _ in }

	public init() {
//		TrackerRecordManager.shared.delegate = self
	}

	public func startRecording() {
		self.trackerManager = TrackerRecordManager()
		trackerManager?.delegate = self
		trackerManager?.updateFrequency = Double(self.updateFrequencyOptions[selectedFrequencyIndex])
		trackerManager?.start()
	}

	public func stopRecording() {
		trackerManager?.stop()
		trackerManager?.delegate = nil
		trackerManager = nil
	}

	public func saveTrackerData() throws {
//		guard !points.isEmpty else { return }
//		do {
//			try CoreDataManager.shared.insertTracker(withId: UUID().uuidString,
//													 name: self.trackerName,
//													 points: self.points)
//		} catch {
//			throw(error)
//		}
	}

	private func clean() {
//		self.points.removeAll()
		self.trackerName = ""
		self.selectedFrequencyIndex = 0
	}
}

extension TrackerRecorderViewModel: TrackerRecordManagerDelegate {
	func trackerRecordingDidStart() {
		//
	}

	func trackerRecordingDidPaused() {
		//
	}

	func trackerRecordingDidFinished() {
		// do something with controller updates
		try? self.saveTrackerData()
		self.clean()
	}

	func trackerRecordingDidTick(_ location: CLLocation) {
//		let point = TrackerPoint()
//		point.id = UUID().uuidString
//		point.latitude = location.coordinate.latitude
//		point.longitude = location.coordinate.longitude
//		point.timestamp = Int64(location.timestamp.timeIntervalSince1970) //Int64(Date().timeIntervalSince1970)
//
//		self.points.append(point)
		self.locationUpdateHandler(.timerUpdate)
	}

	func trackerRecordingDidUpdateLocation(_ location: CLLocation) {
		self.locationUpdateHandler(.locationUpdate)
	}
}
