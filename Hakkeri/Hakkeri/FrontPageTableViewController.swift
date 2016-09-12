import UIKit
import SafariServices
import Alamofire
import QuartzCore


class FrontPageTableViewController: UITableViewController {
    var topStories = [Int]()
    
    func setStatusBarStyle() {
        let height = UIApplication.shared.statusBarFrame.size.height
        let insets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line: UIView = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
        
    }
    
    func getTopStories() {
        Alamofire.request("https://hacker-news.firebaseio.com/v0/topstories.json")
            .responseJSON { response in
                if let topIds = response.result.value as? [Int] {
                    self.topStories = topIds
                    self.tableView.reloadData()
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusBarStyle()
        getTopStories()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FrontPageTableViewController.getTopStories), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells as! [StoryTableViewCell] {
            let point = tableView.convert(cell.center, to: tableView.superview)
            cell.alpha = ((point.y * 100) / tableView.bounds.height) / 7
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! StoryTableViewCell
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            let activityViewController = UIActivityViewController(activityItems: ["\(cell.url!.absoluteString) from Hacker News via Hakkeri"], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: {
                self.tableView.setEditing(false, animated: true)
            })
        }
        
        share.backgroundColor = UIColor.darkGray
        
        return [share]
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath) as! StoryTableViewCell
        
        if cell.url == nil {
            Alamofire.request("https://hacker-news.firebaseio.com/v0/item/\(topStories[indexPath.row]).json")
                .responseJSON { response in
                    if let story = response.result.value as? NSDictionary {
                        if let urlString = story.object(forKey: "url") {
                            let url = URL(string: urlString as! String)
                            let domain = url?.host
                            cell.domainLabel.text = domain
                            cell.url = url
                        } else {
                            let id = String(story.object(forKey: "id") as! Int)
                            let hnUrl =  URL(string: "https://news.ycombinator.com/item?id=\(id)")
                            cell.domainLabel.text = "HN"
                            cell.url = hnUrl
                        }
                        
                        cell.titleLabel.text = story.object(forKey: "title")! as? String
                        
                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                    }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let storyCell = cell as? StoryTableViewCell {
            storyCell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            UIView.animate(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
                storyCell.mainView.alpha = 1.0
                storyCell.layer.transform = CATransform3DMakeScale(1.01, 1.01, 1)
                },completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        storyCell.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    })
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StoryTableViewCell, let url = cell.url {
            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            self.present(svc, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? StoryTableViewCell, let _ = cell.url {
            return indexPath
        } else {
            return nil
        }
    }
}
