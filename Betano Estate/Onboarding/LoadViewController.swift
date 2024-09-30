//
//  LoadViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import UIKit
import SnapKit

class LoadViewController: UIViewController {
    
    lazy var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createInterface()
        settingsTimer()
    }
    
    func settingsTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 7, repeats: false, block: { [self] _ in //поменять тайминтервал на 7
            timer.invalidate()
            if isBet == false {
                if UserDefaults.standard.value(forKey: "tab") != nil {
                    self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
                } else {
                    self.navigationController?.setViewControllers([UserOnboardingViewController()], animated: true)
                }
            } else {
                
            }
        })
    }
    

    func createInterface() {
        let imageViewIcon = UIImageView(image: .loadIcon)
        view.addSubview(imageViewIcon)
        imageViewIcon.snp.makeConstraints { make in
            make.height.width.equalTo(225)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }
        
        let loadInticator = UIActivityIndicatorView(style: .large)
        loadInticator.color = .primary
        view.addSubview(loadInticator)
        loadInticator.snp.makeConstraints { make in
            make.height.width.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageViewIcon.snp.bottom).inset(-150)
        }
        loadInticator.startAnimating()
    }

}



extension UIViewController {
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
