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
  private let scroll = BehaviorRelay(value: (current: CGPoint(x: 0, y: 0), isUp: true))
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var videoListCollectionView: UICollectionView!
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
    
    videoListCollectionView.rx.contentOffset
      .scan([CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0)]) { (acc, point) -> [CGPoint] in
        var pointsHistory = acc
        pointsHistory.removeLast()
        
        pointsHistory.insert(point, at: 0)
        
        return pointsHistory
      }
      .map { (pointHistory) -> (CGPoint, Bool) in
        (current: pointHistory[0], isUp: pointHistory[1].y > pointHistory[0].y)
      }
      .bind(to: scroll)
      .disposed(by: bag)
    
    videoListCollectionView.rx.didEndDragging
      .asObservable()
      .subscribe(onNext: { _ in
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
      })
      .disposed(by: bag)
    
    scroll
      .subscribe(onNext: { (current, isUp) in
        let steps: CGFloat = 5
        let currentContentOffset = current.y
        let alphaRatio = 1 / (self.headerHeightConstraint.constant / steps)
        if self.headerTopConstraint.constant > -self.headerHeightConstraint.constant && !isUp && currentContentOffset > 0 {
          self.headerTopConstraint.constant -= steps
          self.headerView.alpha -= alphaRatio
          return
        }

        if isUp && self.headerTopConstraint.constant < 0 {
          self.headerTopConstraint.constant += steps
          self.headerView.alpha += alphaRatio
        }
      })
      .disposed(by: bag)
    videoListCollectionView.rx.reachedBottom
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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    videoListLayout.invalidateLayout()
    videoListCollectionView.reloadData()
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
      .bind(to: videoListCollectionView.rx.items) { (collectionView: UICollectionView, row: Int, element: Video) in
        let indexPath = IndexPath(row: row, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoListCollectionViewCell.identifier, for: indexPath) as! VideoListCollectionViewCell
        cell.video = element
        cell.maxWidth = collectionView.bounds.width

        return cell
      }
      .disposed(by: bag)
  }
}

extension HomeViewController: SearchViewControllerDelegate {
  func performSearchWith(text: String) {
    print("search")
  }
}
