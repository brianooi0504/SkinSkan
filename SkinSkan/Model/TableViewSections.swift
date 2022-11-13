//
//  TableViewSections.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/28/22.
//

/// Contains all enumerations used to customize the TableViewCells in ProfileViewController

/// Enumeration for TableView sections
enum ProfileSections: Int, CaseIterable, CustomStringConvertible {
    case testHistory
    case appSettings
    case feedback
    
    /// Description used for the title of each section
    var description: String {
        switch self {
        case .testHistory: return "Recent Test History"
        case .appSettings: return "App Settings"
        case .feedback: return "About and Feedback"
        }
    }
}

/// Enumeration for App Settings rows
enum AppSettingsOptions: Int, CaseIterable, CustomStringConvertible {
    case saveHistory
    
    /// Description used for the title of each row
    var description: String {
        return "Save History"
    }
}

/// Enumeration for Feedback rows
enum FeedbackOptions: Int, CaseIterable, CustomStringConvertible {
    case feedback
    case about
    
    /// Description used for the title of each row
    var description: String {
        switch self {
        case .feedback: return "Feedback & Comments"
        case .about: return "About"
        }
    }
}
