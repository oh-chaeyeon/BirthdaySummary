import UIKit

protocol CategoryPickerDelegate: AnyObject {
    func didPickCategory(_ item: CategoryItem)
}

class Category: UITableViewController {
    
    @IBOutlet var tvListView: UITableView!
    @IBOutlet weak var deleteBtnBarItem: UIBarButtonItem!

    var fromPicker: Bool = false
    private var list: [CategoryItem] = CategoryStore.shared.sorted()

    override func viewDidLoad() {
        super.viewDidLoad()

        if fromPicker {
            deleteBtnBarItem.title = "이전"
            deleteBtnBarItem.style = .plain
            deleteBtnBarItem.target = self
            deleteBtnBarItem.action = #selector(backToPicker)
        }
    }
    
    @objc private func backToPicker() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = CategoryStore.shared.sorted()
        tableView.reloadData()
    }
    
   override func tableView(_ tv: UITableView, numberOfRowsInSection s: Int)->Int { list.count }

   override func tableView(_ tv: UITableView, cellForRowAt index: IndexPath)->UITableViewCell {
       let cell = tv.dequeueReusableCell(withIdentifier:"myCell", for:index)
       let item = list[index.row]
       cell.textLabel?.text = item.name
       cell.imageView?.image = UIImage(systemName:"circle.fill")?.withRenderingMode(.alwaysTemplate)
       cell.imageView?.tintColor = item.color
       return cell
   }

   override func tableView(_ tv:UITableView, canEditRowAt idx:IndexPath)->Bool {
       list[idx.row].name != "기타"
   }
    
    override func tableView(_ tv:UITableView,
                            commit editingStyle:UITableViewCell.EditingStyle,
                            forRowAt idx:IndexPath){
        if editingStyle == .delete {
            let id = list[idx.row].id
            CategoryStore.shared.delete(id: id)
            list.remove(at: idx.row)
            tv.deleteRows(at: [idx], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = list[indexPath.row]
        
        if selectedItem.name == "기타" {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddCategory",
           let dest = segue.destination as? AddCategory,
           let indexPath = tableView.indexPathForSelectedRow {
            dest.editingItem = list[indexPath.row]
        } else if segue.identifier == "toAddNewCategory",
            let dest = segue.destination as? AddCategory {
            dest.editingItem = nil
        }
    }

    @IBAction func unwindFromAdd(_ sg:UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBAction func deleteBtn(_ sender: UIBarButtonItem) {
        guard !fromPicker else { return } 
        let editingNow = !isEditing
        setEditing(editingNow, animated: true)
        sender.title = editingNow ? "Done" : "Delete"
    }
    
}
