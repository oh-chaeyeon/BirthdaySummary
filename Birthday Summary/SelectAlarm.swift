import UIKit

protocol AlarmDelegate: AnyObject {
    func didSelectAlarm(_ value: String)
}

class SelectAlarm: UITableViewController {

    @IBOutlet weak var IbISwitch: UILabel!
    @IBOutlet weak var useSelect: UISwitch!
    
    @IBOutlet weak var alarmOption1: UIView!
    @IBOutlet weak var alarmOption2: UIView!
    @IBOutlet weak var alarmOption3: UIView!
    @IBOutlet weak var alarmOption4: UIView!
    
    @IBOutlet weak var labelOption1: UILabel!
    @IBOutlet weak var labelOption2: UILabel!
    @IBOutlet weak var labelOption3: UILabel!
    @IBOutlet weak var labelOption4: UILabel!
    
    weak var delegate: AlarmDelegate?
 
    var selectedOptions: Set<Int> = []
    var labels: [UILabel] = []
    var views: [UIView] = []
    
    let options = ["당일", "하루전", "일주일전", "한달전"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labels = [labelOption1, labelOption2, labelOption3, labelOption4]
        views = [alarmOption1, alarmOption2, alarmOption3, alarmOption4]

        setupOptionsUI()
        updateAlarmOptionsEnabledState()
    }

    @IBAction func useSelectChanged(_ sender: UISwitch) {
        updateAlarmOptionsEnabledState()
    }
    
    func updateAlarmOptionsEnabledState() {
        let enabled = useSelect.isOn

        IbISwitch.text = enabled ? "사용 중" : "선택안함"

        for (index, view) in views.enumerated() {
            view.alpha = enabled ? 1.0 : 0.3
            view.isUserInteractionEnabled = enabled
            labels[index].alpha = enabled ? 1.0 : 0.3
        }

        if !enabled {
            selectedOptions.removeAll()
        }

        updateOptionUI()
    }

    func setupOptionsUI() {
        for (index, view) in views.enumerated() {
            view.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            view.addGestureRecognizer(tap)
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
        }

        for (index, label) in labels.enumerated() {
            label.text = options[index]
            label.isUserInteractionEnabled = false
        }
    }
    
    @objc func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }

        if selectedOptions.contains(index) {
            selectedOptions.remove(index)
        } else {
            selectedOptions.insert(index)
        }

        updateOptionUI()
    }

    func updateOptionUI() {
        for (index, view) in views.enumerated() {
            if selectedOptions.contains(index) {
                view.layer.borderColor = UIColor.systemBlue.cgColor
                view.layer.borderWidth = 2
                view.backgroundColor = UIColor.systemGray6
            } else {
                view.layer.borderWidth = 0
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    @IBAction func alarmSaveTapped(_ sender: UIButton) {
        print("✅ 저장 버튼 눌림")
        
        if useSelect.isOn {
            let selectedAlarms = selectedOptions.sorted().map { options[$0] }.joined(separator: ", ")
            print("✅ 전달할 알람 값: \(selectedAlarms)")
            delegate?.didSelectAlarm(selectedAlarms)
        } else {
            delegate?.didSelectAlarm("선택안함")
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func alarmCancelTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
