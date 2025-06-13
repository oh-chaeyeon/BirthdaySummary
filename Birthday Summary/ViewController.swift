import UIKit

class ViewController: UIViewController, AddDayDelegate  {

    @IBOutlet weak var lblPickerDay1: UILabel!
    @IBOutlet weak var lblPickerDay2: UILabel!
    @IBOutlet weak var birthdayStackView: UIStackView!
    
    var selectedSolarDate: String?
    var selectedLunarDate: String?
    
    var birthdayEntries: [BirthdayEntry] = []
    var editingEntry: BirthdayEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthdayEntries = BirthdayDatabase.shared.fetchAll()
        print("📋 현재 DB에 저장된 생일 수: \(birthdayEntries.count)")
        
        updateToday()
    }
    
    func updateToday() {
        let today = Date()
        let solarFormatter = DateFormatter()
        solarFormatter.locale = Locale(identifier: "ko_KR")
        solarFormatter.dateFormat = "M월 d일 E"

        let solarString = solarFormatter.string(from: today)
        lblPickerDay1.text = solarString
        selectedSolarDate = solarString

        let lunarCalendar = Calendar(identifier: .chinese)
        let lunarComponents = lunarCalendar.dateComponents([.year, .month, .day], from: today)
        let lunarString = "음력 \(lunarComponents.year ?? 0)년 \(lunarComponents.month ?? 0)월 \(lunarComponents.day ?? 0)일"
        lblPickerDay2.text = lunarString
        selectedLunarDate = lunarString

        filterAndDisplayCards(for: solarString)
    }

    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let solarFormatter = DateFormatter()
            solarFormatter.locale = Locale(identifier: "ko_KR")
            solarFormatter.dateFormat = "M월 d일 E"

            let solarString = solarFormatter.string(from: sender.date)
            lblPickerDay1.text = solarString
            selectedSolarDate = solarString

            let chineseCalendar = Calendar(identifier: .chinese)
            let components = chineseCalendar.dateComponents([.year, .month, .day], from: sender.date)
            lblPickerDay2.text = "음력 \(components.year ?? 0)년 \(components.month ?? 0)월 \(components.day ?? 0)일"
            selectedLunarDate = lblPickerDay2.text

            filterAndDisplayCards(for: solarString)
    }
    
    @IBAction func addDay(_ sender: UIButton) {
        editingEntry = nil
        performSegue(withIdentifier: "toAddDay", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddDay" {
            if let nav = segue.destination as? UINavigationController,
               let destination = nav.topViewController as? AddDay {
                destination.solarDateText = selectedSolarDate
                destination.lunarDateText = selectedLunarDate
                destination.delegate = self
                if let editing = sender as? BirthdayEntry {
                    destination.editingEntry = editing
                }
            }
        }
    }

    private func monthDay(from formatted: String) -> String {
        if let range = formatted.range(of: "일") {
            return String(formatted[..<range.upperBound])
        }
        return formatted
    }

    func filterAndDisplayCards(for date: String) {
        birthdayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let key = monthDay(from: date)
        let matched = birthdayEntries.filter {
            monthDay(from: $0.solarDate) == key
        }

        matched.forEach { entry in
            let card = BirthdayCardView()
            card.configure(entry: entry)
            card.onTapped = { [weak self] tapped in
                self?.editingEntry = tapped
                self?.performSegue(withIdentifier: "toAddDay", sender: tapped)
            }
            birthdayStackView.addArrangedSubview(card)
        }
    }
    
    func didSaveBirthday(categoryItem: CategoryItem, name: String, nickname: String){
        guard let date = selectedSolarDate else { return }
        let newEntry = BirthdayEntry(
            id: UUID(),
            name: name,
            nickname: nickname,
            categoryID: categoryItem.id,
            category: categoryItem.name,
            categoryColorHex: categoryItem.color.toHexString(),
            solarDate: date,
            alarm: "없음",
            like: "",
            dislike: ""
        )
        birthdayEntries.append(newEntry)
        filterAndDisplayCards(for: date)
    }

    func didSaveBirthday(entry: BirthdayEntry) {
        birthdayEntries.append(entry)
        filterAndDisplayCards(for: entry.solarDate)
    }

    func didUpdateBirthday(entry: BirthdayEntry) {
        if let idx = birthdayEntries.firstIndex(where: { $0.id == entry.id }) {
            birthdayEntries[idx] = entry
            filterAndDisplayCards(for: entry.solarDate)
        }
    }

    func didDeleteBirthday(id: UUID) {
        birthdayEntries.removeAll { $0.id == id }
        filterAndDisplayCards(for: selectedSolarDate ?? "")
    }
}
