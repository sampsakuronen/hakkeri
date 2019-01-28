import Foundation

enum ItemType: String {
    case job
    case story
    case comment
    case poll
    case pollopt
    case unknown
}

struct Item {
    let id: Int
    let type: ItemType
    let url: URL
    let title: String

    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
        let urlString = json["url"] as? String,
        let url = URL(string: urlString),
        let title = json["title"] as? String,
        let type = json["type"] as? String else {
            return nil
        }
        
        self.id = id
        self.url = url
        self.title = title
        self.type = ItemType(rawValue: type) ?? .unknown
    }
}

class HackerNewsAPI {
    static let shared = HackerNewsAPI()
    
    static let domain = "https://hacker-news.firebaseio.com/v0"
    static let topStories = URL(string: "\(domain)/topstories.json")!
   
    var topStoryIds: [Int] = []
    
    var cachedStories: [Item] = [] {
        didSet {
            if (cachedStories.count > 200) {
                cachedStories = []
            }
        }
    }

    private func constructItemURL(_ itemNumber: Int) -> String {
        let itemURL = URL(string: "\(HackerNewsAPI.domain)/item")!
        return "\(itemURL)/\(itemNumber).json"
    }
    
    func update(completion: @escaping ()->()) {
        let task = URLSession.shared.dataTask(with: HackerNewsAPI.topStories) { [weak self] data, response, error in
            guard error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                self?.topStoryIds = []
                completion()
                return
            }
            
            self?.topStoryIds = json as? [Int] ?? []
            completion()
        }
        task.resume()
    }
    
    private func fetchItem(id: Int, completion: @escaping (Item?) -> ()) {
        let itemURL = URL(string: constructItemURL(id))!
        let task = URLSession.shared.dataTask(with: itemURL) { data, response, error in
            guard error == nil,
                let data = data,
                let serialisedJSON = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = serialisedJSON as? [String : Any] else {
                    completion(nil)
                    return
            }

            if let item = Item(json: json) {
                self.cachedStories.append(item)
                completion(item)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func itemForLocation(n: Int, completion: @escaping (Item?) -> ()) {
        let storyId = topStoryIds[n]
        let cachedStory = cachedStories.filter { item in
            return item.id == storyId
        }
        
        if let cacheHit = cachedStory.first {
            completion(cacheHit)
        } else {
            fetchItem(id: storyId, completion: completion)
        }
    }
}
