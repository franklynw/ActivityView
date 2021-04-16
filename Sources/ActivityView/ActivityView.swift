//
//  ActivityView.swift
//  Simplist
//
//  Created by Franklyn Weber on 05/02/2021.
//

import SwiftUI


public struct ActivityView<T>: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = UIActivityViewController
    
    @Binding private var activeSheet: T?
    
    private let items: [Any]
    private let subject: String
    private let done: ((Result<Bool, Error>) -> ())?
    
    public init(activeSheet: Binding<T?>, items: [Any], subject: String, done: ((Result<Bool, Error>) -> ())?) {
        _activeSheet = activeSheet
        self.items = items
        self.subject = subject
        self.done = done
    }
    
    
    public static func csv(activeSheet: Binding<T?>, items: [String], subject: String, done: ((Result<Bool, Error>) -> ())? = nil) -> ActivityView {
        
        let activityView = ActivityView(activeSheet: activeSheet, items: [items.joined(separator: ",")], subject: subject, done: done)
        return activityView
    }
    
    public static func withNewlines(activeSheet: Binding<T?>, items: [String], subject: String, done: ((Result<Bool, Error>) -> ())? = nil) -> ActivityView {
        let activityView = ActivityView(activeSheet: activeSheet, items: items, subject: subject, done: done)
        return activityView
    }
    
    public static func withMessage(activeSheet: Binding<T?>, message: String, subject: String, image: UIImage?, done: ((Result<Bool, Error>) -> ())? = nil) -> ActivityView {
        
        let items: [Any?] = [message, image]
        
        return ActivityView(activeSheet: activeSheet, items: items.compactMap { $0 }, subject: subject, done: done)
    }
    
    public static func withSource(activeSheet: Binding<T?>, source: UIActivityItemSource, subject: String, done: ((Result<Bool, Error>) -> ())? = nil) -> ActivityView {
        let activityView = ActivityView(activeSheet: activeSheet, items: [source], subject: subject, done: done)
        return activityView
    }
    
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIViewControllerType {
        
        let controller = ActivityViewController(activeSheet: _activeSheet, activityItems: items, applicationActivities: nil)
        controller.setValue(subject, forKey: "subject")
        
        controller.completionWithItemsHandler = { activityType, success, _, error in
            
            if let error = error {
                done?(.failure(error))
            } else {
                done?(.success(success && activityType != nil))
            }
        }
        
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<ActivityView>) {
        
    }
}


class ActivityViewController<T>: UIActivityViewController {
    
    @Binding private var activeSheet: T?
    
    init(activeSheet: Binding<T?>, activityItems: [Any], applicationActivities: [UIActivity]?) {
        _activeSheet = activeSheet
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activeSheet = nil
    }
}
