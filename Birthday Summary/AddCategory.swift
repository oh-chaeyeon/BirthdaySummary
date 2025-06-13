import UIKit

class AddCategory: UIViewController {

    @IBOutlet weak var changeColor: UIColorWell!
    @IBOutlet weak var colorName: UILabel!
    @IBOutlet weak var tfAddCategory: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var categoryColor: UIColor?
    var categoryName: String?

    var isEditingCategory: Bool = false
    var initialColor: UIColor?
    var initialName: String?
    
    var editingItem: CategoryItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeColor.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
        
        if let item = editingItem {
            tfAddCategory.text   = item.name
            changeColor.selectedColor = item.color
            saveButton.setTitle("수정", for:.normal)
            colorName.text = item.color.toHexString()
        }
    }
    
    @objc func colorChanged(_ sender: UIColorWell) {
        if let color = sender.selectedColor {
            colorName.text = color.toHexString()
        } else {
            colorName.text = "선택 없음"
        }
    }
    
    @IBAction func saveTapped(_ sender:UIButton){
        guard let name = tfAddCategory.text, !name.isEmpty,
              let color = changeColor.selectedColor else { return }

        let item = CategoryItem(id: editingItem?.id ?? UUID(),
                                name: name, color: color)

        if editingItem != nil {
            CategoryStore.shared.update(item)
        } else {
            CategoryStore.shared.add(item)
        }
    }
}
