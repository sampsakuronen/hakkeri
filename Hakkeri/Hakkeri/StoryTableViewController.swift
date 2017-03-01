import UIKit
import SafariServices
import Alamofire
import QuartzCore
import Firebase

class StoryTableViewCell: UITableViewCell {
    let domainLabel = UILabel()
    let titleLabel = UILabel()
    let border = UIView()
    let bgColorView = UIView()
    
    let horizontalMargin: CGFloat = 15
    
    var url: URL? = nil
    var id: String? = nil
    var hackerNewsURL: String? = nil
    var storyRequest: DataRequest? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        url = nil
        id = nil
        hackerNewsURL = nil
        
        if let request = storyRequest {
            request.cancel()
            storyRequest = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class StoryTableViewController: UITableViewController {
    let CELL_ID = "StoryCell"
    var topStories: [Int] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tableView.register(StoryTableViewCell.self, forCellReuseIdentifier: CELL_ID)
        
        tableView.showsVerticalScrollIndicator = false
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    func getTopStories() {
        let TOP_STORIES_URL = "https://hacker-news.firebaseio.com/v0/topstories.json"
        Alamofire.request(TOP_STORIES_URL)
                .responseJSON { response in
                    if let topIds = response.result.value as? [Int] {
                        self.topStories = topIds
                        self.tableView.reloadData()
                    }
                }
    }

    func showInSafari(url: URL) {
        let defaults = UserDefaults.standard
        let dontUseReaderMode = defaults.bool(forKey: "dont_use_reader_mode")

        let svc = SFSafariViewController(url: url, entersReaderIfAvailable: !dontUseReaderMode)

        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
                "url": NSString(string: url.absoluteString),
                "dontUseReaderMode": dontUseReaderMode as NSObject
        ])

        self.present(svc, animated: true, completion: nil)
    }

    func getHackerNewsURL(id: String) -> String {
        return "https://news.ycombinator.com/item?id=\(id)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getTopStories()

        NotificationCenter.default.addObserver(self, selector: #selector(getTopStories), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        FIRAnalytics.logEvent(withName: kFIREventViewItemList, parameters: nil)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells as! [StoryTableViewCell] {
            let point = tableView.convert(cell.center, to: tableView.superview)
            cell.alpha = ((point.y * 100) / tableView.bounds.height) / 10
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! StoryTableViewCell

        let showThread = UITableViewRowAction(style: .normal, title: "Comments") { (action, index) in
            if let urlString = cell.hackerNewsURL, let url = URL(string: urlString) {
                self.showInSafari(url: url)
            }
        }

        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            let activityViewController = UIActivityViewController(activityItems: ["\(cell.url!.absoluteString) from Hacker News via Hakkeri"], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: {
                FIRAnalytics.logEvent(withName: kFIREventShare, parameters: [
                        "url": NSString(string: cell.url!.absoluteString)
                ])
                self.tableView.setEditing(false, animated: true)
            })
        }

        share.backgroundColor = UIColor.gray
        showThread.backgroundColor = UIColor.darkGray

        return [showThread, share]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! StoryTableViewCell

        let storyRequest = Alamofire.request("https://hacker-news.firebaseio.com/v0/item/\(topStories[indexPath.row]).json")
                .responseJSON { response in
                    if let story = response.result.value as? NSDictionary {
                        if let urlString = story.object(forKey: "url") {
                            let url = URL(string: urlString as! String)
                            let domain = url?.host
                            cell.domainLabel.text = domain
                            cell.url = url
                        } else {
                            let id = String(story.object(forKey: "id") as! Int)
                            let hnUrl = self.getHackerNewsURL(id: id)
                            cell.domainLabel.text = "Hacker News"
                            cell.url = URL(string: hnUrl)
                        }

                        let id = String(story.object(forKey: "id") as! Int)
                        cell.hackerNewsURL = self.getHackerNewsURL(id: id)
                        cell.titleLabel.text = story.object(forKey: "title")! as? String

                        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
                                "url": NSString(string: cell.url!.absoluteString)
                        ])

                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                    }
                }

        cell.storyRequest = storyRequest

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let storyCell = cell as? StoryTableViewCell else {
            return
        }

        storyCell.layer.transform = CATransform3DMakeScale(0.2, 0.2, 1)

        UIView.animate(
                withDuration: 0.4,
                delay: 0,
                options: .allowUserInteraction,
                animations: {
                    storyCell.alpha = 1.0
                    storyCell.layer.transform = CATransform3DMakeScale(1.01, 1.01, 1)
                },
                completion: { _ in
                    UIView.animate(
                            withDuration: 0.1,
                            animations: {
                                storyCell.layer.transform = CATransform3DMakeScale(1, 1, 1)
                            }
                    )
                }
        )
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? StoryTableViewCell,
              let url = cell.url else {
            return
        }

        showInSafari(url: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
