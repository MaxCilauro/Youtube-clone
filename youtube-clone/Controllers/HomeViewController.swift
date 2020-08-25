//
//  ViewController.swift
//  youtube-clone
//
//  Created by Yaku on 11/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    private let youtubeClient = YoutubeClient()
    private var lastContentOffset: CGFloat = 0
    private var isUp: Bool = false

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
        youtubeClient.search(q: "honkai") { (success) in
            guard success else { return }
            
            self.videoListCollectionView.reloadData()
        }
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
        youtubeClient.searchItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: VideoListCell.identifier, for: indexPath) as! VideoListCell
        
        cell.videoItem = youtubeClient.searchItems[indexPath.item]
        
        return cell
    }
    
    
}

