//
//  TabTopView.swift
//  iOS
//
//  Created by Oleg Komaristy on 01.08.2020.
//

import SwiftUI

struct TabTopView: View {
	@State var index = 0
	var menuItems: [String]
	
    var body: some View {
		HStack(spacing: 0) {
			ForEach(menuItems, id: \.self) { item in
				Text(item)
					.foregroundColor(self.index == self.menuItems.firstIndex(of: item)! ? .white : Color.blue.opacity(0.7))
					.font(.footnote)
					.fontWeight(.bold)
					.multilineTextAlignment(.center)
					.padding(.vertical,8.0)
					.padding(.horizontal,35)
					.background(Color.blue.opacity(self.index == self.menuItems.firstIndex(of: item)! ? 1 : 0))
					.clipShape(Capsule())
					.onTapGesture {
						withAnimation(.default) {
							self.index = self.menuItems.firstIndex(of: item)!
						}
					}
				
			}
		}
		.background(Color.black.opacity(0.06))
		.clipShape(Capsule())
		.padding(.horizontal)
//		.padding(.top,25)
    }
}

struct TabTopView_Previews: PreviewProvider {
    static var previews: some View {
		TabTopView(menuItems: ["One", "Two", "Three"])
			.previewLayout(.fixed(width: 375, height: 100))
    }
}
