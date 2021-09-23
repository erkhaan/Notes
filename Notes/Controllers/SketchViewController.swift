import UIKit
import SnapKit

class SketchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel()
        view.addSubview(label)
        label.text = "SketchViewController"
        label.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }

}
