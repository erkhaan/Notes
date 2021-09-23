import UIKit
import SnapKit

class NotesViewController: UIViewController {

    // MARK: Properties
    let tableView = UITableView()
    var notes = ["Newe notewwqe"]

    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
        view.addSubview(tableView)
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
        return cell
    }
}

// MARK: Table View Delegate

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
