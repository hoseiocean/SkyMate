//
//  Command.swift
//  SkyMate
//
//  Created by Thomas Heinis on 12/07/2023.
//

enum Command {
  case destination(icaoCode: String)
  case metar
  case microphone
  case night
  case notam
  case request
}
