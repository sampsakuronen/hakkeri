import Foundation
import UIKit
import SafariServices

class ItemTableViewCell: UITableViewCell {
    let domainLabel = UILabel()
    let titleLabel = UILabel()
    let border = UIView()
    
    let horizontalMargin: CGFloat = 15

    var item: Item? {
        didSet {
            self.titleLabel.alpha = 0
            self.domainLabel.alpha = 0

            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
                self.domainLabel.text = self.item?.url.host
                self.titleLabel.text = self.item?.title
                self.titleLabel.alpha = 1
                self.domainLabel.alpha = 1
            }, completion: nil)
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

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        self.selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        domainLabel.text = ""
        titleLabel.text = ""    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArticlesViewController: UITableViewController {
    init() {
        super.init(style: .plain)

        navigationController?.isNavigationBarHidden = true
        tableView.separatorStyle = .none

        refreshAll()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAll), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func refreshAll() {
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell,
            let item = cell.item else {
                return
        }

        showInSafari(url: item.url)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        
        let showThread = UITableViewRowAction(style: .normal, title: "Comments") { (action, index) in
            if let item = cell.item {
                self.showInSafari(url: item.threadUrl)
            }
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            guard let item = cell.item else {
                return
            }
            let activityViewController = UIActivityViewController(activityItems: ["\(item.title) - \(item.url.absoluteString) via Hacker News"], applicationActivities: nil)
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
