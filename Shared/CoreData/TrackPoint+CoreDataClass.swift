//
//  TrackPoint+CoreDataClass.swift
//  
//
//  Created by Oleg Komaristy on 17.07.2020.
//
//

import Foundation
import CoreData

@objc(TrackPoint)
public class TrackPoint: NSManagedObject {
	convenience public init() {
		let context = CoreDataManager.shared.context
		let entityName = String(describing: TrackPoint.self)
		guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
			fatalError("Could not create entity of TrackPoint")
		}

		self.init(entity: entity, insertInto: context)
	}
}
