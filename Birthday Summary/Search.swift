import UIKit

class Search: UITableViewController, UISearchBarDelegate, AddDayDelegate {
    
    @IBOutlet weak var searchInput: UISearchBar!
    
        private var allEntries:      [BirthdayEntry]           = []
        private var groupedEntries:  [String:[BirthdayEntry]]  = [:]
        private var sectionTitles:   [String]                  = []

        override func viewDidLoad() {
            super.viewDidLoad()
            searchInput.delegate = self
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            allEntries = BirthdayDatabase.shared.fetchAll()
            applyFilter(keyword: searchInput.text ?? "")
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
            applyFilter(keyword: text)
        }

        private func applyFilter(keyword raw: String) {
            let keyword = raw.lowercased()
            
            let filtered: [BirthdayEntry] = {
                guard !keyword.isEmpty else { return allEntries }
                return allEntries.filter {
                    $0.name.lowercased()     .contains(keyword) ||
                    $0.nickname.lowercased() .contains(keyword) ||
                    $0.category.lowercased() .contains(keyword) ||
                    $0.like.lowercased()     .contains(keyword) ||
                    $0.dislike.lowercased()  .contains(keyword) ||
                    $0.solarDate.lowercased().contains(keyword)
                }
            }()

            groupedEntries = Dictionary(grouping: filtered) { $0.category }

            sectionTitles = groupedEntries.keys.sorted()

            tableView.reloadData()
        }

        override func numberOfSections(in tableView: UITableView) -> Int {
           
            return groupedEntries.isEmpty ? 1 : sectionTitles.count
        }

        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
            guard !groupedEntries.isEmpty else { return 1 }
            let key = sectionTitles[section]
            return groupedEntries[key]?.count ?? 0
        }

        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
            return groupedEntries.isEmpty ? nil : sectionTitles[section]
        }

        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            if groupedEntries.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
                cell.textLabel?.text          = "검색 결과가 없어요 😥"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor     = .systemGray
                cell.detailTextLabel?.text    = nil
                cell.selectionStyle           = .none
                return cell
            }

            let cell  = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
            let key   = sectionTitles[indexPath.section]
            let entry = groupedEntries[key]![indexPath.row]
            let kw    = (searchInput.text ?? "").lowercased()

            let nick = entry.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            let base = nick.isEmpty ? entry.name : "\(entry.name) (\(nick))"

            let attr = NSMutableAttributedString(string: base,
                                                 attributes: [.foregroundColor: UIColor.label])

            if !kw.isEmpty, let range = base.lowercased().range(of: kw) {
                let nsRange = NSRange(range, in: base)
                attr.addAttributes([
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.boldSystemFont(ofSize: 17)
                ], range: nsRange)
            }
            cell.textLabel?.attributedText = attr

            var subtitle = ""
            if entry.like.lowercased().contains(kw)      { subtitle = "❤️ " + entry.like      }
            else if entry.dislike.lowercased().contains(kw) { subtitle = "💀 " + entry.dislike }
            else if entry.solarDate.lowercased().contains(kw) { subtitle = "📅 " + entry.solarDate }
            cell.detailTextLabel?.text      = subtitle
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.selectionStyle             = .none
            return cell
        }

        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
            guard !groupedEntries.isEmpty else { return }
            let key     = sectionTitles[indexPath.section]
            let entry   = groupedEntries[key]![indexPath.row]

            let sb      = UIStoryboard(name: "Main", bundle: nil)
            guard let nav  = sb.instantiateViewController(withIdentifier: "AddDayNavigation") as? UINavigationController,
                  let add  = nav.topViewController as? AddDay else { return }
            add.editingEntry = entry
            add.delegate     = self
            present(nav, animated: true)
        }

        func didSaveBirthday(entry: BirthdayEntry)   { allEntries.append(entry); applyFilter(keyword: searchInput.text ?? "") }
        func didUpdateBirthday(entry: BirthdayEntry) { if let i = allEntries.firstIndex(where: { $0.id == entry.id }) { allEntries[i] = entry }; applyFilter(keyword: searchInput.text ?? "") }
        func didDeleteBirthday(id: UUID)             { allEntries.removeAll { $0.id == id }; applyFilter(keyword: searchInput.text ?? "") }
    }
