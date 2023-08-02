//
//  NotificationName.swift
//  SkyMate
//
//  Created by Thomas Heinis on 17/07/2023.
//

import Foundation

extension Notification.Name {

  static let didProcessedTranscription = Notification.Name("New Transcription Processed")
  static let transcriptionDidEncounterError = Notification.Name("Transcription Error Encountered")
  static let transcriptionDidFoundTerm = Notification.Name("Term Found")
  static let languageDidChange = Notification.Name(Const.Name.languageDidChange)

}
