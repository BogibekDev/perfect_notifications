import Foundation
import UserNotifications

import Foundation

struct ChannelDetails: Codable {
    let id: String
    let name: String
    let importance: Int
    let description: String
    let enableSound: Bool
    let soundUri: String?
    let enableVibration: Bool
}

