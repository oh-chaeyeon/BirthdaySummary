import UIKit

final class CategoryStore {
    static let shared = CategoryStore()
    private init() { reloadFromDB() }
    private(set) var items: [CategoryItem] = []
    
    func reloadFromDB() {
        items = CategoryDatabase.shared.fetchAll()
        sortInPlace()
    }
    
    func add(_ item: CategoryItem)   {
        CategoryDatabase.shared.insert(item)
        items.append(item) ; sortInPlace()
    }
    func update(_ item: CategoryItem){
        CategoryDatabase.shared.update(item)
        if let i = idx(item.id) { items[i] = item ; sortInPlace() }
    }
    func delete(id: UUID){
        CategoryDatabase.shared.delete(id:id)
        if let i = idx(id), items[i].name != "기타" { items.remove(at:i) }
    }
    
    func sorted() -> [CategoryItem] { items }
    
    private func idx(_ id: UUID)->Int? { items.firstIndex{ $0.id == id } }
    private func sortInPlace() {
        items.sort {
            if $0.name == "기타" { return false }
            if $1.name == "기타" { return true  }
            return $0.name < $1.name
        }
    }
}
