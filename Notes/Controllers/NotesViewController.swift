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
        firstListInit()
        configureNavigationBar()
        configureTableView()
        setTableViewConstraints()
    }

    // MARK: - Realm methods

    private func firstListInit() {
        if notes.count == 0 {
            let firstNote = Note(text: "Sample note note note note note note note note note")
            notes.append(firstNote)
        }
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

    private func loadNotes() {
        guard let realm = try? Realm() else {
            print("Error opening realm")
            return
        }
        let realmNotes = realm.objects(Note.self)
        notes.append(objectsIn: realmNotes)
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
        saveNotes()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sketchViewcontroller = SketchViewController()
        sketchViewcontroller.note = notes[indexPath.row]
        sketchViewcontroller.delegate = self
        navigationController?.pushViewController(sketchViewcontroller, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Notes Delegate

extension NotesViewController: NotesDelegate {
    func updateNotes() {
        tableView.reloadData()
    }
}
