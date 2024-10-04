//
//  SettingsViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 30.09.2024.
//

import UIKit
import StoreKit
import WebKit
import Combine
import CombineCocoa

class SettingsViewController: UIViewController {
    
    private var cancellable = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Settings"
        createInterface()
    }
    
    private func createInterface() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        let shareView = createViews(image: .share, text: "Share our app", textButton: "Share")
        stackView.addArrangedSubview(shareView)
        
        let rateView = createViews(image: .rate, text: "Rate us", textButton: "Rate")
        stackView.addArrangedSubview(rateView)
        
        let usageView = createViews(image: .share, text: "Usage Policy", textButton: "Read")
        stackView.addArrangedSubview(usageView)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(238)
        }
        
    }
    
    private func createViews(image: UIImage, text: String, textButton: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        view.layer.cornerRadius = 12
        
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(42)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        let mainLabel = UILabel()
        mainLabel.text = text
        mainLabel.textColor = .black
        mainLabel.font = .systemFont(ofSize: 17, weight: .bold)
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.centerY.equalToSuperview()
        }
        
        let button = UIButton(type: .system)
        button.backgroundColor = .primary
        button.layer.cornerRadius = 17
        button.setTitle(textButton, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
        
        switch textButton {
        case "Share":
            button.tapPublisher
                .sink { _ in
                    self.shareApps()
                }
                .store(in: &cancellable)
        case "Rate":
            button.tapPublisher
                .sink { _ in
                    self.rateApps()
                }
                .store(in: &cancellable)
        case "Read":
            button.tapPublisher
                .sink { _ in
                    self.policy()
                }
                .store(in: &cancellable)
        default:
            print(1)
        }
        
        return view
    }
   

    private func rateApps() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let url = URL(string: "https://apps.apple.com/us/app/bnt-estate/id6736412744") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    private func shareApps() {
        let appURL = URL(string: "https://apps.apple.com/us/app/bnt-estate/id6736412744")!
        let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        // Настройка для показа в виде popover на iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func policy() {
        let webVC = WebViewController()
        webVC.urlString = "https://www.termsfeed.com/live/e23f9923-03db-46bd-a32b-a48e367183e1"
        present(webVC, animated: true, completion: nil)
    }
}


class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        // Загружаем URL
        if let urlString = urlString, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
