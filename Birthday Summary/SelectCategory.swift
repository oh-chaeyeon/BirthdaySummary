import UIKit

class SelectCategory: UITableViewController {

    @IBOutlet weak var moveSettingbtn: UIBarButtonItem!
    weak var delegate: CategoryPickerDelegate?
    private var list: [CategoryItem] { CategoryStore.shared.sorted() }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { list.count }

    override func tableView(_ tv: UITableView, cellForRowAt idx: IndexPath) -> UITableViewCell {
        let c = tv.dequeueReusableCell(withIdentifier: "catCell", for: idx)
        let it = list[idx.row]
        c.textLabel?.text = it.name
        c.imageView?.image = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate)
        c.imageView?.tintColor = it.color
        return c
    }

    override func tableView(_ tv: UITableView, didSelectRowAt idx: IndexPath) {
        delegate?.didPickCategory(list[idx.row])
        navigationController?.popViewController(animated: true)
    }

    @IBAction func moveToCategorySetting(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let categoryVC = storyboard.instantiateViewController(
                withIdentifier: "CategoryVC") as? Category {
            categoryVC.fromPicker = true
            navigationController?.pushViewController(categoryVC, animated: true)
        }
    }
}
