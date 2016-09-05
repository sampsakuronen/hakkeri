
import UIKit

class StoryTableViewCell: UITableViewCell {

    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var url: URL? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        domainLabel.text = ""
        titleLabel.text = ""
        url = nil
    }

}
