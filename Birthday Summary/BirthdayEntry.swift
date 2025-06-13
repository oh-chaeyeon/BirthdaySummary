import Foundation
import UIKit

struct BirthdayEntry: Codable, Equatable {
    let id: UUID
    var name, nickname: String

    var categoryID: UUID
    var category: String
    var categoryColorHex: String
    var categoryColor: UIColor { UIColor(hex: categoryColorHex) ?? .systemGray }

    var solarDate: String
    var alarm: String
    var like: String
    var dislike: String
}
