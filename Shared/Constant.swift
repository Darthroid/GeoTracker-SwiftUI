//
//  Constant.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 24.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import Foundation

// UI
public let ERROR_TITLE = "Error"
public let WARNING_TITLE = "Warning"
#if !os(macOS)
public let DOC_TYPES = ["com.topografix.gpx"]
#else
public let DOC_TYPES = ["gpx"]
#endif
