//
//  UserOnboardingViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class UserOnboardingViewController: UIViewController {
    
    lazy var imageViewTop = UIImageView(image: .userOnb1)
    lazy var tap = 1
    lazy var cancellable = [AnyCancellable]()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.text = "Track property deals"
        return label
    }()
    
    lazy var botLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .center
        label.text = "Record transactions and monitor your profits"
        return label
    }()
    
    lazy var arrViews: [UIView] = {
        var arr: [UIView] = []
        for i in 0..<2 {
            let view = UIView()
            view.backgroundColor = .primary
            view.layer.cornerRadius = 4
            arr.append(view)
        }
        return arr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createInterface()
    }
    

    func createInterface() {
        view.addSubview(imageViewTop)
        imageViewTop.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(545)
        }
        
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageViewTop.snp.bottom).inset(-15)
        }
        
        view.addSubview(botLabel)
        botLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).inset(-5)
        }
        
        view.addSubview(arrViews[0])
        arrViews[0].snp.makeConstraints { make in
            make.height.width.equalTo(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.right.equalTo(view.snp.centerX).offset(-3)
        }
        
        view.addSubview(arrViews[1])
        arrViews[1].backgroundColor = UIColor(red: 229/255, green: 25/255, blue: 64/255, alpha: 0.5)
        arrViews[1].snp.makeConstraints { make in
            make.height.width.equalTo(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view.snp.centerX).offset(3)
        }
        
        let nextButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Next", for: .normal)
            button.layer.cornerRadius = 16
            button.backgroundColor = .secondary
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            return button
        }()
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.bottom.equalTo(arrViews[1].snp.top).inset(-20)
        }
        
        nextButton.tapPublisher
            .sink { _ in
                self.tapped()
            }
            .store(in: &cancellable)
    }
    
    func tapped() {
        tap += 1
        
        switch tap {
        case 2:
            UIView.animate(withDuration: 0.3) { [self] in
                imageViewTop.image = .userOnb2
                headerLabel.text = "Manage investments"
                botLabel.text = "Organize your properties and track financial stats"
                arrViews[0].backgroundColor = UIColor(red: 229/255, green: 25/255, blue: 64/255, alpha: 0.5)
                arrViews[1].backgroundColor = .primary
            }
        case 3:
            self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
        default:
            return
        }
    }

}
