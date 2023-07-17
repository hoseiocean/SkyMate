//
//  NotificationName.swift
//  SkyMate
//
//  Created by Thomas Heinis on 17/07/2023.
//

import Foundation

/// This extension provides a way to identify when a language change has occurred in the application.
///
/// It introduces a static property `languageDidChange` to the `Notification.Name` structure. This
/// property represents a notification that gets posted whenever the language of the app changes.
///
/// Observers of this notification can listen for it and update their content or behavior as necessary.
///
/// For example, a view controller might listen for this notification and update the text of its labels,
/// or a model object might listen for this notification and re-fetch its data in the correct language.
extension Notification.Name {

  static let languageDidChange = Notification.Name(Const.Name.languageDidChange)

}
