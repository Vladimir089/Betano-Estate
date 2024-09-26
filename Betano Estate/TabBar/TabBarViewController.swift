//
//  TabBarViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import UIKit

var propertiesArr: [Home] = []

class TabBarViewController: UITabBarController {
    
    lazy var homePage = MainHomePageViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        propertiesArr = loadAthleteArrFromFile() ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(1, forKey: "tab")
        setting()
        setVC()
    }
    

    func setting() {
        tabBar.backgroundColor = .white
        tabBar.layer.cornerRadius = 20
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.25
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.masksToBounds = false
        tabBar.unselectedItemTintColor = .black.withAlphaComponent(0.3)
        tabBar.tintColor = .secondary
    }
    
    func setVC() {
        let homeVCTabItem = UITabBarItem(title: nil, image: .home.resize(targetSize: CGSize(width: 24, height: 24)), tag: 0)
        homePage.tabBarItem = homeVCTabItem

        viewControllers = [UINavigationController(rootViewController: homePage)]
        
        hideTitle()
    }
    
    
    func hideTitle() {
        for vc in viewControllers ?? [UIViewController()] {
            vc.tabBarItem.title = nil
            vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
            vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .selected)
        }
    }
    
    func loadAthleteArrFromFile() -> [Home]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("home.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Home].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }


}




extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
