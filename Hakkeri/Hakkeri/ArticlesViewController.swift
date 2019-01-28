import Foundation
import UIKit
import SafariServices

class ItemTableViewCell: UITableViewCell {
    let domainLabel = UILabel()
    let titleLabel = UILabel()
    let border = UIView()
    let bgColorView = UIView()
    
    let horizontalMargin: CGFloat = 15

    var item: Item? {
        didSet {
            domainLabel.text = item?.url.host
            titleLabel.text = item?.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(domainLabel)
        addSubview(titleLabel)
        addSubview(border)
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        domainLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        domainLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        domainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        domainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        border.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        border.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
        border.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        
        domainLabel.font = UIFont.systemFont(ofSize: 14)
        domainLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        
        border.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        
        bgColorView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        self.selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        domainLabel.text = ""
        titleLabel.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ArticlesViewController: UITableViewController {
    init() {
        super.init(style: .grouped)

        navigationController?.isNavigationBarHidden = true

        HackerNewsAPI.shared.update { [weak self] in
            DispatchQueue.main.sync {
                self?.tableView.reloadData()
            }
        }
    }
    
    
    func showInSafari(url: URL) {
        let svc = SFSafariViewController(url: url.absoluteURL, entersReaderIfAvailable: true)
        self.present(svc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HackerNewsAPI.shared.topStoryIds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ItemTableViewCell()
        
        HackerNewsAPI.shared.itemForLocation(n: indexPath.row, completion: { item in
            DispatchQueue.main.async {
                cell.item = item
            }
        })

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        
        let showThread = UITableViewRowAction(style: .normal, title: "Comments") { (action, index) in
            if let url = cell.item?.url {
                self.showInSafari(url: url)
            }
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            let activityViewController = UIActivityViewController(activityItems: ["\(cell.item?.url.absoluteString ?? "") from Hacker News"], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: {
                self.tableView.setEditing(false, animated: true)
            })
        }
        
        share.backgroundColor = UIColor.gray
        showThread.backgroundColor = UIColor.darkGray
        
        return [showThread, share]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
