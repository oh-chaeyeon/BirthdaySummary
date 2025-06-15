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
                selectLunar.text = ""
            } else {
                navigationItem.title  = "정보 추가"
                saveButton.setTitle("저장", for: .normal)
                deleteButton.isHidden = true

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
        selectedAlarm = value
        alarmResultLabel.text = value
    }

    func didPickCategory(_ item: CategoryItem) {
        pickedCategory = item
        refreshCategoryUI()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let nameText = userName.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                 !nameText.isEmpty else {
           let alert = UIAlertController(title: "이름을 입력해주세요",
                                         message: "이름은 필수 항목입니다.",
                                         preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "확인", style: .default))
           present(alert, animated: true)
           return
       }

       let entry = BirthdayEntry(
           id: editingEntry?.id ?? UUID(),
           name: nameText,
           nickname: userNickname.text ?? "",
           categoryID: pickedCategory.id,
           category: pickedCategory.name,
           categoryColorHex: pickedCategory.color.toHexString(),
           solarDate: selectSolar.text ?? "",
           alarm: selectedAlarm ?? "없음",
           like: userLike.textColor == .lightGray ? "" : userLike.text,
           dislike: userDisLike.textColor == .lightGray ? "" : userDisLike.text
       )

       if editingEntry == nil {
           BirthdayDatabase.shared.insert(entry)
           delegate?.didSaveBirthday(entry: entry)

           let today = currentFormattedDate()
           if entry.solarDate == today {
               NotificationManager.shared.schedule(entry: entry, daysBefore: 0, testImmediate: true)
           }
       } else {
           BirthdayDatabase.shared.update(entry)
           delegate?.didUpdateBirthday(entry: entry)
       }

       dismiss(animated: true)
    }

    private func currentFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: Date())
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
       let alert = UIAlertController(
           title: "정말 삭제하시겠습니까?",
           message: "삭제하면 되돌릴 수 없습니다.",
           preferredStyle: .alert
       )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            guard let editing = self.editingEntry else { return }
            BirthdayDatabase.shared.delete(id: editing.id)
            self.delegate?.didDeleteBirthday(id: editing.id)
            self.dismiss(animated: true)
        }

       let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
       
       alert.addAction(deleteAction)
       alert.addAction(cancelAction)
       
       present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectCategory" {
            if let nav = segue.destination as? UINavigationController,
               let catVC = nav.topViewController as? SelectCategory {
                catVC.delegate = self
            } else if let catVC = segue.destination as? SelectCategory {
                catVC.delegate = self
            }

        } else if segue.identifier == "toAlarm" {
            if let nav = segue.destination as? UINavigationController,
               let alarmVC = nav.topViewController as? SelectAlarm {
                alarmVC.delegate = self
            } else if let alarmVC = segue.destination as? SelectAlarm {
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
