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
        print("last: ", lastContentOffset, "current: ", scrollView.contentOffset.y)
        if (headerTopConstraint.constant < 0 && isUp) {
            headerTopConstraint.constant = 0
                
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [],
                           animations: { [weak self] in
                                self?.view.layoutIfNeeded()
                            },
                           completion: nil)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContentOffset = scrollView.contentOffset.y
        
        if headerTopConstraint.constant > -headerHeightConstraint.constant && !isUp && currentContentOffset > 0 {
            headerTopConstraint.constant -= 4
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

