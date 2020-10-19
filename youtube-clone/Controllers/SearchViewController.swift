//
//  SearchViewController.swift
//  youtube-clone
//
//  Created by Yaku on 01/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController  {
  var searchRelay: PublishRelay<String>!
  var searchTerm: String?
  
  private let historyKey = "history"
  private let historyTableCellIdentifier = "historyCell"
  private var clearButton: UIBarButtonItem?
  private var searchTextField = UITextField()
  private var history = BehaviorRelay<[String]>(value: [])
  private let bag = DisposeBag()
  
  @IBOutlet weak var searchHistoryTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let crossImage = UIImage(named: "cross")?.resize(size: CGSize(width: 16, height: 16))
    let customClearButton = UIBarButtonItem(image: crossImage, style: .plain, target: self, action: #selector(clearTextField))
    customClearButton.tintColor = .label
    clearButton = customClearButton
    
    let savedHistory = UserDefaults.standard.array(forKey: historyKey) as? [String] ?? []
    history.accept(savedHistory)
    
    setupSearch()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    setupSearchHistory()
  }
  
  func setupSearch() {
    searchTextField.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
    searchTextField.placeholder = "Search on youtube"
    searchTextField.textAlignment = .left
    searchTextField.returnKeyType = .search
    searchTextField.text = searchTerm

    navigationItem.titleView = searchTextField
    
    searchTextField.becomeFirstResponder()
    subscribeToSearchEvents()
  }
  
  func subscribeToSearchEvents() {
    searchTextField.rx.controlEvent(.editingDidEndOnExit)
      .asObservable()
      .subscribe(onNext: {
        guard let text = self.searchTextField.text, !text.isEmpty else { return }
        let updatedHistory = [text] + self.history.value
        self.history.accept(updatedHistory)
        UserDefaults.standard.set(updatedHistory, forKey: self.historyKey)
        
        self.searchRelay.accept(text)
        self.closeSearch()
      })
      .disposed(by: bag)
    
    searchTextField.rx.text.orEmpty
      .subscribe { (controlProperty) in
        guard let text = controlProperty.element else {
          self.toggleClearButton(isVisible: false)
          return
        }
        self.toggleClearButton(isVisible: text != "")
        
      }
      .disposed(by: bag)
  }
  
  fileprivate func setupSearchHistory() {
    history
      .bind(to: searchHistoryTableView.rx.items) { (tableView: UITableView, row: Int, element: String) in
        let cell = tableView.dequeueReusableCell(withIdentifier: self.historyTableCellIdentifier, for: IndexPath(row: row, section: 0))
        
        cell.imageView?.image = UIImage(systemName: "clock")
        cell.textLabel?.text = element
        
        return cell
      }
      .disposed(by: bag)
    
    searchHistoryTableView.rx.itemSelected
      .asObservable()
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        self.searchRelay.accept(self.history.value[indexPath.row])
        self.closeSearch()
      })
      .disposed(by: bag)
  }
  
  @objc func clearTextField() {
    searchTextField.text = ""
    toggleClearButton(isVisible: false)
  }
  
  func toggleClearButton(isVisible: Bool) {
    if isVisible {
      if navigationItem.rightBarButtonItem == nil {
        navigationItem.rightBarButtonItem = clearButton
      }
      return
    }
    
    navigationItem.rightBarButtonItem = nil
  }
  
  func closeSearch() {
    self.navigationController?.popViewController(animated: false)
  }
}

extension UIViewController {
  
}
