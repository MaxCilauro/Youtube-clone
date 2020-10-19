//
//  VideoListViewController.swift
//  youtube-clone
//
//  Created by Yaku on 09/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultsViewController: UIViewController  {
  var searchTerm: String!
  
  private let youtubeClient = YoutubeClient()
  private let searchResults = BehaviorRelay<[Video]>(value: [])
  private let searchRelay = PublishRelay<String>()
  private let bag = DisposeBag()
  
  @IBOutlet weak var searchResultsTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setButtonInNavigationBarWith(term: searchTerm)
    setClearButtonInNavigationBar()
    setupResultsTableView()
    
    searchRelay
      .asObservable()
      .delay(.milliseconds(10), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] newTerm in
        self?.searchResults.accept([])
        self?.searchItemsWith(term: newTerm)
        let termButton = self?.navigationItem.titleView as? UIButton
        termButton?.setTitle(newTerm, for: .normal)
      })
      .disposed(by: bag)
    
    searchItemsWith(term: searchTerm)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (searchResultsTableView.delegate != nil) {
      return
    }
    
    searchResults
      .bind(to: searchResultsTableView.rx.items) { (tableView: UITableView, row: Int, element: Video) -> UITableViewCell in
        let indexPath = IndexPath(row: row, section: 0)
        
        if element.kind == "youtube#channel" {
          let channelCell = tableView.dequeueReusableCell(withIdentifier: ChannelResultCell.identifier, for: indexPath) as! ChannelResultCell
          channelCell.video = element

          return channelCell
        }
        
        let searchResultCell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
        searchResultCell.video = element
        
        return searchResultCell
      }
      .disposed(by: bag)
  }
  
  private func setButtonInNavigationBarWith(term: String) {
    let termButton = UIButton(type: .custom)
    termButton.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
    termButton.setTitle(term, for: .normal)
    termButton.setTitleColor(.label, for: .normal)
    termButton.contentHorizontalAlignment = .left
    
    navigationItem.titleView = termButton
    
    termButton.rx.tap
      .asObservable()
      .subscribe(onNext: navigateToSearchWith(term: searchTerm))
      .disposed(by: bag)
  }
  
  private func setClearButtonInNavigationBar() {
    let crossImage = UIImage(named: "cross")?.resize(size: CGSize(width: 16, height: 16))
    let clearSearchButton = UIBarButtonItem(image: crossImage, style: .plain, target: nil, action: nil)
    clearSearchButton.tintColor = .label
    navigationItem.rightBarButtonItem = clearSearchButton
    
    clearSearchButton.rx.tap
      .asObservable()
      .subscribe(onNext: navigateToSearchWith(term: nil))
      .disposed(by: bag)
  }
  
  private func setupResultsTableView() {
    searchResultsTableView.rowHeight = UITableView.automaticDimension
    searchResultsTableView.estimatedRowHeight = 120
    searchResultsTableView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: SearchResultCell.identifier)
    searchResultsTableView.register(UINib(nibName: "ChannelResultCell", bundle: nil), forCellReuseIdentifier: ChannelResultCell.identifier)
  }
  
  private func searchItemsWith(term: String) {
    youtubeClient
      .search(query: term)
      .bind(to: searchResults)
      .disposed(by: bag)
  }
  
  private func navigateToSearchWith(term: String?) -> () -> Void {
    return {
      self.performSegue(withIdentifier: "goToSearch", sender: term)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToSearch" {
      let vc = segue.destination as! SearchViewController
      vc.searchRelay = searchRelay
      vc.searchTerm = sender as? String
    }
  }
}
