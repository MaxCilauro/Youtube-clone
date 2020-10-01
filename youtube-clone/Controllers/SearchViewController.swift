//
//  SearchViewController.swift
//  youtube-clone
//
//  Created by Yaku on 01/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
  func performSearchWith(text:String)
}

class SearchViewController: UIViewController  {
  let historyKey = "history"
  let historyTableCellIdentifier = "historyCell"
  var closeButton = UIBarButtonItem()
  var searchTextField = UITextField()
  var history: [String] = []
  var delegate: SearchViewControllerDelegate?
  
  @IBOutlet weak var searchHistoryTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    closeButton = UIBarButtonItem.init(barButtonSystemItem: .close, target: self, action: #selector(clearTextField))
    history = UserDefaults.standard.array(forKey: historyKey) as? [String] ?? []
    setupSearch()
    setupSearchHistory()
  }
  
  func setupSearch() {
    searchTextField.delegate = self
    searchTextField.translatesAutoresizingMaskIntoConstraints = true
    searchTextField.placeholder = "Search on youtube"
    searchTextField.textAlignment = .left
    searchTextField.returnKeyType = .search
    
    self.navigationItem.titleView = searchTextField
  }
  
  fileprivate func setupSearchHistory() {
    searchHistoryTableView.delegate = self
    searchHistoryTableView.dataSource = self
    
    searchHistoryTableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    searchTextField.becomeFirstResponder()
  }
  
  @objc func clearTextField() {
    searchTextField.text = ""
    isClearButtonVisible(false)
  }
  
  func isClearButtonVisible(_ isVisible: Bool) {
    if isVisible {
      if navigationItem.rightBarButtonItem == nil {
        navigationItem.rightBarButtonItem = closeButton
      }
      return
    }
    
    navigationItem.rightBarButtonItem = nil
  }
  
  func closeSearch() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SearchViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let text = textField.text else { return false }
    history.append(text)
    UserDefaults.standard.set(history, forKey: historyKey)
    
    delegate?.performSearchWith(text: text)
    closeSearch()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text, let textRange = Range(range, in: text) {
      let updatedText = text.replacingCharacters(in: textRange, with: string)
      
      isClearButtonVisible(updatedText != "")
      return true
    }
    
    isClearButtonVisible(false)
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
    cell.textLabel?.text = history[indexPath.row] as String
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.performSearchWith(text: history[indexPath.row])
    closeSearch()
  }
}
