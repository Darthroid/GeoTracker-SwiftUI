//
//  CreateTrackerView.swift
//  iOS
//
//  Created by Oleg Komaristy on 15.07.2020.
//

import SwiftUI

struct CreateTrackerView: View {
	@ObservedObject var viewModel =  TrackerRecorderViewModel()
	@State var updateFrrequency = 0.0
	@State var isFormInvalid = false
	
	var startButton: some View {
		Button(action: {
			isFormInvalid = !viewModel.isValidTrackerInfo
		}) {
			Text("Start")
		}
	}
	
    var body: some View {
		NavigationView {
			Form {
				TextField("Tracker Name", text: $viewModel.trackerName)
				Picker(selection: $viewModel.selectedFrequencyIndex, label: Text("Update frequency")) {
					ForEach(0 ..< viewModel.updateFrequencyOptions.count, id: \.self) {
						Text("\(viewModel.updateFrequencyOptions[$0]) seconds")
					}
				}.labelsHidden()
			}
			.navigationTitle(Text("New Tracker"))
			.navigationBarItems(trailing: startButton)
			.alert(isPresented: $isFormInvalid) {
//				Text("Please fill in all fields and try again")
				Alert(
					title: Text("Error"),
					message: Text("Please fill in all fields and try again"),
					dismissButton: .default(Text("Got it!"))
				)
			}
		}
	}
}

struct CreateTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTrackerView()
    }
}
