import UIKit
import SnapKit

class SketchViewController: UIViewController {

    // MARK: Properties

    let textView = UITextView()
    weak var delegate: NotesDelegate?
    var note: Note!

    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        view.backgroundColor = .white
        textView.backgroundColor = UIColor(red: 253/255, green: 249/255, blue: 169/255, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.text = note.text
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalTo(0)
        }
    }

    // MARK: Private methods

    private func updateNote() {
        delegate?.updateNotes()
    }
}

// MARK: Text View Delegate

extension SketchViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            note.text = "Empty note"
        } else {
            note.text = textView.text
        }
        updateNote()
    }
}
