//
//  MapPreviewView.swift
//  iOS
//
//  Created by Oleg Komaristy on 02.08.2020.
//

import SwiftUI

struct MapPreviewView: View {
    var body: some View {
		VStack {
			Text("Map Preview")
				
		}
		.frame(height: 120)
		.background(Color(.cyan))
		.cornerRadius(20.0)
		.shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct MapPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MapPreviewView()
    }
}
