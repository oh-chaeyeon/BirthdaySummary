import SQLite
import UIKit

final class CategoryDatabase {

    static let shared = CategoryDatabase()

    private let db = BirthdayDatabase.shared.db
    private let table = Table("categories")

    private let idCol     = SQLite.Expression<String>("id")
    private let nameCol   = SQLite.Expression<String>("name")
    private let hexCol    = SQLite.Expression<String>("hexColor")
    
    private init() {
        try? createTableIfNeeded()
    }

    private func createTableIfNeeded() throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(idCol,   primaryKey: true)
            t.column(nameCol, unique:     true)
            t.column(hexCol)
        })

        if try db.scalar(table.count) == 0 {
            ["가족": UIColor.systemRed,
             "친구": UIColor.systemBlue,
             "직장": UIColor.systemGreen,
             "기타": UIColor.systemGray]
            .forEach { (n, c) in
                let item = CategoryItem(name: n, color: c)
                try? db.run(table.insert(
                    idCol <- item.id.uuidString,
                    nameCol <- n,
                    hexCol <- c.toHexString()
                ))
            }
        }
    }

    // 간단 CRUD – 별도 큐 필요 없음
    func fetchAll() -> [CategoryItem] {
        (try? db.prepare(table))?.compactMap { r in
            guard let id = UUID(uuidString: r[idCol]) else { return nil }
            return CategoryItem(id: id,
                                name: r[nameCol],
                                color: UIColor(hex: r[hexCol]) ?? .systemGray)
        } ?? []
    }

    func insert(_ item: CategoryItem) {
        try? db.run(table.insert(
            idCol <- item.id.uuidString,
            nameCol <- item.name,
            hexCol  <- item.color.toHexString()
        ))
    }

    func update(_ item: CategoryItem) {
        let row = table.filter(idCol == item.id.uuidString)
        try? db.run(row.update(
            nameCol <- item.name,
            hexCol  <- item.color.toHexString()
        ))
    }

    func delete(id: UUID) {
        let row = table.filter(idCol == id.uuidString)
        try? db.run(row.delete())
    }
}
