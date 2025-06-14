import UIKit

struct CategoryItem: Codable, Equatable {
    let id: UUID
    var name: String
    private var hex: String

    var color: UIColor {
        get { UIColor(hex: hex) ?? .systemGray }
        set { hex = newValue.toHexString() }
    }

    init(id: UUID = UUID(), name: String, color: UIColor) {
        self.id = id
        self.name = name
        self.hex  = color.toHexString()
    }
    
    static let defaultCategory = CategoryItem(name:"기타", color:.systemGray)
}
