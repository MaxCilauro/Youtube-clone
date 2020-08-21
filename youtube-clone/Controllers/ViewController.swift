//
//  ViewController.swift
//  youtube-clone
//
//  Created by Yaku on 11/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let youtubeClient = YoutubeClient()
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
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

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

