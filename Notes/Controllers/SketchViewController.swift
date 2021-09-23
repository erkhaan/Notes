import UIKit
import SnapKit

class SketchViewController: UIViewController {

    // MARK: Properties

    let textView = UITextView()

    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        textView.backgroundColor = UIColor(red: 253/255, green: 249/255, blue: 169/255, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.snp.makeConstraints { maker in
            maker.bottom.top.right.left.equalTo(0)
        }
    }

}
