import UIKit
import SafariServices
import Alamofire


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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusBarStyle()
        getTopStories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTopStories() {
        Alamofire.request("https://hacker-news.firebaseio.com/v0/topstories.json", withMethod: .get)
            .responseJSON { response in
                if let topIds = response.result.value as? [Int] {
                    self.topStories = topIds
                    self.tableView.reloadData()
                }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath) as! StoryTableViewCell
        
        if cell.url == nil {
            Alamofire.request("https://hacker-news.firebaseio.com/v0/item/\(topStories[indexPath.row]).json", withMethod: .get)
                .responseJSON { response in
                    if let story = response.result.value as? NSDictionary {
                        if let urlString = story.object(forKey: "url") {
                            let url = URL(string: urlString as! String)
                            let domain = url?.host
                            cell.domainLabel.text = domain
                            cell.url = url
                        } else {
                            let url =  URL(string: "https://news.ycombinator.com/item?id=\(story.object(forKey: "id")! as? String)")
                            cell.domainLabel.text = "HN"
                            cell.url = url
                        }
                        
                        cell.titleLabel.text = story.object(forKey: "title")! as? String
                        
                        self.tableView.layoutSubviews()
                    }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let storyCell = cell as? StoryTableViewCell
        
        UIView.animate(withDuration: 0.3, animations: {
            storyCell?.mainView.alpha = 1.0
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StoryTableViewCell
        let svc = SFSafariViewController(url: cell.url!, entersReaderIfAvailable: true)
        self.present(svc, animated: true, completion: nil)
    }

}
