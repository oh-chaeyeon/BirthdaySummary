import UIKit

protocol AddDayDelegate: AnyObject {
    func didSaveBirthday(entry: BirthdayEntry)
    func didUpdateBirthday(entry: BirthdayEntry)
    func didDeleteBirthday(id: UUID)
}

class AddDay: UITableViewController,
              UITextViewDelegate,
              AlarmDelegate,
              CategoryPickerDelegate {

    @IBOutlet weak var selectSolar:  UILabel!
    @IBOutlet weak var selectLunar:  UILabel!

    @IBOutlet weak var userName:     UITextField!
    @IBOutlet weak var userNickname: UITextField!
    @IBOutlet weak var userLike:     UITextView!
    @IBOutlet weak var userDisLike:  UITextView!

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var alarmResultLabel: UILabel!

    @IBOutlet weak var saveButton:   UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var solarDateText:  String?
    var lunarDateText:  String?

    var selectedAlarm:  String?
    private var pickedCategory: CategoryItem = CategoryStore.shared.items.last!

    weak var delegate: AddDayDelegate?
    var editingEntry: BirthdayEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView      = nil
        tableView.sectionHeaderHeight  = .leastNormalMagnitude

        selectSolar.text = solarDateText
        selectLunar.text = lunarDateText

        [userLike, userDisLike].forEach {
            $0?.delegate = self
            setupTextView($0!, placeholder: "여기에 적어주세요")
        }

        if let entry = editingEntry {
                navigationItem.title  = "정보 수정"
                saveButton.setTitle("수정 완료", for: .normal)
                deleteButton.isHidden = false

                userName.text     = entry.name
                userNickname.text = entry.nickname

                pickedCategory = CategoryStore.shared.items.first{ $0.id == entry.categoryID }
                                ?? pickedCategory

                selectedAlarm       = entry.alarm
                alarmResultLabel.text = entry.alarm

                setText(userLike,    entry.like)
                setText(userDisLike, entry.dislike)

                selectSolar.text = entry.solarDate
                selectLunar.text = "(음력 변환 예정)"
            } else {
                navigationItem.title  = "정보 추가"
                saveButton.setTitle("저장", for: .normal)
                deleteButton.isHidden = true

                // ‘추가’ 모드일 땐 처음에 전달된 날짜 보여주기
                selectSolar.text = solarDateText
                selectLunar.text = lunarDateText
            }
        refreshCategoryUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCategoryUI()
    }

    private func refreshCategoryUI() {
        categoryLabel.text      = pickedCategory.name
        categoryLabel.textColor = pickedCategory.color
    }

    private func setupTextView(_ tv:UITextView, placeholder:String){
        tv.text      = placeholder
        tv.textColor = .lightGray
    }
    
    private func setText(_ tv:UITextView, _ txt:String){
        tv.text      = txt.isEmpty ? "여기에 적어주세요" : txt
        tv.textColor = txt.isEmpty ? .lightGray : .label
    }
    
    func textViewDidBeginEditing(_ tv:UITextView){
        if tv.textColor == .lightGray { tv.text = ""; tv.textColor = .label }
    }
    
    func textViewDidEndEditing(_ tv:UITextView){
        if tv.text.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty {
            tv.text = "여기에 적어주세요"; tv.textColor = .lightGray
        }
    }

    func didSelectAlarm(_ value:String){
        print("📌 AddDay에서 받은 알람 값: \(value)")
        selectedAlarm = value
        alarmResultLabel.text = value
    }

    func didPickCategory(_ item: CategoryItem) {
        print("✅ 선택된 카테고리: \(item.name), 색상: \(item.color.toHexString())")

        pickedCategory = item
        refreshCategoryUI()
    }

    // MARK: - 저장·삭제
    @IBAction func saveButtonTapped(_ sender: UIButton) {

        let entry = BirthdayEntry(
            id:          editingEntry?.id ?? UUID(),
            name:        userName.text ?? "",
            nickname:    userNickname.text ?? "",
            categoryID:  pickedCategory.id,
            category:    pickedCategory.name,
            categoryColorHex: pickedCategory.color.toHexString(),
            solarDate:   selectSolar.text ?? "",
            alarm:       selectedAlarm ?? "없음",
            like:        userLike.textColor == .lightGray ? "" : userLike.text,
            dislike:     userDisLike.textColor == .lightGray ? "" : userDisLike.text
        )

        if editingEntry == nil {
            BirthdayDatabase.shared.insert(entry)
            delegate?.didSaveBirthday(entry: entry)
        } else {
            BirthdayDatabase.shared.update(entry)
            delegate?.didUpdateBirthday(entry: entry)
        }
        dismiss(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        guard let editing = editingEntry else { return }
        BirthdayDatabase.shared.delete(id: editing.id)
        delegate?.didDeleteBirthday(id: editing.id)
        dismiss(animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectCategory" {
            if let nav = segue.destination as? UINavigationController,
               let catVC = nav.topViewController as? SelectCategory {
                print("📦 delegate 연결: NavigationController → SelectCategory")
                catVC.delegate = self
            } else if let catVC = segue.destination as? SelectCategory {
                print("📦 delegate 연결: Direct → SelectCategory")
                catVC.delegate = self
            }

        } else if segue.identifier == "toAlarm" {
            if let nav = segue.destination as? UINavigationController,
               let alarmVC = nav.topViewController as? SelectAlarm {
                print("🔔 delegate 연결: NavigationController → SelectAlarm")
                alarmVC.delegate = self
            } else if let alarmVC = segue.destination as? SelectAlarm {
                print("🔔 delegate 연결: Direct → SelectAlarm")
                alarmVC.delegate = self
            }
        }
    }

    @IBAction func cancelBtn(_ sender: UIButton) {
        dismiss(animated:true)
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated:true)
    }
}
