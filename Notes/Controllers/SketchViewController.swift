import UIKit
import SnapKit
import RealmSwift

class SketchViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Properties

    weak var delegate: NotesDelegate?
    let textView = UITextView()
    let fontSizeLabel = UILabel()
    var note: Note!
    var fontSize: CGFloat = 20
    var fontName: String = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
    private var text: NSMutableAttributedString?

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        configureTextView()
        configureToolbar()
        configureNavigationBar()
        configureNotificationCenter()
    }

    // MARK: - Private methods

    private func updateNote() {
        delegate?.updateNotes()
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

    private func configureFontPicker(_ button: UIButton) {
        button.addTarget(
            self,
            action: #selector(fontPickerTapped),
            for: .touchUpInside
        )
    }

    private func configureNavigationBar() {
        let addImageButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.rectangle"),
            style: .plain,
            target: self,
            action: #selector(addImageTapped)
        )
        navigationItem.rightBarButtonItem = addImageButton
    }

    private func configureFontSizeStepper(_ stepper: UIStepper) {
        stepper.value = Double(fontSize)
        stepper.addTarget(self, action: #selector(fontSizeChanged(_:)), for: .valueChanged)
        stepper.minimumValue = 1
        fontSizeLabel.text = "\(Int(stepper.value)) pt"
        fontSizeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
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

    private func configureTextView() {
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
        setFontSize()
        textView.delegate = self
        textView.isEditable = true
        textView.isSelectable = true
        textView.backgroundColor = UIColor(
            red: 253/255,
            green: 249/255,
            blue: 169/255,
            alpha: 1
        )
        textView.allowsEditingTextAttributes = true
        text = NSMutableAttributedString(attributedString: textView.attributedText)
        configureTextViewImage()
        textView.attributedText = text
        setTextViewConstraints()
    }

    private func configureTextViewImage() {
        let width  = view.frame.size.width - 10
        text?.enumerateAttribute(
            NSAttributedString.Key.attachment,
            in: NSRange(
                location: 0,
                length: textView.attributedText.length
            ),
            options: [],
            using: { [width] (object, range, _) in
                let textViewAsAny: Any = self.textView
                if let attachment = object as? NSTextAttachment, let img = attachment.image(
                    forBounds: self.textView.bounds,
                    textContainer: textViewAsAny as? NSTextContainer,
                    characterIndex: range.location
                ) {
                    guard let fileType = attachment.fileType else { return }
                    if fileType == "public.png" {
                        let aspect = img.size.width / img.size.height
                        if img.size.width <= width {
                            attachment.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                            return
                        }
                        let height = width / aspect
                        attachment.bounds = CGRect(
                            x: 0,
                            y: 0,
                            width: width,
                            height: height
                        )
                        attachment.image = img
                    }
                }
            })
    }

    // MARK: - Obj-c methods

    @objc private func fontPickerTapped() {
        let fontPickerViewController = UIFontPickerViewController()
        fontPickerViewController.delegate = self
        present(fontPickerViewController, animated: true)
    }

    @objc private func addImageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
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
        let attributes: [NSAttributedString.Key: Any] = [.font: newFont]
        textView.typingAttributes = attributes
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

// MARK: - Image Picker Delegate

extension SketchViewController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func compressImage(image: UIImage) -> UIImage? {
        guard let imageData = image.jpeg(.lowest) else {
            return nil
        }
        if imageData.count > 4000000 {
            guard let img = UIImage(data: imageData) else { return nil }
            return compressImage(image: img)
        }
        return UIImage(data: imageData)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let imageFromPicker = info[.originalImage] as? UIImage {
            guard let image = compressImage(image: imageFromPicker) else { return }
            let imageWidth = image.size.width
            let textViewWidth = textView.frame.size.width
            let tmpAttributes = textView.typingAttributes
            let imageAttachment = NSTextAttachment()
            if imageWidth > textViewWidth {
                let scale = (textViewWidth - 10) / imageWidth
                let newHeight = image.size.height * scale
                imageAttachment.bounds = CGRect(
                    x: 0,
                    y: 0,
                    width: textViewWidth - 10,
                    height: newHeight
                )
                imageAttachment.image = image
            } else {
                imageAttachment.image = image
            }
            let attributedString = NSAttributedString(attachment: imageAttachment)
            let text = NSMutableAttributedString(attributedString: textView.attributedText)
            text.append(NSAttributedString(string: "\n"))
            text.append(attributedString)
            text.append(NSAttributedString(string: "\n"))
            textView.attributedText = text
            textView.typingAttributes = tmpAttributes
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
