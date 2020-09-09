//
//  VideoListViewController.swift
//  youtube-clone
//
//  Created by Yaku on 09/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController  {
    var searchTerm: String!
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
