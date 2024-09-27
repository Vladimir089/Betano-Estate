//
//  PropertiesViewController.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 27.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class PropertiesViewController: UIViewController {
    
    var watchListPubliser = PassthroughSubject<Any, Never>()
    var cancellable = [AnyCancellable]()
    
    private var sortedProperties: [Home] = []
    private var selectedType = "Earning"
    
    //ui
    var collection: UICollectionView?
    
    //other
    private lazy var properties = "0"
    private lazy var earning = "0"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Properties"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always

        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton

        let addButton = UIButton(type: .system)
        addButton.setBackgroundImage(UIImage.addProperties
            .resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
        navigationController?.navigationBar.addSubview(addButton)
        let targetView = self.navigationController?.navigationBar
        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(targetView?.snp.trailing ?? 1).offset(-15)
            make.bottom.equalTo(targetView?.snp.bottom ?? 1).offset(-6)
            make.height.width.equalTo(40)
        }
    }
    
    @objc func addButtonTapped() {
        print("addNewprop")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        subscribe()
        checkStat()
        createInterface()
    }
    
    private func checkStat() {
        if let prop = UserDefaults.standard.string(forKey: "properties") {
            properties = prop
        }
        if let earn = UserDefaults.standard.string(forKey: "earnOnes") {
            earning = earn
        }
    }
    
    private func subscribe() {
        watchListPubliser
            .sink { _ in
                self.sortedProperties = propertiesArr
                self.changeCategory(category: "Earning")
                self.collection?.reloadData()
            }
            .store(in: &cancellable)
        
        //watchListPubliser.send(0) при лайке дома
    }
    
   
    

    func createInterface() {
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .white
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.dataSource = self
            collection.showsVerticalScrollIndicator = false
            collection.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
    }
    
    private func createViews(topText: String, topImage: UIImage, mainText: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
        view.layer.cornerRadius = 14
        
        let imageViewType = UIImageView(image: topImage.resize(targetSize: CGSize(width: 26, height: 26)))
        view.addSubview(imageViewType)
        imageViewType.snp.makeConstraints { make in
            make.height.width.equalTo(26)
            make.top.left.equalToSuperview().inset(15)
        }
        
        let topLabel = UILabel()
        topLabel.text = topText
        topLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.5)
        topLabel.font = .systemFont(ofSize: 13, weight: .regular)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(imageViewType.snp.right).inset(-5)
            make.centerY.equalTo(imageViewType)
        }
        
        let mainLabel = UILabel()
        mainLabel.text = mainText
        mainLabel.textColor = .black
        mainLabel.textAlignment = .left
        mainLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        
        let editImageView = UIImageView(image: .editTopsView.withRenderingMode(.alwaysTemplate))
        editImageView.tintColor = .gray.withAlphaComponent(0.8)
        view.addSubview(editImageView)
        editImageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(15)
            make.height.width.equalTo(24)
        }
        
        return view
    }
    
    private func openAlrertController() {
        let alertController = UIAlertController(title: "Change", message: "Change properties and earning ones", preferredStyle: .alert)
        alertController.addTextField()
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "Properties"
        alertController.textFields?[1].placeholder = "Earning ones"
        
        alertController.textFields?[0].text = properties == "0" ? "" : properties
        alertController.textFields?[1].text = earning == "0" ? "" : earning
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            UserDefaults.standard.setValue(alertController.textFields?[0].text ?? "", forKey: "properties")
            UserDefaults.standard.setValue(alertController.textFields?[1].text ?? "", forKey: "earnOnes")
            self.properties = alertController.textFields?[0].text ?? ""
            self.earning = alertController.textFields?[1].text ?? ""
            self.collection?.reloadData()
            self.dismiss(animated: true)
        }
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    
    private func changeCategory(category: String) {
        sortedProperties.removeAll()
        for i in propertiesArr {
            if i.propertyType == category {
                sortedProperties.append(i)
            }
        }
        print(category)
    }

}


extension PropertiesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            return 2
        } else {
            return sortedProperties.count > 0 ? sortedProperties.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white //.orange
            var collectionCancellable = [AnyCancellable]()
            
            if indexPath.row == 0 {
                let leftView = createViews(topText: "Properties", topImage: .propertiesTopLeft, mainText: properties)
                cell.addSubview(leftView)
                leftView.snp.makeConstraints { make in
                    make.left.top.equalToSuperview()
                    make.height.equalTo(93)
                    make.right.equalTo(cell.snp.centerX).offset(-5)
                }
                
                let tapPubliserLeft = UITapGestureRecognizer(target: self, action: nil)
                leftView.addGestureRecognizer(tapPubliserLeft)
                tapPubliserLeft.tapPublisher.sink { _ in
                    self.openAlrertController()
                }
                .store(in: &collectionCancellable)
                
                let rightView = createViews(topText: "Earning ones", topImage: .earningsTopLeft, mainText: earning)
                cell.addSubview(rightView)
                rightView.snp.makeConstraints { make in
                    make.right.top.equalToSuperview()
                    make.height.equalTo(93)
                    make.left.equalTo(cell.snp.centerX).offset(5)
                }
                let tapPubliserRight = UITapGestureRecognizer(target: self, action: nil)
                rightView.addGestureRecognizer(tapPubliserRight)
                tapPubliserRight.tapPublisher.sink { _ in
                    self.openAlrertController()
                }
                .store(in: &collectionCancellable)
                
                let segmentItems = ["Earning", "Available"]
                let segmentedControl = UISegmentedControl(items: segmentItems)
                segmentedControl.selectedSegmentIndex = 0
                segmentedControl.selectedSegmentTintColor = .secondary
                segmentedControl.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 241/255, alpha: 1)
                cell.addSubview(segmentedControl)
                segmentedControl.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(rightView.snp.bottom).inset(-10)
                    make.height.equalTo(28)
                }
                segmentedControl.selectedSegmentIndexPublisher
                    .sink { index in
                        self.changeCategory(category: segmentItems[index])
                    }
                    .store(in: &cancellable)
                
            } else {
                let layout = UICollectionViewFlowLayout()
                let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
                collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
                layout.scrollDirection = .vertical
                collection.delegate = self
                collection.dataSource = self
                cell.addSubview(collection)
                collection.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                cell.backgroundColor = .orange
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .white
            
            if sortedProperties.count > 0 {
                
            } else {
                let topLabel = UILabel()
                topLabel.text = "Empty"
                topLabel.textColor = .black
                topLabel.font = .systemFont(ofSize: 22, weight: .bold)
                cell.addSubview(topLabel)
                topLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(cell.snp.centerY)
                }
                
                let botLabel = UILabel()
                botLabel.textColor = UIColor(red: 0/255, green: 9/255, blue: 27/255, alpha: 0.7)
                botLabel.font = .systemFont(ofSize: 13, weight: .regular)
                botLabel.text = "You don’t have any properties"
                cell.addSubview(botLabel)
                botLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(cell.snp.centerY).offset(3)
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collection {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.bounds.width, height: 140)
            } else {
                if sortedProperties.count > 0 {
                    return CGSize(width: collectionView.bounds.width, height: CGFloat(sortedProperties.count * 250))
                } else {
                    return CGSize(width: collectionView.bounds.width, height: 243)
                }
            }
        } else {
            return CGSize(width: collectionView.bounds.width, height: CGFloat(sortedProperties.count > 0 ? sortedProperties.count : 1 * 243))
        }
    }
}
