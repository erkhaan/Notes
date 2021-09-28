import UIKit
import SnapKit
import RealmSwift

protocol NotesDelegate: class {
    func updateNotes()
}

class NotesViewController: UIViewController {

    // MARK: - Properties

    let tableView = UITableView()
    private var notes = List<Note>()
    let lightYellowColor = UIColor(
        red: 253/255,
        green: 249/255,
        blue: 169/255,
        alpha: 1
    )

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
        firstNoteInit()
        configureTableView()
        configureNavigationBar()
    }

    // MARK: - Realm methods

    private func loadNotes() {
        guard let realm = try? Realm() else {
            print("Error opening realm")
            return
        }
        let realmNotes = realm.objects(Note.self)
        notes.append(objectsIn: realmNotes)
    }

    private func saveNotes() {
        guard let realm = try? Realm() else {
            print("Error opening realm")
            return
        }
        do {
            try realm.write {
                realm.add(notes, update: .modified)
            }
        } catch let error as NSError {
            print("Error writing to realm: \(error)")
        }
    }

    private func deleteNote(index: Int) {
        guard let realm = try? Realm() else {
            print("Error opening realm")
            return
        }
        do {
            try realm.write {
                realm.delete(notes[index])
                notes.remove(at: index)
            }
        } catch let error as NSError {
            print("Error deleting note: \(error)")
        }
    }

    // MARK: - Private methods

    private func firstNoteInit() {
        if notes.count == 0 {
            let firstNote = Note(
                // swiftlint:disable:next line_length
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
            )
            notes.append(firstNote)
        }
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.backgroundColor = lightYellowColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        setTableViewConstraints()
    }

    private func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
        }
    }

    private func configureNavigationBar() {
        guard let navigationbar = navigationController?.navigationBar else { return }
        title = "Notes"
        navigationbar.tintColor = .white
        navigationbar.barTintColor = UIColor(
            red: 32/255,
            green: 15/255,
            blue: 8/255,
            alpha: 1
        )
        navigationbar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let addNoteButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addNoteTapped)
        )
        navigationItem.rightBarButtonItem = addNoteButton
    }

    // MARK: - Obj-c methods

    @objc private func addNoteTapped() {
        notes.append(Note(text: "Empty Note"))
        saveNotes()
        tableView.reloadData()
    }
}

// MARK: - Notes Delegate

extension NotesViewController: NotesDelegate {
    func updateNotes() {
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source

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

// MARK: - Table View Delegate

extension NotesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sketchViewController = SketchViewController()
        sketchViewController.delegate = self
        sketchViewController.note = notes[indexPath.row]
        navigationController?.pushViewController(sketchViewController, animated: true)
    }
}
