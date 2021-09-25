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
        configureTextView()
        setTextViewConstraints()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(updateKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(updateKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

    }

    // MARK: Private methods

    @objc private func updateKeyboard(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrameKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardValue = userInfo?[keyboardFrameKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height,
                right: 0
            )
        }
        textView.scrollIndicatorInsets = textView.contentInset
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }

    private func configureTextView() {
        textView.backgroundColor = UIColor(
            red: 253/255,
            green: 249/255,
            blue: 169/255,
            alpha: 1
        )
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.text = note.text
        textView.delegate = self
    }

    private func setTextViewConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalTo(0)
        }
    }

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
