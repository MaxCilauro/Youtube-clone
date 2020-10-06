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
    videoListCollectionView.rx.setDelegate(self).disposed(by: bag)
    
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

extension HomeViewController: SearchViewControllerDelegate {
  func performSearchWith(text: String) {
    print("search")
  }
}
