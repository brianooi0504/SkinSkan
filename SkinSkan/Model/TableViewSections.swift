//
//  TableViewSections.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/28/22.
//

enum ProfileSections: Int, CaseIterable, CustomStringConvertible {
    case testHistory
    case appSettings
    case feedback
    
    var description: String {
        switch self {
        case .testHistory: return "Recent Test History"
        case .appSettings: return "App Settings"
        case .feedback: return "Help and Feedback"
        }
    }
}

enum appSettingsOptions: Int, CaseIterable, CustomStringConvertible {
    case saveHistory
    
    var description: String {
        return "Save History"
    }
}

enum feedbackOptions: Int, CaseIterable, CustomStringConvertible {
    case tutorial
    case feedback
    
    var description: String {
        switch self {
        case .tutorial: return "Help"
        case .feedback: return "Feedback and Comments"
        }
    }
}
