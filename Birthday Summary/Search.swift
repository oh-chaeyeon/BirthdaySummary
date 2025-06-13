import UIKit

class Search: UITableViewController, UISearchBarDelegate, AddDayDelegate {
    
    @IBOutlet weak var searchInput: UISearchBar!
    
    private var allEntries: [BirthdayEntry] = []
    private var filteredEntries: [BirthdayEntry] = []
    private var selectedEntry: BirthdayEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allEntries = BirthdayDatabase.shared.fetchAll()
        searchBar(searchInput, textDidChange: searchInput.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredEntries = allEntries
        } else {
            let keyword = searchText.lowercased()
            filteredEntries = allEntries.filter {
                $0.name.lowercased().contains(keyword)      ||
                $0.nickname.lowercased().contains(keyword)  ||
                $0.category.lowercased().contains(keyword)  ||
                $0.like.lowercased().contains(keyword)      ||
                $0.dislike.lowercased().contains(keyword)   ||
                $0.solarDate.lowercased().contains(keyword)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.isEmpty ? 1 : filteredEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredEntries.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
            cell.textLabel?.text          = "검색 결과가 없어요 😥"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor     = .systemGray
            cell.detailTextLabel?.text    = nil
            cell.selectionStyle           = .none
            return cell
        }
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let entry   = filteredEntries[indexPath.row]
        let keyword = searchInput.text?.lowercased() ?? ""
        
        let baseText = "\(entry.name) (\(entry.nickname))"
        let attr     = NSMutableAttributedString(string: baseText, attributes: [.foregroundColor: UIColor.label])
        if !keyword.isEmpty {
            let nsBase = baseText.lowercased() as NSString
            let range  = nsBase.range(of: keyword)
            if range.location != NSNotFound {
                attr.addAttributes([
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.boldSystemFont(ofSize: 17)
                ], range: range)
            }
        }
        cell.textLabel?.attributedText = attr
        cell.textLabel?.textAlignment  = .left
        
        var matched = ""
        if entry.like.lowercased().contains(keyword) {
            matched = "❤️ " + entry.like
        } else if entry.dislike.lowercased().contains(keyword) {
            matched = "💀 " + entry.dislike
        } else if entry.category.lowercased().contains(keyword) {
            matched = "🏷️ " + entry.category
        } else if entry.solarDate.lowercased().contains(keyword) {
            matched = "📅 " + entry.solarDate
        }
        cell.detailTextLabel?.text      = matched
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.selectionStyle             = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !filteredEntries.isEmpty else { return }
        let selected = filteredEntries[indexPath.row]
        let sb = UIStoryboard(name: "Main", bundle: nil)

        if let nav = sb.instantiateViewController(withIdentifier: "AddDayNavigation") as? UINavigationController,
           let addVC = nav.topViewController as? AddDay {
            addVC.editingEntry = selected
            addVC.delegate = self
            present(nav, animated: true)
        }
    }
    
    func didSaveBirthday(entry: BirthdayEntry) {
        allEntries.append(entry)
        searchBar(searchInput, textDidChange: searchInput.text ?? "")
    }
    
    func didUpdateBirthday(entry: BirthdayEntry) {
        print("🎯 수정된 항목: \(entry.name), ID: \(entry.id)")
        
        if let idx = allEntries.firstIndex(where: { $0.id == entry.id }) {
            allEntries[idx] = entry
            print("✅ 업데이트 성공 – 인덱스: \(idx)")
        } else {
            print("⚠️ 업데이트 실패 – 해당 ID 없음")
        }

        searchBar(searchInput, textDidChange: searchInput.text ?? "")
    }
    
    func didDeleteBirthday(id: UUID) {
        allEntries.removeAll { $0.id == id }
        searchBar(searchInput, textDidChange: searchInput.text ?? "")
    }
}

