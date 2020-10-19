//
//  BaseTabBarViewController.swift
//  youtube-clone
//
//  Created by Yaku on 20/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class BaseTabBarViewController: BaseViewController {
  
  enum ControllerName: Int {
    case home, explore, subscriptions, notifications, library
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewControllers()
  }
  
  private func setupViewControllers() {
    
    viewControllers?.enumerated().forEach({ (index, viewController) in
      if let name = ControllerName.init(rawValue: index) {
        switch name {
        case .home:
          setTabBar(viewController: viewController, iconName: "home")
        case .explore:
          setTabBar(viewController: viewController, iconName: "explore")
        case .subscriptions:
          setTabBar(viewController: viewController, iconName: "subscriptions")
        case .notifications:
          setTabBar(viewController: viewController, iconName: "notifications")
        case .library:
          setTabBar(viewController: viewController, iconName: "library")
        }
      }
    })
  }
  
  private func setTabBar(viewController: UIViewController, iconName: String) {
    viewController.tabBarItem.selectedImage = UIImage(named: "\(iconName)-selected")?
      .resize(size: .init(width: 20, height: 20))?
      .withRenderingMode(.alwaysOriginal)
    viewController.tabBarItem.image = UIImage(named: "\(iconName)")?
      .resize(size: .init(width: 20, height: 20))?
      .withRenderingMode(.alwaysOriginal)
    viewController.tabBarItem.title = iconName.capitalized
  }
}
