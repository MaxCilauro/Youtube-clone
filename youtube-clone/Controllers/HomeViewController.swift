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
  private let bag = DisposeBag()
  private let videos = BehaviorRelay<[Video]>(value: [])
  private let search = PublishRelay<String>()
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var videoListCollectionView: UICollectionView!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var videoListLayout: UICollectionViewFlowLayout! {
    didSet {
      videoListLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    videoListCollectionView.register(UINib(nibName: "VideoListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: VideoListCollectionViewCell.identifier)
    
    toggleHeaderOnScroll()
    toggleMidAnimationHeader()
    
    searchButton.rx
      .tap
      .bind {
        self.performSegue(withIdentifier: "goToSearch", sender: nil)
      }
      .disposed(by: bag)
    
    search
      .asObservable()
      .delay(.milliseconds(10), scheduler: MainScheduler.instance)
      .subscribe(onNext: { text in
        self.performSegue(withIdentifier: "goToSearchResults", sender: text)
      })
      .disposed(by: bag)
    
    fetchVideos()
    loadVideoList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    videoListLayout.invalidateLayout()
    videoListCollectionView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToSearch" {
      let searchVC = segue.destination as! SearchViewController
      searchVC.searchRelay = search
      return
    }
    
    if segue.identifier == "goToSearchResults" {
      let searchResultsVC = segue.destination as! SearchResultsViewController
      searchResultsVC.searchTerm = sender as? String
    }
  }
  
  func fetchVideos() {
    youtubeClient
      .getMostPopularVideos()
      .bind(to: videos)
      .disposed(by: bag)
  }
  
  func loadVideoList() {
    videos
      .bind(to: videoListCollectionView.rx.items) { (collectionView: UICollectionView, row: Int, element: Video) in
        let indexPath = IndexPath(row: row, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoListCollectionViewCell.identifier, for: indexPath) as! VideoListCollectionViewCell
        cell.video = element
        cell.maxWidth = collectionView.bounds.width
        
        return cell
      }
      .disposed(by: bag)
  }
  
  func toggleHeaderOnScroll() {
    videoListScroll()
      .subscribe(onNext: { (current, isScrollingDown) in
        let steps: CGFloat = 5
        let currentContentOffset = current.y
        let headerHeight = self.headerHeightConstraint.constant
        let alphaRatio = 1 / (headerHeight / steps)
        let visibleItems = 3
        
        guard let presentIndexPath = self.videoListCollectionView.indexPathForItem(at: current) else { return }
        // there should be a better way of checking if we are at the bottom of the collectionView
        let isShowingBottomVideo = presentIndexPath.row >= self.videos.value.count - visibleItems
        if currentContentOffset <= 0 || isShowingBottomVideo {
          return
        }
        
        
        if isScrollingDown && self.headerTopConstraint.constant > -headerHeight {
          self.headerTopConstraint.constant -= steps
          self.headerView.alpha -= alphaRatio
          return
        }
        
        if !isScrollingDown && self.headerTopConstraint.constant < 0 {
          self.headerTopConstraint.constant += steps
          self.headerView.alpha += alphaRatio
        }
      })
      .disposed(by: bag)
  }
  
  func videoListScroll() -> Observable<(CGPoint, Bool)> {
    videoListCollectionView.rx.contentOffset
      .scan([CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0)]) { (acc, point) -> [CGPoint] in
        var pointsHistory = acc
        pointsHistory.removeLast()
        
        pointsHistory.insert(point, at: 0)
        
        return pointsHistory
      }
      .map { (pointHistory) -> (CGPoint, Bool) in
        (current: pointHistory[0], isScrollingDown: pointHistory[0].y > pointHistory[1].y)
      }
  }
  
  func toggleMidAnimationHeader() {
    videoListCollectionView.rx.didEndDragging
      .asObservable()
      .subscribe(onNext: { _ in
        let headerHeight = self.headerHeightConstraint.constant
        let headerHalfHeight = -headerHeight / 2
        let currentTopConstrain = self.headerTopConstraint.constant
        
        if (currentTopConstrain == 0 || currentTopConstrain == -headerHeight) {
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
      })
      .disposed(by: bag)
  }
}
