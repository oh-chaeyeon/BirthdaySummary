import UIKit

class ViewController: UIViewController,
                      AddDayDelegate,
                      UICalendarViewDelegate,
                      UICalendarSelectionSingleDateDelegate {

    @IBOutlet weak var lblPickerDay1: UILabel!
    @IBOutlet weak var lblPickerDay2: UILabel!
    @IBOutlet weak var birthdayStackView: UIStackView!
    @IBOutlet weak var calendarContainerView: UIView!
    
    var selectedSolarDate: String?
    var selectedLunarDate: String?
    
    var birthdayEntries: [BirthdayEntry] = []
    var editingEntry:   BirthdayEntry?
    
    private var calendarView: UICalendarView!
    private var singleSel  : UICalendarSelectionSingleDate!   // ★ 선택객체 보관
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthdayEntries = BirthdayDatabase.shared.fetchAll()
        setupCalendarView()
        updateToday()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExternalBirthdayUpdate(_:)),
            name: .birthdayEntryUpdated,
            object: nil
        )
    }
    
    
    @objc func handleExternalBirthdayUpdate(_ notification: Notification) {
        guard let updatedEntry = notification.object as? BirthdayEntry else { return }

        if let i = birthdayEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            birthdayEntries[i] = updatedEntry
        } else {
            birthdayEntries.append(updatedEntry)
        }

        if let selected = selectedSolarDate {
            filterAndDisplayCards(for: selected)
            refreshVisibleDots()
        }
    }

    private func setupCalendarView() {
        calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        
        singleSel = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = singleSel
        
        calendarContainerView.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.topAnchor .constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor)
        ])
        
        let todayComps = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        singleSel.setSelected(todayComps, animated: false)
    }
    
    func calendarView(_ calendarView: UICalendarView,
                      decorationFor dateComps: DateComponents) -> UICalendarView.Decoration? {
        
        guard let date = Calendar.current.date(from: dateComps) else { return nil }
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M월 d일"
        let key = monthDay(from: df.string(from: date))
        
        if let entry = birthdayEntries.first(where: { monthDay(from: $0.solarDate) == key }) {
            let dotColor = UIColor(hex: entry.categoryColorHex)
            return .default(color: dotColor)
        }
        return nil
    }
    
    func dateSelection(_ selection : UICalendarSelectionSingleDate,
                       didSelectDate dateComps: DateComponents?) {
        guard let comps = dateComps,
              let date  = Calendar.current.date(from: comps) else { return }
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M월 d일"
        let solarStr = df.string(from: date)
        
        lblPickerDay1.text  = solarStr
        selectedSolarDate   = solarStr
        
        let lunarCal = Calendar(identifier: .chinese)
        let c = lunarCal.dateComponents([.year,.month,.day], from: date)
        lblPickerDay2.text  = "음력 \(c.year ?? 0)년 \(c.month ?? 0)월 \(c.day ?? 0)일"
        selectedLunarDate   = lblPickerDay2.text
        
        filterAndDisplayCards(for: solarStr)
    }
    
    private func updateToday() {
        let today          = Date()
        let df             = DateFormatter()
        df.locale          = Locale(identifier: "ko_KR")
        df.dateFormat      = "M월 d일"
        let solarStr       = df.string(from: today)
        lblPickerDay1.text = solarStr
        selectedSolarDate  = solarStr
        
        let lunarCal = Calendar(identifier: .chinese)
        let c        = lunarCal.dateComponents([.year,.month,.day], from: today)
        lblPickerDay2.text = "음력 \(c.year ?? 0)년 \(c.month ?? 0)월 \(c.day ?? 0)일"
        selectedLunarDate  = lblPickerDay2.text
        
        filterAndDisplayCards(for: solarStr)
    }
    
    private func monthDay(from formatted: String) -> String {
        if let r = formatted.range(of: "일") { return String(formatted[..<r.upperBound]) }
        return formatted
    }
    
    private func filterAndDisplayCards(for date: String) {
        birthdayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let key = monthDay(from: date)
        birthdayEntries
            .filter { monthDay(from: $0.solarDate) == key }
            .forEach { entry in
                let card = BirthdayCardView()
                card.configure(entry: entry)
                card.onTapped = { [weak self] tapped in
                    self?.editingEntry = tapped
                    self?.performSegue(withIdentifier: "toAddDay", sender: tapped)
                }
                birthdayStackView.addArrangedSubview(card)
            }
    }
    
    @IBAction func addDay(_ sender: UIButton) {
        editingEntry = nil
        performSegue(withIdentifier: "toAddDay", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toAddDay",
              let nav  = segue.destination as? UINavigationController,
              let dest = nav.topViewController as? AddDay else { return }
        
        dest.solarDateText = selectedSolarDate
        dest.lunarDateText = selectedLunarDate
        dest.delegate      = self
        if let e = sender as? BirthdayEntry { dest.editingEntry = e }
    }
    
    private func refreshVisibleDots(animated: Bool = false) {
        guard let monthRange = Calendar.current.dateInterval(of: .month, for: Date()) else { return }
        
        var compsArr: [DateComponents] = []
        var d = monthRange.start
        while d < monthRange.end {
            compsArr.append(Calendar.current.dateComponents([.year,.month,.day], from: d))
            d = Calendar.current.date(byAdding: .day, value: 1, to: d)!
        }
        
        calendarView.reloadDecorations(forDateComponents: compsArr,
                                       animated: animated)
    }

    func didSaveBirthday(entry: BirthdayEntry) {
        birthdayEntries.append(entry)
        filterAndDisplayCards(for: entry.solarDate)
        refreshVisibleDots()
    }
    
    func didUpdateBirthday(entry: BirthdayEntry) {
        if let i = birthdayEntries.firstIndex(where: { $0.id == entry.id }) {
            birthdayEntries[i] = entry
            filterAndDisplayCards(for: entry.solarDate)
        }
        refreshVisibleDots()
    }
    
    func didDeleteBirthday(id: UUID) {
        birthdayEntries.removeAll { $0.id == id }
        if let d = selectedSolarDate { filterAndDisplayCards(for: d) }
        refreshVisibleDots()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .birthdayEntryUpdated, object: nil)
    }

}
