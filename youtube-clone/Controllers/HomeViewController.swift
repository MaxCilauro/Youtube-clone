//
//  ViewController.swift
//  youtube-clone
//
//  Created by Yaku on 11/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
  private let youtubeClient = YoutubeClient()
  private var lastContentOffset: CGFloat = 0
  private var isUp: Bool = false
  private let bag = DisposeBag()
  private let youtubeItems = BehaviorRelay<[Video]>(value: [])
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var videoListCollectionView: UICollectionView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    videoListCollectionView.delegate = self
    videoListCollectionView.dataSource = self
    avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: VideoListCell.identifier)
    
    youtubeItems
      .asObservable()
      .subscribe(onNext: { [weak self] el in
        print("next", el.count)
        self?.videoListCollectionView.reloadData()
      }, onError: { (error) in
        print(error)
      }, onDisposed: {
        print("disposed")
      })
      .disposed(by: bag)
    
    
    fetchItems()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  @IBAction func onSearchClick(_ sender: UIButton) {
    performSegue(withIdentifier: "goToSearch", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToSearch" {
      let searchVC = segue.destination as! SearchViewController
      searchVC.delegate = self
    }
  }
  
  func fetchItems() {
    youtubeClient
      .getMostPopularVideos()
      .bind(to: youtubeItems)
      .disposed(by: bag)
      
  }
}

extension HomeViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    if (isUp && headerTopConstraint.constant == -headerHeightConstraint.constant) {
      UIView.animate(withDuration: 0.2) { [weak self] in
        self?.headerTopConstraint.constant = 0
        self?.headerView.alpha = 1
        self?.view.layoutIfNeeded()
      }
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let headerHeight = self.headerHeightConstraint.constant
    let headerHalfHeight = -headerHeight / 2
    let currentTopConstrain = self.headerTopConstraint.constant
    
    if (currentTopConstrain == 0 || currentTopConstrain == -self.headerHeightConstraint.constant) {
      return
    }
    
    if currentTopConstrain > headerHalfHeight {
      UIView.animate(withDuration: 0.1) { [weak self] in
        self?.headerView.alpha = 1
        self?.headerTopConstraint.constant = 0
        self?.view.setNeedsLayout()
      }
      return
    }
    
    UIView.animate(withDuration: 0.1) { [weak self] in
      self?.headerView.alpha = 0
      self?.headerTopConstraint.constant = -headerHeight
      self?.view.setNeedsLayout()
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let steps: CGFloat = 5
    let currentContentOffset = scrollView.contentOffset.y
    let alphaRatio = 1 / (headerHeightConstraint.constant / steps)
    if headerTopConstraint.constant > -headerHeightConstraint.constant && !isUp && currentContentOffset > 0 {
      headerTopConstraint.constant -= steps
      headerView.alpha -= alphaRatio
    }
    
    if isUp && headerTopConstraint.constant < 0 && currentContentOffset <= headerHeightConstraint.constant {
      headerTopConstraint.constant += steps
      headerView.alpha += alphaRatio
    }
    
    isUp = lastContentOffset > currentContentOffset
    lastContentOffset = currentContentOffset
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = self.view.frame.width
    
    return .init(width: width, height: width - 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    youtubeItems.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: VideoListCell.identifier, for: indexPath) as! VideoListCell
    
    cell.video = youtubeItems.value[indexPath.item]
    
    return cell
  }
}

extension HomeViewController: SearchViewControllerDelegate {
  func performSearchWith(text: String) {
    print("search")
  }
}
