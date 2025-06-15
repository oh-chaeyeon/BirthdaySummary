import UIKit

final class Schedule: UITableViewController, AddDayDelegate {

    private enum SortMode: Int { case byDate = 0, byRecent }
    private var sortMode: SortMode = .byDate
    private var grouped: [(date: String, entries: [BirthdayEntry])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(BirthdayCardCell.self,
                           forCellReuseIdentifier: BirthdayCardCell.identifier)
        tableView.separatorStyle      = .none
        tableView.sectionHeaderHeight = 36
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(customView: makeSegment())
        
        reloadAndGroup()
    }
    
    private func makeSegment() -> UISegmentedControl {
        let seg = UISegmentedControl(items: ["날짜순", "최근추가"])
        seg.selectedSegmentIndex = sortMode.rawValue
        seg.addTarget(self, action: #selector(segChanged(_:)), for: .valueChanged)
        return seg
    }
    
    @objc private func segChanged(_ sender: UISegmentedControl) {
        sortMode = SortMode(rawValue: sender.selectedSegmentIndex) ?? .byDate
        reloadAndGroup()
    }
    
    private func reloadAndGroup() {
        
        let all = BirthdayDatabase.shared.fetchAll()
        let df        = DateFormatter()
        df.locale     = Locale(identifier: "ko_KR")
        df.dateFormat = "M월 d일"
        let todayKey  = df.string(from: Date())
  
        let dict  = Dictionary(grouping: all) { $0.solarDate }
        var temp: [(date: String, entries: [BirthdayEntry])] =
            dict.map { (date: $0.key, entries: $0.value) }

        func monthDay(_ str: String) -> (Int, Int) {
            let m = Int(str.split(separator: "월")[0].trimmingCharacters(in: .whitespaces)) ?? 0
            let d = Int(str.split(separator: "월")[1]
                           .split(separator: "일")[0]
                           .trimmingCharacters(in: .whitespaces)) ?? 0
            return (m, d)
        }

        switch sortMode {
        case .byDate:
            temp.sort {
                let a = monthDay($0.date), b = monthDay($1.date)
                return a.0 == b.0 ? a.1 < b.1 : a.0 < b.0
            }
        case .byRecent:
            temp.sort {
                let idA = $0.entries.max(by: { $0.id.uuidString < $1.id.uuidString })?.id.uuidString ?? ""
                let idB = $1.entries.max(by: { $0.id.uuidString < $1.id.uuidString })?.id.uuidString ?? ""
                return idA > idB
            }
        }
        
        if let idx = temp.firstIndex(where: { $0.date.hasPrefix(todayKey) }) {
            let today = temp.remove(at: idx)
            temp.insert(("🎂 오늘 생일", today.entries), at: 0)
        }
        
        grouped = temp
        tableView.reloadData()
    }
    
    func didSaveBirthday(entry: BirthdayEntry)   { reloadAndGroup() }
    func didUpdateBirthday(entry: BirthdayEntry) { reloadAndGroup() }
    func didDeleteBirthday(id: UUID) {
        reloadAndGroup()
    }

    
    override func numberOfSections(in _: UITableView) -> Int { grouped.count }
    
    override func tableView(_ tv: UITableView,
                            titleForHeaderInSection s: Int) -> String? {
        grouped[s].date
    }
    
    override func tableView(_ tv: UITableView,
                            numberOfRowsInSection s: Int) -> Int {
        grouped[s].entries.count
    }
    
    override func tableView(_ tv: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: BirthdayCardCell.identifier,
                                          for: indexPath) as! BirthdayCardCell
        let entry = grouped[indexPath.section].entries[indexPath.row]
        cell.configure(with: entry)
        
        cell.cardView.backgroundColor =
            indexPath.section == 0 && grouped[0].date.hasPrefix("🎂")
            ? UIColor.systemPink.withAlphaComponent(0.15)
            : entry.categoryColor.withAlphaComponent(0.10)
        
        cell.onCardTapped = { [weak self] in self?.presentAddDay(for: $0) }
        return cell
    }

    override func tableView(_ tv: UITableView, didSelectRowAt i: IndexPath) {
        presentAddDay(for: grouped[i.section].entries[i.row])
    }
    
    private func presentAddDay(for e: BirthdayEntry) {
        guard let nav = storyboard?.instantiateViewController(
                withIdentifier: "AddDayNavigation") as? UINavigationController,
              let add = nav.topViewController as? AddDay else { return }
        add.editingEntry = e
        add.delegate     = self
        present(nav, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAndGroup()         
    }
}
