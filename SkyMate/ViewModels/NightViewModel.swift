//
//  NightViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 19/07/2023.
//

import Combine
import Foundation

/// `NightViewModel` is a ViewModel that manages the display and updates of night information in
/// the UI.
final class NightViewModel: ObservableObject {

  // MARK: - Initialization

  /// Initializes and starts the NightViewModel, which immediately updates the information card and
  /// starts a timer to update this information every second.
  init() {
    let cardTitle = NightText.title.localized
    var cardContent = String()
    var cardId: UUID?
    var timer: Timer? = nil

    // MARK: - Card content updating

    let updateCardContent = {
      do {
        let smTime = try SMTime()
        
        guard let nauticalSunsetUTC = smTime.nauticalSunsetUTC else {
          throw SMTimeError.failedToCalculateNauticalTwilightEnd
        }

        guard let remainingTime = smTime.timeIntervalToNauticalSunset() else {
          throw SMTimeError.failedToCalculateNauticalTwilightEnd
        }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: Const.Id.utc)!
        
        let components = calendar.dateComponents([.hour, .minute, .second, .timeZone], from: nauticalSunsetUTC)

        var roundedComponents = DateComponents()
        roundedComponents.hour = components.hour
        roundedComponents.minute = components.minute
        roundedComponents.timeZone = components.timeZone

        let roundedSunsetTime = calendar.date(from: roundedComponents)!
        
        cardContent = smTime.UTCTime(from: roundedSunsetTime)
          let hours = Int(remainingTime) / 3600
          let minutes = (Int(remainingTime) % 3600) / 60
          let seconds = Int(remainingTime) % 60
        cardContent += "\n" + String(format: "%02d:%02d:%02d", hours, minutes, seconds) + NightText.remaining.localized

        // If card exists, update it. Otherwise, create a new card.
        if let existingCardId = cardId,
           let cardIndex = CarrouselViewModel.shared.cards.firstIndex(where: { $0.id == existingCardId }) {
          let card = CarrouselViewModel.shared.cards[cardIndex]
          CarrouselViewModel.shared.updateCard(card, with: cardContent)
        } else {
          let newCard = Card(title: cardTitle, content: cardContent)
          CarrouselViewModel.shared.addCard(newCard)
          cardId = newCard.id
        }
        
      } catch {
        cardContent = "smTime Error"
        timer?.invalidate()
        timer = nil
      }
    }
    
    updateCardContent()

    // MARK: - Timer setup

    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      updateCardContent()
    }
  }
}
