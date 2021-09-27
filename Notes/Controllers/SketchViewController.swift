import UIKit
import SnapKit
import RealmSwift

class SketchViewController: UIViewController {

    // MARK: - Properties

    let textView = UITextView()
    weak var delegate: NotesDelegate?
    var note: Note!
    var fontSize: CGFloat = 20
    var fontName: String = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
    let fontSizeLabel = UILabel()

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        configureTextView()
        setTextViewConstraints()
        configureNotificationCenter()
        configureToolbar()
        configureNavigationBar()
    }

    // MARK: - Private methods

    private func configureNavigationBar() {
        let addImageButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.rectangle"),
            style: .plain,
            target: self,
            action: #selector(addImageTapped)
        )
        navigationItem.rightBarButtonItem = addImageButton
    }

    private func configureNotificationCenter() {
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

    private func configureToolbar() {
        let textEditToolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 30
            )
        )
        let fontPicker = UIButton()
        let fontSizeStepper = UIStepper()
        configureFontPicker(fontPicker)
        configureFontSizeStepper(fontSizeStepper)
        textEditToolbar.items = [
            UIBarButtonItem(
                title: "Select Font",
                style: .plain,
                target: self,
                action: #selector(fontPickerTapped)
            ),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: fontSizeLabel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: fontSizeStepper)
        ]
        textEditToolbar.sizeToFit()
        textEditToolbar.barStyle = .default
        textView.inputAccessoryView = textEditToolbar
    }

    private func configureFontPicker(_ button: UIButton) {
        button.addTarget(
            self,
            action: #selector(fontPickerTapped),
            for: .touchUpInside
        )
    }

    private func configureFontSizeStepper(_ stepper: UIStepper) {
        stepper.value = Double(fontSize)
        stepper.addTarget(self, action: #selector(fontSizeChanged(_:)), for: .valueChanged)
        stepper.minimumValue = 1
        fontSizeLabel.text = "\(Int(stepper.value)) pt"
        fontSizeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    }

    private func configureTextView() {
        textView.backgroundColor = UIColor(
            red: 253/255,
            green: 249/255,
            blue: 169/255,
            alpha: 1
        )
        if note.data != nil {
            do {
                try textView.attributedText = NSAttributedString(
                    data: note.data!,
                    options: [.documentType: NSAttributedString.DocumentType.rtfd],
                    documentAttributes: nil
                )
            } catch let error as NSError {
                print("Error decoding NSAttributedString from data: \(error)")
            }
        } else {
            textView.text = note.text
            textView.font = UIFont.systemFont(ofSize: fontSize)
        }
        textView.delegate = self
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        setFontSize()
    }

    private func setFontSize() {
        guard let curFont = textView.typingAttributes[.font] as? UIFont else { return }
        fontSize = curFont.pointSize
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

    // MARK: - Obj-c methods

    @objc private func addImageTapped() {
        guard let image = UIImage(named: "placeholder") else { return }
        let imageWidth = image.size.width
        let textViewWidth = textView.frame.size.width
        let attachment = NSTextAttachment()
        if imageWidth > textViewWidth {
            let scale = imageWidth / (textViewWidth - 20)
            guard let cgImage = image.cgImage else {
                print("Error opening cgImage")
                return
            }
            let scaledImage = UIImage(
                cgImage: cgImage,
                scale: scale,
                orientation: .up
            )
            attachment.image = scaledImage
        } else {
            attachment.image = image
        }
        let attributedString = NSAttributedString(attachment: attachment)
        textView.textStorage.insert(attributedString, at: textView.selectedRange.location)
    }

    @objc private func fontSizeChanged(_ stepper: UIStepper) {
        fontSize = CGFloat(stepper.value)
        fontSizeLabel.text = "\(Int(stepper.value)) pt"
        guard let curFont = textView.typingAttributes[.font] as? UIFont else { return }
        fontName = curFont.fontName
        guard var newFont = UIFont(name: fontName, size: fontSize) else {
            print("Font error")
            return
        }
        if fontName == ".SFUI-Regular" {
            newFont = UIFont.systemFont(ofSize: fontSize)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: newFont
        ]
        textView.typingAttributes = attributes
    }

    @objc private func fontPickerTapped() {
        let vc = UIFontPickerViewController()
        vc.delegate = self
        present(vc, animated: true)
    }

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
}

// MARK: - Text View Delegate

extension SketchViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let realm = try? Realm() else {
            print("Error opening realm")
            return
        }
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                try realm.write {
                    note.text = "Empty note"
                }
            } catch let error as NSError {
                print("Error writing to realm: \(error)")
            }
        } else {
            do {
                guard let attributedText = textView.attributedText else { return }
                guard let data = try? attributedText.data(
                    from: NSRange(
                        location: 0,
                        length: attributedText.length
                    ),
                    documentAttributes: [
                        .documentType: NSAttributedString.DocumentType.rtfd
                    ]
                ) else {
                    return
                }
                try realm.write {
                    note.text = textView.text
                    note.data = data
                }
            } catch let error as NSError {
                print("Error writing to realm: \(error)")
            }
        }
        updateNote()
    }
}

// MARK: - Font Picker Delegate

extension SketchViewController: UIFontPickerViewControllerDelegate {
    func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
        viewController.dismiss(
            animated: true,
            completion: nil
        )
    }

    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        viewController.dismiss(
            animated: true,
            completion: nil
        )
        guard let descriptor = viewController.selectedFontDescriptor else { return }
        let newFont = UIFont(descriptor: descriptor, size: fontSize)
        fontName = newFont.fontName
        let attributes: [NSAttributedString.Key: Any] = [
            .font: newFont
        ]
        textView.typingAttributes = attributes
    }
}
