//
//  SearchViewController.swift
//  youtube-clone
//
//  Created by Yaku on 01/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController  {
    let historyKey = "history"
    let historyTableCellIdentifier = "historyCell"
    var searchTextView = UITextField()
    var history: [String] = []

    @IBOutlet weak var searchHistoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        history = UserDefaults.standard.array(forKey: historyKey) as? [String] ?? []
        setupSearch()
        setupSearchHistory()
    }
    
    func setupSearch() {
        searchTextView.delegate = self
        searchTextView.translatesAutoresizingMaskIntoConstraints = true
        searchTextView.placeholder = "Search on youtube"
        searchTextView.textAlignment = .left
        searchTextView.returnKeyType = .search
        
        self.navigationItem.titleView = searchTextView
    }
    
    fileprivate func setupSearchHistory() {
        searchHistoryTableView.delegate = self
        searchHistoryTableView.dataSource = self
        
        searchHistoryTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchTextView.becomeFirstResponder()
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        history.append(text)
        UserDefaults.standard.set(history, forKey: historyKey)
        return true
    }
}


extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchHistoryTableView.dequeueReusableCell(withIdentifier: historyTableCellIdentifier, for: indexPath)

        cell.imageView?.image = UIImage(systemName: "clock")
        cell.textLabel?.text = history[indexPath.row] as? String

            return cell
        }
}
