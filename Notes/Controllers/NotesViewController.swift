import UIKit
import SnapKit
import RealmSwift

protocol NotesDelegate: class {
    func updateNotes()
}

class NotesViewController: UIViewController {

    // MARK: Properties

    let tableView = UITableView()
    var notes: [Note] = [
        Note(text: "Sample note SampkeyboardFrameKeyle Note")
    ]
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
        notes.append(Note(text: "Empty Note"))
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
        cell.textLabel?.text = notes[indexPath.row].text
        cell.backgroundColor = lightYellowColor
        return cell
    }
}

// MARK: Table View Delegate

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sketchViewcontroller = SketchViewController()
        sketchViewcontroller.note = notes[indexPath.row]
        sketchViewcontroller.delegate = self
        navigationController?.pushViewController(sketchViewcontroller, animated: true)
    }
}

// MARK: Notes Delegate

extension NotesViewController: NotesDelegate {
    func updateNotes() {
        tableView.reloadData()
    }
}
