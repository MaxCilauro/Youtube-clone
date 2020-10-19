//
//  BaseViewController.swift
//  youtube-clone
//
//  Created by Yaku on 18/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class BaseViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
      let backButtonBackgroundImage = UIImage(systemName: "arrow.left")
      let barAppearance =
          UINavigationBar.appearance(whenContainedInInstancesOf: [UIViewController.self])
      barAppearance.backIndicatorImage = backButtonBackgroundImage
      barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage

      let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
      backBarButtton.tintColor = .label
      navigationItem.backBarButtonItem = backBarButtton
    }
}
