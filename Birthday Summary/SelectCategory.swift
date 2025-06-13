import UIKit

class SelectCategory: UITableViewController {

    weak var delegate: CategoryPickerDelegate?
    private var list:[CategoryItem] { CategoryStore.shared.sorted() }

    override func tableView(_ tv:UITableView, numberOfRowsInSection s:Int)->Int { list.count }

    override func tableView(_ tv:UITableView, cellForRowAt idx:IndexPath)->UITableViewCell {
        let c = tv.dequeueReusableCell(withIdentifier:"catCell", for:idx)
        let it = list[idx.row]
        c.textLabel?.text = it.name
        c.imageView?.image = UIImage(systemName:"circle.fill")?.withRenderingMode(.alwaysTemplate)
        c.imageView?.tintColor = it.color
        return c
    }

    override func tableView(_ tv:UITableView, didSelectRowAt idx:IndexPath){
        delegate?.didPickCategory(list[idx.row])
        navigationController?.popViewController(animated:true)
    }
}

