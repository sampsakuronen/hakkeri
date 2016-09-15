
import UIKit

class StoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var url: URL? = nil
    var id: String? = nil
    var hackerNewsURL: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.03)
        self.selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        domainLabel.text = ""
        titleLabel.text = ""
        url = nil
        id = nil
        hackerNewsURL = nil
        mainView.alpha = 0.0
    }

}
