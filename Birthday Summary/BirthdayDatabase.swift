import SQLite
import UIKit

final class BirthdayDatabase {

    static let shared = BirthdayDatabase()
    let db: Connection

    private let birthdayTable = Table("birthdays")
    private let idColumn        = SQLite.Expression<String>("id")
    private let nameColumn      = SQLite.Expression<String>("name")
    private let nicknameColumn  = SQLite.Expression<String>("nickname")
    
    private let categoryIDColumn  = SQLite.Expression<String>("categoryID")
    private let categoryColumn    = SQLite.Expression<String>("category")
    private let categoryHexColumn = SQLite.Expression<String>("categoryColorHex")
    
    private let solarDateColumn = SQLite.Expression<String>("solarDate")
    private let alarmColumn     = SQLite.Expression<String>("alarm")
    private let likeColumn      = SQLite.Expression<String>("like")
    private let dislikeColumn   = SQLite.Expression<String>("dislike")
    
    private init() {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("birthday.sqlite3")

        db = try! Connection(url.path)
        db.busyTimeout = 5_000
        try? db.execute("PRAGMA journal_mode=WAL")

        try? createTable()
        print("📍 DB Path:", url.path)
    }

    private func createTable() throws {
        try db.run(birthdayTable.create(ifNotExists: true) { t in
            t.column(idColumn, primaryKey: true)
            t.column(nameColumn)
            t.column(nicknameColumn)
            t.column(categoryIDColumn)
            t.column(categoryColumn)
            t.column(categoryHexColumn)
            t.column(solarDateColumn)
            t.column(alarmColumn)
            t.column(likeColumn)
            t.column(dislikeColumn)
        })
    }

    func insert(_ e: BirthdayEntry) {
        let q = birthdayTable.insert(
            idColumn          <- e.id.uuidString,
            nameColumn        <- e.name,
            nicknameColumn    <- e.nickname,
            categoryIDColumn  <- e.categoryID.uuidString,
            categoryColumn    <- e.category,
            categoryHexColumn <- e.categoryColorHex,
            solarDateColumn   <- e.solarDate,
            alarmColumn       <- e.alarm,
            likeColumn        <- e.like,
            dislikeColumn     <- e.dislike
        )
        try? db.run(q)
    }

    func update(_ e: BirthdayEntry) {
        let row = birthdayTable.filter(idColumn == e.id.uuidString)
        let q = row.update(
            nameColumn        <- e.name,
            nicknameColumn    <- e.nickname,
            categoryIDColumn  <- e.categoryID.uuidString,
            categoryColumn    <- e.category,
            categoryHexColumn <- e.categoryColorHex,
            solarDateColumn   <- e.solarDate,
            alarmColumn       <- e.alarm,
            likeColumn        <- e.like,
            dislikeColumn     <- e.dislike
        )
        try? db.run(q)
    }

    func delete(id: UUID) {
        let row = birthdayTable.filter(idColumn == id.uuidString)
        try? db.run(row.delete())
    }

    func fetchAll() -> [BirthdayEntry] {
        (try? db.prepare(birthdayTable))?
            .compactMap { r in
                guard
                    let bid  = UUID(uuidString: r[idColumn]),
                    let cid  = UUID(uuidString: r[categoryIDColumn])
                else { return nil }

                return BirthdayEntry(
                    id: bid,
                    name: r[nameColumn],
                    nickname: r[nicknameColumn],
                    categoryID: cid,
                    category: r[categoryColumn],
                    categoryColorHex: r[categoryHexColumn],
                    solarDate: r[solarDateColumn],
                    alarm: r[alarmColumn],
                    like: r[likeColumn],
                    dislike: r[dislikeColumn]
                )
            } ?? []
    }
}
