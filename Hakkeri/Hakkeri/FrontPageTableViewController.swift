//
//  FrontPageTableViewController.swift
//  Hakkeri
//
//  Created by Sampsa Kuronen on 04.09.2016.
//  Copyright © 2016 Sampsa Kuronen. All rights reserved.
//

import UIKit

class FrontPageTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let height = UIApplication.shared.statusBarFrame.size.height
        let insets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
