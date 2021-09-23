import UIKit
import SnapKit

class NotesViewController: UIViewController {

    // MARK: Properties

    let tableView = UITableView()
    var notes = ["New note New note New note New note New note New note New note New note New note New note"]
    let lightYellowColor = UIColor(
        red: 253/255,
        green: 249/255,
        blue: 169/255,
        alpha: 1
    )

    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureTableView()
        setTableViewConstraints()
    }

    // MARK: Private methods

    private func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = lightYellowColor
        tableView.separatorInset = .zero
        view.addSubview(tableView)
    }

    private func configureNavigationBar() {
        title = "Notes"
        let addNoteButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addNoteTapped)
        )
        navigationItem.rightBarButtonItem = addNoteButton
        navigationController?.navigationBar.barTintColor = UIColor(
            red: 32/255,
            green: 15/255,
            blue: 8/255,
            alpha: 1
        )
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    @objc private func addNoteTapped() {
        notes.append("Empty Note")
        tableView.reloadData()
    }
}

// MARK: Table View Data Source

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row]
        cell.backgroundColor = lightYellowColor
        return cell
    }
}

// MARK: Table View Delegate

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sketchViewcontroller = SketchViewController()
        sketchViewcontroller.textView.text = notes[indexPath.row]
        navigationController?.pushViewController(sketchViewcontroller, animated: true)
    }
}
