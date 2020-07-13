//
//  DocumentPickerView.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 24.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//
import UIKit
import SwiftUI

final class DocumentPickerView: NSObject, UIViewControllerRepresentable {
	typealias UIViewControllerType = UIDocumentPickerViewController
	
	var documentTypes: [String]
	var pickerMode: UIDocumentPickerMode
	var onDocumentPick: ([URL]) -> Void
	
	init(documentTypes: [String], pickerMode: UIDocumentPickerMode, onDocumentPick: @escaping ([URL]) -> Void) {
		self.documentTypes = documentTypes
		self.pickerMode = pickerMode
		self.onDocumentPick = onDocumentPick
	}

	lazy var viewController:UIDocumentPickerViewController = {
		let vc = UIDocumentPickerViewController(documentTypes: documentTypes, in: pickerMode)
		vc.allowsMultipleSelection = false
//        vc.accessibilityElements = [kFolderActionCode]
//        vc.shouldShowFileExtensions = true
		vc.delegate = self
		return vc
	}()

	func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPickerView>) -> UIDocumentPickerViewController {
		viewController.delegate = self
		return viewController
	}

	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPickerView>) {
	}
}

extension DocumentPickerView: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		print(urls)
		onDocumentPick(urls)
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		controller.dismiss(animated: true) {
		}
		print("cancelled")
	}
}
